# gpl
# 
#  Author: Renwix (renwix@gmail.com)
#  Maintainer: Renwix
#  Copyright (C) 2008 Renwix, all rights reserved.
#  Created: Tue Sep 23 23:52:17 MDT 2008
# 
# 
#=======================================================================
# 
# This file is part of theSiliProject, a humorous software organization,
# design and development toolkit.
# 
# theSiliProject is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# theSiliProject is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with theSiliProject. If not, see <http://www.gnu.org/licenses/>.
# 
#=======================================================================
# 
# /gpl

package Sili::Ness;
# use strict;

=pod

=head1 NAME

Sili::Ness - The definition of a bit of silliness. If something is
siliable, it can be described as part of theSiliSystem.

=head1 DESCRIPTION

The OWL and RDF specs (w3c) layout a definition for how data relates
to other data. There are pieces of this model that are similar to
those specs and there are bits that may not have any real place in any
spec, anywhere! The working notion is that it is interesting to
describe the relationship between data in an object oriented way, but
only if the mechanism for those declarations is significantly shorter
(and easier to read/write than the equivalent XML (or some other
implementation). I have seen it done in s-expressions and that is
extremely interesting; This should strive to be somewhere between the
XML and the s-expression for the same data.

I choose perl for this due to the extremely flexible nature of the
language. With function prototypes and some trickery, it is possible
to a large degree to write new languages in Perl itself. These
languages are what Martin Fowler refers to as an Internal DSL, as
opposed to requiring the formal grammar of an external DSL. As such
they are really quite quick and easy to write. Perhaps too much so, as
the dev can quickly shoot themselves in the foot - with a bazooka (or
whatever the perl saying is...)

=cut

use Sili::NamedParams;
use Carp;
use Data::Dumper;
use Storable qw( dclone );
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use Pod::Usage;
use Exporter;
our (@ISA, @EXPORT);
@ISA = qw( Exporter );
@EXPORT = qw( defineClass isObject debugPrint param members isa isSome CONFESS CROAK WARN USAGE getopts );

sub CONFESS (@) { confess BOLD, RED, @_, RESET }
sub CROAK   (@) { croak BOLD, RED, @_, RESET }
sub WARN    (@) { warn YELLOW, BOLD, ON_BLACK, "@_", RESET }

=pod

A lot of what this library is about is taking the shortcuts that perl
gives us and using them. Embracing the "ugly side" of Perl and using
it to our benefit. Of course, there are a couple of things that are a
requirement then:

=head3 Ugly Patterns

These are patterns, people who extend the class shouldn't be trying to
use the same trickery. It is a pattern of the base class that you
create objects in a certain way. Don't try to get sassy with your own
perl code that extends this lib, try to stick to the regular burned in
perl code patterns.

=head3 Hide Ugliness

Bury the patterns deep in the system (where they won't have to be
maintained. For perf reasons, the model can almost never be cleanly
described; There will always be an "ugly statement". To combat that we
bury the hard to maintain bits deep enough that no one has to maintain
those bits. (wishful thinking)

=head2 FUNCTIONS

=head3 my $hashref = gHash( namespace::name )

Grab the static data structure out of the named location. This is
stictly for internal mechanisms and shouldn't be used outside this
module. Polluting Perl namespaces is a bad thing!

=cut
sub gHash ($) {
  return \%{*{ $_[0] }};
}


=pod

=head3 my $arrayref = gArray( namespace::name )

Grab the static data structure out of the named location. This is
stictly for internal mechanisms and shouldn't be used outside this
module. Polluting Perl namespaces is a bad thing!

=cut
sub gArray ($) {
  return \@{*{ $_[0] }};
}


=pod

=head3 my $true = keyInISAObjs( $key, @isa )

This is used to recursively inspect an object hierarchy to discover if
the key in question is defined as an available field in the current
class, or any of it's parent classes. The __data hash in the class
namespace defines the list of available fields for a class.

=cut
sub keyInISAObjs {
  my ($key, @isa) = @_;
  for my $i (@isa) {
    my $data = gHash $i . '::__data';
    return 1 if exists $data->{$key};
    my $isa = gArray $i . '::ISA';
    return 1 if keyInISAObjs( $key, @$isa );
  }
}


=pod

=head3 my $obj = new( %defaults )

The classic perl object constructor. By use'ing this class the new
function becomes available in the current class namespace. The
construction of the object validates that all fields passed into it
are defined as available fields in this class, or any of its
parents. If a field isn't defined, then it generates an error immediately.

It also generates an accessor for that key named the same as the
key. It uses the accessor to set the data passed in for the named
value.

Next it checks a list of defaults. The defaults are part of a classes
__data hashref. If there are any default values defined in this class,
or parent classes, that haven't been defined in the constructor call,
then they are initialized here.

Lastly it makes a call to the object's init() function if it
exists. This is where a user can override or alter or extend the new
function in some way.

=cut
sub new {
  my $class = shift;
  my $self  =  bless {}, $class;
  my $d = gHash $class . '::__data';
  my %a = @_;
  while (my ($k, $v) = each %a) {
    # is this a valid field?
    CONFESS "$k isn't defined for class '$class'!"
        if ! keyInISAObjs($k, $class);
    # call the accessor
    eval $class . '::' . $k . '( $self, $v );';
  }
  # set defaults & check types & required
  while (my ($k,$v) = each %$d) {
    if ( $v->{default} && not exists $self->{$k} ) {
      if (ref $v->{default}) {
        $self->{$k} = dclone($v->{default});
      } else {
        $self->{$k} = $v->{default};
      }
    }
    if ( defined $v->{isa} && exists $self->{$k} ) {
      CONFESS "$k should be of type '" . $v->{isa} . "', not '" . ref( $self->{$k} ) . "'"
          unless ref( $self->{$k} ) eq $v->{isa};
    }
    if ( defined $v->{required} && ! exists $self->{$k} ) {
      CONFESS "$k is required to create a type of '" . ref( $self ) . "'";
    }
  }

  $self->init( @_ ) if $self->UNIVERSAL::can( 'init' );
  return $self;
}


=pod

=head3 my $cloned_obj = $obj->clone( )

Storable copy of the object. It won't work with function
pointers. Keep the object contents to data. If you are stuffing fn
pointers into perl objects, use a different library!

=cut
sub clone {
  my $self = shift;
  return dclone($self);
}


=pod

=head3 AUTOLOAD

This module implements AUTOLOAD. It is also a base class for the data
descriptions in your own project. This means that it is possible to
inadvertantly call a property that doesn't exist. There are some
attempts made to check for this case by inspecting the __data
properties of the class hierarchy.

Also, this AUTOLOAD works as a poor man's memoize, calling a property
on an object before it exists will generate the accessor routine so
that future calls to access that data do not pass through
AUTOLOAD. Note that the generated accessor is the typical 3-state perl
accessor, if there is an argument passed to it, the object->property
takes that argument as it's value (and it is returned as well). If
there is no argument, then the current value is returned. This cleans
up a lot of the perl OO code and makes it a little easier to consume.

   my $name = $obj->name('bob');
   $name = $obj->name();
   $name = $obj->name

Those are all legitimate syntaxes that are generated by this AUTOLOAD.

=cut
our ($AUTOLOAD);
sub AUTOLOAD {
  my ($self, @argv) = @_;
  # for example: $obj->name('newName')
  $AUTOLOAD =~ /.*::(\w+)/;
  my $attribute = $1;
  my $class = ref $self;
  # is this a valid field?
  confess "$attribute isn't defined for class '$class'!"
    if ! keyInISAObjs($attribute, $class);
  # And a poor-man's accessor memoize
  *{ $AUTOLOAD } = my $c = sub {
    my ($_s, $_arg) = @_;
    $_s->{ $attribute } = $_arg if defined $_arg;
    return $_s->{ $attribute }
  };
  return $c->($self, @argv);
}

sub DESTROY { 1 } # prevent the AUTOLOAD call

=pod

=head3 my $boolean = isObject( $x );

ref() can be used to tell a lot, but not if it is an object
(directly). That is, the check is more difficult if it is an object
than if it is a HASH ref. This makes that check a little easier to
manage. It has a prototype, so you can use it as a bareword. It is
also exported by default, so it is available to all scripts that 'use'
this library.

=cut
sub isObject (@) {
  my $x = shift;
  return 0 unless ref($x);
  return 0 if ref($x) =~ /^(SCALAR|ARRAY|HASH|CODE|REF|GLOB|LVALUE)$/;
  return 1;
}


=pod

=head3 void debugPrint( $level, @message );

Given a particular debug message, print it to STDERR if the script
thinks that the user is running in some kind of 'debug' state. If the
function is called like:

    $self->debugPrint( 1, 'message' );

Then the script will output if $self->debug > 1 (or more generally,
$level).

If the function is called like:

    debugPrint 1, 'message' ;

Then the script will look for debug set in main greater than 1 (or
more generally, $level). A handy trick is to 'use Env'. Then if debug
is set in the environment, it is set in the script as well.

=cut
sub debugPrint ($@) {
  my $self = shift;
  $main::debug ||= -1;
  my ($l, @msg);
  if (isObject($self)) {
    ($l, @msg) = @_;
    return if $l > $self->{debug} || $l > $main::debug;
  } else {
    ($l, @msg) = ($self, @_);
    return if $l > $main::debug;
  }
  my $c = (caller(1))[3];
  my $d = localtime;
  print STDERR "[$d] $c: @msg\n";
}

=pod

=item void USAGE (;@) @message

Print the pod2usage for the running .pl script.
verbosity is controlled by the $debug variable in
the package namespace. Usually this isn't used
in libraries, but in scripts (where $debug would
be defined via the 'getopts' fn below.

If the user defines @messages, then that is printed
instead of pod2usage.

=cut
sub USAGE (@) {
  if (scalar @_ > 0) {
    print STDERR "@_\n";
    exit(1);
  } else {
    pod2usage({ -exitval => 1,
                -verbose => ($main::debug ? $main::debug : ($main::help ? 2 : 1)),
                -output  => \*STDERR});
  }
}

=pod

=item void getopts (@) %GetOptionsHash

A wrapper around regular Getopt::Long
argument processing. This allows syntax like:

    my ($debug, $help, $verbose, $test);
    getopts "test" => \$test;
    print "DEBUG is $debug\n";

It sets 'debug', 'verbose', 'help', 'NOEXEC'
variables + whatever you add to the list.

It probably won't work very well with 'strict'.

=cut
sub getopts (@) {
  return if $ENV{ SILI_ENV_DISABLE };
  Getopt::Long::Configure('pass_through');
  GetOptions( 'debug+'   => \$main::debug,
              'help'     => \$main::help,
              'NOEXEC'   => \$main::noexec, # just tell us what you are going to do
              @_ );
  $main::help && USAGE;
}

=pod

=head3 boolean = __doc_defined( $documentation );

Internal function that is used to check if a bit of documentation is
'ok'. Of course, the method by which it does this is arbitrary and
capricious.

=cut
sub __doc_defined {
  return length( $_[0] ) > 5;
}


=pod

=head3 param_struct = param(name=>'name',doc=>'text',default=>'default')

A helper utility, shortcut for defining class 'parameters'. The point
of this function is to create a data structure that can be consumed by
the defineClass() function below. See those docs for more information.

This function is exported into your namespace by default.

=cut
sub param [$name:required,
           $isa,
           $required,
           $doc:__doc_defined,
           $default]
{
  return ( $name => { doc => $doc,
                      isa => $isa,
                      required => $required,
                      default => $default } );
}


=pod

=head3 struct = members( param(), param() )

Syntactic sugar for the defineClass function below. See param() and
defineClass() for more information.

This function is exported into your namespace by default.

=cut
sub members (@) {
  return @_;
}


=pod

=head3 struct = isa( qw( Type1 Type2 ) )

Syntactic sugar for the defineClass function below. See param() and
defineClass() for more information.

This function is exported into your namespace by default.

=cut
sub isa (@) {
  return isa => [ (ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_) ];
}

=pod

=head3 struct = isSome( qw( Type1 Type2 ) )

Syntactic sugar for the defineClass function below. It is actually
just a wrapper on the isa function defined previously.

This function is exported into your namespace by default.

   defineClass
     isSome => Sili::Ness,
     params( );

=cut
sub isSome (@) {
  return isa( @_ );
}


=pod

=head3 defineClass( isa => Type1, members( param(), param() ) );

Perl has a not-so-hot Object system. But - to make up for that it
exposes all the details about the object, which makes it really easy
to build your own object system in Perl. Perhaps that is why there are
so many different Perl OO implementations... So, here is another
one. The goal here is to use the building blocks in this file and the
dependent NamedFnParams libarary to do some type checking, and
standardize the OO interfaces and code generation.

The other thing that this does is defines a schema in memory of what
the class is and what objects implementing this class should conform
to. It is a little more structured than your typical Perl or OOPerl
script, but that is the point. The additional structure makes for a
different syntax (to some degree) that looks more like Python than
Perl, but all the power of Perl is still there.

As a handy side effect, it returns true. So now the declaration of a
new class is nothing more than:

    package MyClass;
    use Sili::Ness;
    defineClass
        isa => Sili::Ness,
        members( param( name => 'x',
                        doc => 'This is variable x',
                        isa => 'Some::Object',
                        required => 1),
                 param( name => 'y', doc => 'This is a variable') );

=cut
sub defineClass [$isa, $isSome] (@) {
  my $class = (caller)[0];
  my $d = gHash $class . '::__data';
  my %a = @_;
  $isa ||= $isSome;
  # handle isa specially
  my $their_isa = gArray $class . '::ISA';
  unshift @$their_isa, (ref $isa eq 'ARRAY' ? @$isa : $isa);
  delete $a{isa}; delete $_args{isa}; # generated
  while (my ($name, $h) = each %a) {
    confess "$class::defineClass - Specify docs for $name!" unless $h->{doc};
    $d->{$name} = $h;
  }
  return 1;   # means that package defs don't need to end true.
}


=pod

=head3 defineClass( );

The base class actually uses the features built up to now to define
'trace' and 'debug' variables that are part of ALL classes that use
this library.

=cut
defineClass
    param( name => 'trace',
           doc => 'set trace to be a default property',
           default => -1 ),
    param( name => 'debug',
           default => 6,
           doc => 'All objects have a debug property as well' )
    ;

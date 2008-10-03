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
=pod

=head1 NAME

Sili::NamedParams - Use named parameters as input to a subroutine

=head1 DESCRIPTION

In the CONCLUSION of the perlfilter perldoc, there is a description
of how to generate prototypes for perl subroutines based on named
arguments to that subroutine. This is an implementation of that.

It came about because of successes that I have seen with defaulting
to named parameters in perl and how it:

=over 4

=item *

Increases readability

=item *

Can be extremely extensible

=item *

Is actually nice to type-check perl vars

=item *

Makes it easier to do modular perl progamming and larger systems

=back

=head1 SUPPORTED SYNTAX

All named variables must occur between the NAME and the opening '{' bracket
for a subroutine. For example:

  sub t [ $str="default",
          $x:required ]  {
      print "t: $str\n" if $x;
  }

creates a subroutine that has 2 arguments, 'str' and 'x'. The calling syntax
has to be:

    t( x => 1 );

Or

    t( x => 1, str => "Not Default" );

The 'x' is required, and the str has a default value being set.

=head2 CLOSURES

This works on anonymous subroutines too. (Square Brackets are required.)

=head2 SQUARE BRACKETS

The square brackets around the named arguments are optional in the case of
named subroutines. They are required for anonymous subroutines.

=head2 DEBUG

Turn on debugging with:

  use NamedFnParams debuglevel => $debug_level || 1,
                    debugOutput => './sourceFilterTest.output';

For example. That will create a file called ./sourceFilterTest.output
which will contain all the expansions. Increase verbosity by increasing
the debug level. NOTE - level 1 will preserve line numbers. Anything
greater than that, and any error message line numbers will most likely
NOT line up correctly in the generated source files.

=head1 DISCLAMER

This is a source filter. Source filters are EVIL. That said, this one is
fairly useful, and strives to give some feedback to the dev via debug
when possible. It also makes an effort to preserve generated code line
numbers so that error messages match the source code.

Also, the tokenization mechanism isn't a full blown implementation. To
keep it brief, there is a simple, regexp based tokenization system that
might not always be right. When in doubt, use the '[]' in your code.

To turn on debugging set NFP_DEBUG to an integer level in the environment.
The higher the level, the more parsing information you will get out. At
debug level = 1, the line numbers all remain correct, above that, all
bets are off.

=head1 TODO

It would be great to have a "doc-mode" that would generate
the pod docs for any class that implements this filter.
=cut

package Sili::NamedParams;
use Filter::Simple;
use Data::Dumper;
use Carp;
use IO::File;

sub SIGIL () { 0 };
sub NAME  () { 1 };
sub META  () { 2 };

{
  my $__debugging = 0;
  my $__debug_fh = undef;
  sub setDebuggingOn {
    my ($level, $file) = @_;
    return unless $level && $file;

    $__debugging = $level;
    $__debug_fh = new IO::File ">$file" || confess "unable to open debug output: $file: $!";
  }
  sub debugPrint {
    my $level = shift;
    print $__debug_fh "@_\n" if defined $__debug_fh && $__debugging >= $level;
  }
  sub nl () { return ($__debugging > 1 ? "\n" : ' ') }
}


#FILTER_ONLY executable_no_comments => sub {
FILTER {
  my ($self, %options) = @_;
  my $code = $_;
  my $ret = ''; my $match = '';
  my $start = 0; my $end = 0;
  my $caller = (caller(1))[0]; $caller =~ s/:+/_/g;

  # debugging defaults
  $options{ debuglevel } ||= $ENV{ NFP_DEBUG };
  $options{ debugOutput } ||= "/tmp/$caller.debug";
  setDebuggingOn( $options{ debuglevel }, $options{ debugOutput } );
  debugPrint( 3, "# OPTIONS: ", Dumper(\%options) );

  while ( $code =~ m! sub \s+ (\w*) \s* ( \(.+\) | [^{]* ) \{ !msx ) {
      
    $ret .= $`; $code = $'; #'

    # match now contains 'sub <name> <description>' {
          
    my ($name, $description) = ($1, $2);
    my $description_lines = 0; $description_lines++ while ( $description =~ /[\n\r\f]/g );

    # simplify the description
    my ($prototype, $proto_found);
    if ($description =~ s/\((.+)\)//) {
      $proto_found = 1;
      $prototype = $1;
    } else {
      $proto_found = 0;
      $prototype = '@';
    }

    $description =~ s/^\s*//; $description =~ s/\s*$//; #trim
    $description =~ s/^\[\s*//; $description =~ s/\s*\]$//; #trim optional brackets
    $description =~ s/[\r\n\f]+/ /g; # remove line breaks
    $description =~ s/,\s+/,/g; # make comma the elem delim
    $description =~ s/\s+/,/g;  # make comma the elem delim
    $description =~ s/\#,*.*?,//g; # comments in the args

    chomp($description);

    # convert the string into an @argv struct
    my @d = split /,/, $description;
    my @argv = ();
    for my $d (@d) {
      debugPrint( 3,  "# ARGV: $d" );
      $d =~ /^(.{1})(\w+)(.*)/;
      push @argv, [ $1, $2, ($3 ? $3 : undef) ];
    }

    # decide whether this fn has specified @argv
    if ($description) {
      $ret .= "sub $name ($prototype) { " . nl;
      $ret .= "my \$self = shift; " . nl if $options{ classes };
    } elsif ( $proto_found ) {
      $ret .= "sub $name ($prototype) { ";
      next;
    } else {
      $ret .= "sub $name { ";
      next;
    }
  
  $name ||= '__ANON__';
  $ret .= "my \%_args = \@_; confess 'syntax error (named arguments required, but not provided: (' . \"\@_\" . ')) in call to $name' if scalar \@_ \% 2 != 0; " . nl;

    debugPrint( 2, "# $name DESCRIPTION ($description_lines) [$description]" );
    debugPrint( 3, "# $name ARGV ARRAY ", Dumper( \@argv ) );

    # build the variables defined in the description.
    # Allow directives to be specified on multiple lines, I.e. dupes
    my %cache = ();
    for my $arg (@argv) {
      my $varName =  $arg->[SIGIL] . $arg->[NAME];
      my $aName = $arg->[NAME];

      if ( ! exists $cache{ $varName } ) {
        $ret .= " my ". $varName . " = \$_args{" . $arg->[NAME] . "};" . nl;
      }
      $cache{ $varName } = 1;

      if ($arg->[META]) {

        # quick tokenize the META string
        # uses whitespace as the delimiter
        # which is guaranteed by the $description 'simplification' above
        $arg->[META] =~ s/(:|=)/ $1 /g;
        $arg->[META] =~ s/^\s*//; $arg->[META] =~ s/\s*$//;
        my @tokens = split /\s/, $arg->[META];

        debugPrint( 2, "# $name TOKENS $varName -> [@tokens]" );

        while (my $tok = shift @tokens) {
          next unless $tok;

          if ( $tok eq '=' ) {
            $ret .= "$varName = ( $varName ? $varName : " . shift( @tokens ) . ' ); ' . nl;

          } elsif ( $tok eq ':' ) {
            my $tag = shift @tokens;

            if ( $tag =~ /^req.*/i ) {
              $ret .= " confess \"param:$aName is required in call to $name\" unless defined $varName; " . nl;

            } elsif ( $tag =~ /^isa(.+)/i ) {
              my $match = $1; $match =~ s!/!::!g;
              $ret .= " confess 'param:$aName in call to $name\(\) is required to be a \"$match\"' if defined $varName && ! UNIVERSAL::isa(" .$varName . ", \"$match\"); " . nl;

            } elsif ( $tag =~ /^(HASH|CODE|ARRAY|SCALAR|GLOB|REF)/i ) {
              $ret .= " confess 'param:$aName in call to $name\(\) is required to be of ref type: \"$1\"' if defined $varName && ref(" .$varName . ") ne '$1'; " . nl;

            } else {
              $ret .= " confess 'param:$aName in call to $name\(\) failed $tag\(\) validation.' if defined $varName && not $tag(" .$varName . "); " . nl;

            }

          } else {
            $ret .= "; " . nl;
          }
        }
      }
    }

    # fill in white space for the debugging line print
    for (my $i = 1; $i <= $description_lines; $i++) {
      $ret .= "# debug lines filler - keeps line count correct.\n";
    }
  }

  $ret .= $code;
  debugPrint(1, $ret );
  close(F);

  $_ = $ret; # this is the return call.
}



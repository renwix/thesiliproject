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

package Sili::C;

=pod

=head1 NAME

Sili::C - The Sili Compiler

=head1 DESCRIPTION

Depending on the compiler there is somewhere between 2 and 7 "phases"
that it runs through during the compilation process. Add
pre-processors to the list and there is 1 "potential" phase it might
run through. If we recognize that the number is a hardcode/design
decision and abstract it to "N" phases, the we get the Sili::C
compiler.

It is basically an array of function pointers where each function is a
"phase" of the compilation process. In order to make this work, the
AST is passed to each phase in the form of Sili::Ness meaning that
Sili::Q can be used to inspect the AST. That in turn means that each
phase doesn't necessarily have to know the structure of the underlying
Sili::Ness tree (the AST) and that makes them more reusable. Given
this, it is really in the developer's best interest to make small
special purpose AST inspection tools, potentially with side effects,
and combine them to create compiler blocks or composite phases. That
means that we are dealing with primarily a data hierarchy problem,
which, Sili::Ness is particularily good at representing. Confusing?

Additionally, when the phase is executed, since the phase is also a
Sili::Ness, it is just passed to the executing function. Or - put
another way, each phase has access to the AST and all of it's child
phases - which makes it act a lot like the Unix environment. Actually,
the code is pulled from the Unix process tree code.

=head1 USAGE

  use Sili::C;
  use Sili::NamedParams classes => 1;
  use Data::Dumper;

  my \$phase1 = new Sili::C( name => 'phase1',
                             doc => 'hello world',
                             fn => sub [\$ast] { print Dumper($self), Dumper( \$ast ) } );
  $phase1->run();

=head1 sili.pl TIEIN

This is probably the way this thing would be used in the real world,
so the idea here, is to create a SILI file with a \$silis definition
containing a list of the Sili::C's that need to get run (or a
programmatic determination of what the phases look like). Then exec it
with a C<sili -c> command which should load up that SILI file and
then exec the \$silis in order.

=cut

use Sili::Ness;
use Sili::Q;
use Sili::NamedParams classes => 1, debuglevel => 2;
use Carp;
use Data::Dumper;

defineClass  # Sili::C
    isa => 'Sili::Ness',
    param( name => 'name',
           doc => 'The Name of the Sili::C phase.',
           required => 1 ),
    param( name => 'doc',
           doc => 'Some documentation about the phase.',
           required => 1 ),
    param( name => 'children',
           doc => 'Child Sili::C phases that should be processed.',
           default => [] ),
    param( name => 'fn',
           doc => 'The name of the function that should be executed. CODE actually works too, but that is not Storable, and is not recommended.',
           required => 1 ),
    param( name => 'permissive',
           doc => 'If set, then @failures are returned, otherwise - a run failure is CONFESSed. Defaults to CONFESSed.',
           default => 0 ),
    param( name => '_failed_cnt',
           doc => 'Number of times the phase has tried and failed..',
           default => 0 ),
    ;

sub import [$permissive] {
  my $d = \%{*{'Sili::C::__data'}};
  $d->{permissive}->{default} = $permissive;
}

sub addChild  {
  my $self = shift;
  for my $p (@_) {
    CONFESS $p->name . " is not a Sili::C!"
        if ref($p) ne 'Sili::C';
    push @{ $self->{children} }, $p;
  }
}

sub hasChild {
  my ($self, $name) = @_;
  return query_by_key( key => 'name',
                       match => $name,
                       list => $self );
}

sub run [$ast:ARRAY] {
  # setup
  debugPrint( 2, "processing: ", $self->name, " permissive = " .
              $self->permissive || $Sili::C::PERMISSIVE );
  my @failures = (); my $res = 0; my $fn;
  if ( ref( $self->fn ) eq 'CODE' ) {
    $fn = $self->fn;
  } else {
    $fn = $self->can( $self->fn );
  }
  CONFESS "Phase not defined for ", ref($self), "->", $self->name
      unless $fn;
  $ast ||= [];

  # exec the fn pointer and watch for errors.
  eval {
    $res = $fn->( $self, ast => $ast );
  }; if ($@ || $res) {
    if ($self->permissive || $Sili::C::PERMISSIVE) {
      $self->debugPrint(1, "Error: " . $self->name .
                        " $@ ... will attempt 1 delay.\n" . Carp::longmess );
      $self->_failed_cnt( $self->_failed_cnt + 1 );
      push @failures, $self;
    } else {
      CONFESS "Failed to run " . $self->name . ": $@";
    }
  }

  # exec the children in order.
  for my $child (@{ $self->children}) {
    push @failures, grep { defined } ($child->run( ast => $ast ));
  }
  if (scalar @failures) {
    return @failures;
  } else {
    return undef;
  }
}

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

package Sili::Q;

=pod

=head1 NAME

Sili::Q - Query language for getting Sili::Ness

=head1 DESCRIPTION

This gives a way to query the Sili objects. Since they will be layed
out in a tree hierarcy, a recursion down the tree is all that is
needed to locate a particular node(s). This library exports the
following functions by default:

=over 4

=item *

query( $fn, @list )

=item *

query_by_type( type => 'type', list => [ @list ] )

=item *

query_by_key( key => 'keyName', match => 'value', list => [ @list ] )

=back

=cut

use Sili::NamedParams;
use Sili::Ness;
use Exporter;
use Carp;
use Data::Dumper;

@ISA = qw( Exporter );
@EXPORT = qw( query query_by_type query_by_key );


=pod

=head1 FUNCTIONS

=head2 _query

An internal function that is used to actually find and match the
objects that are being called for. It uses function prototypes ala
sort and map in order to specify the algorithm for what it means when
a Sili is "found".  The following syntax is legit and will find all DDM
objects:

  my @siliness = query { 1 } @all_siliness;

The next one will find the siliness named 'bob':

  my @siliness = query { $_[0]->name eq 'bob' } @all_siliness;

Unfortunately, when using function prototypes, the $_ variable doesn't
get set. The work around is to use declared variables, or refrence the
@_ variable position in the array that you need.

As a side note (for devs), the implementation has a manual tail-call
recursion expansion in it. A list is used to maintain state as opposed
to the perl frame stack of the recursed function calls. This is almost
verbatim out of MJD's HOP book.

=cut

sub _query {
  my $accumulator = shift;
  my $fn = shift;
  my $q = [ @_ ]; # manual tail-call impl
  for my $l (@$q) {
    debugPrint 6, "Looking at $l in ['", join "','", @$q, "']";
    if ( $fn->( $l ) ) {
      push @$accumulator, $l;
      debugPrint 6, "Found $l to match the condition";
    }
    if ( ref $l eq 'ARRAY' ) {
      push @$q, @$l;
    } elsif ( ref $l eq 'HASH' || isObject $l ) {
      push @$q, (values %$l);
    }
  }
}

=pod

=head2 query

This is a wrapper around _query that manages the accumulator; the
array cache of matching objects. Again, it takes a function used to
determine matching SILI object as defined in _query.

=cut

sub query (&@) {
  my $acc = [];
  _query( $acc, @_ );
  return @$acc;
}


=pod

=head2 query_by_type( named arguments )

Given a declared type, find all Siliness of that type:

  my @siliness_of_type = query_by_type( type => 'test',
                                    list => [ @siliness ] );



=cut

sub query_by_type [$type:required,
                   $list:required]
{
  return
    query { UNIVERSAL::isa($_[0], $type) }
          (ref $list eq 'ARRAY' ? @$list : $list );
}

=pod

=head2 query_by_key( named arguments )

Given a declared key and the value it should match, find all Siliness of
that with a key matching that value:

  my @bob_siliness = query_by_key( key => 'name',
                               match => 'bob',
                               list => [ @siliness ] );

That is another way to write the bob example in _query above.

The query_by functions make use of the NamedFnParams.pm perl
library. YYMV

=cut

sub query_by_key [$key:required,
                  $match:required,
                  $list]
{
  return
    query { exists $_[0]->{$key} && $_[0]->{$key} =~ /$match/ }
          (ref $list eq 'ARRAY' ? @$list : $list );
}

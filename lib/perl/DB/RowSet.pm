# -*- perl -*-

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

package DB::RowSet;
use Sili::NamedParams;
use DBI;

=pod

=head1 NAME

DB::RowSet - an ADO'ish syntax on DBI

=head1 EXAMPLE

   use DB::OracleHandle;
   use DB::RowSet;

   my $dbhandle = DB::OracleHandle->new(user => "$ENV{DB_USER}",
                                        password => "$ENV{DB_PASSWD}",
                                        SID => "$ENV{DB_SID}",
                                        host => "$ENV{DB_HOST}",
                                        port => "$ENV{DB_PORT}");


   my $rowset = DB::RowSet->new(dbh => $dbhandle->dbh(),
      			        sql => $this->sql());

   my %results = %{$rowset->getResults()};

   #
   # Or all as one.....
   #

   my %results = %{(DB::RowSet->new(dbh => $dbhandle->dbh(),
   			            sql => $this->sql()))->results()};


   #
   # Or use the ADO interface
   while ($rowset->next) {
       $data1 = $rowset->item(0);
       $data2 = $rowset->item('jazz');
   }

=cut

defineClass
  isa => Sili::Ness,
  param( name => "results",
         isa => "HASH",
         doc => "results returned by the SQL query" ),
  param( name => "rows",
         format => '\d+',
         doc => "number of the rows in the rowset" ),
  param( name => "fields",
         isa => "ARRAY",
         doc => "An array of field names returned by the SQL query" ),
  param( name => "dbh",
         isa => "DBI::db",
         doc => "the DBI handle for the database" ),
  param( name => "sql", 
         doc => "sql string for this rowset" ),
  param( name => "verbose",
         doc => "verbose STDERR logging of sql queries" ),
  param( name => 'i_internal',
         doc => 'Internal variable for storing the current row that is pointed to in the RowSet' ),
  param( name => 'nextCalledOnceInternal',
         doc => 'Internal variable for storing the fact that the next function has set the iterator - support for different call syntax based on 1 row in the result set and many rows in the result set.' ),
  ;
sub init {
  my $self = shift;
  $self->execute() if $self->dbh && $self->sql;
  $self->reset();
}

sub execute [$sql] {
  my $self = shift;
  $self->sql( $sql ) if $sql;
  my $results = {};
  my $debug = $self->debug();
  my $dbh = $self->dbh();
  my $stmt = $dbh->prepare($self->sql()) 
    or Confess "ERROR: preparing statement: $DBI::errstr";
  $self->debugPrint( 1, "SQL: " . $self->sql() );

  $stmt->execute or Confess "ERROR: $DBI::errstr";
  return if $self->sql =~ /^\s*(insert|update|delete)/;

  #
  # If there was a dataset returned, then load it
  #
  my (@row,$debugString);
  $results->{rows} = 0;
  $debugString = "\n";
  push @{ $results->{_fields} }, @{ $stmt->{NAME} };
  $debugString .= join( "\t", @{ $stmt->{NAME} } ) . "\n";

  while (@row = $stmt->fetchrow_array()) {
    $results->{rows}++;
    for (my $i = 0; $i < $stmt->{NUM_OF_FIELDS} ; $i++) {
      push @{ $results->{ $stmt->{NAME}->[$i] } }, $row[$i];
      $debugString .=  $row[$i] . "\t";
    }
    $debugString .= "\n";
  }

  $self->debugPrint( 2, $debugString );
  $stmt->finish;
  $self->rows( $results->{rows} );
  $self->fields( $results->{_fields} );
  $self->results( $results );
}

sub reset {
  my $self = shift;
  $self->{i_internal} = -1;
  $self->{nextCalledOnceInternal} = 0;
}

sub next {
  my $self = shift;
  $self->{nextCalledOnceInternal} = 1;
  $self->{i_internal}++;
  return ($self->{i_internal} >= $self->rows ? 0 : 1);
}

sub item {
  my $self = shift;
  $self->{i_internal} = 0 unless $self->{nextCalledOnceInternal};
  my $fieldName = shift;
  if ($fieldName =~ /^\d+$/) { # if it is a digit, lookup the field name
    $fieldName = $self->fields()->[$fieldName];
    $self->debugPrint( 1, "Derived '$fieldName' from its index in the field list" );
  }
  $self->debugPrint( 2, "getting value for $fieldName: " , 
                     $self->{results}->{$fieldName}->[$self->{i_internal}] );
  return $self->{results}->{$fieldName}->[$self->{i_internal}];
}

sub fields { return @{ $self->getFields } }

sub count  { return $self->{results}->{rows} }

# -*-perl-*-

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

package DB::DBHandle;
use Sili::NamedParams;
use DBI;

defineClass
    isa => Sili::Ness,
    param( name => "user", 
           doc=> "username for the oracle instance to connect to" ),
    param( name => "password",		  
           doc => "password for the oracle instance to connect to"),
    param( name => "host", 
           doc => "host for the oracle instance to connect to" ),
    param( name => "connectString", 
           doc => "the DBI connectstring for this db handle resource" ),
    param( name => "dbh", 
           isa => "DBI::db",
           doc => "DBI handle for this Oracle Connection" ),
    param( name => "connectString", 
           doc => "DBI connect string for call to DBI->connect()" ),
    ;

sub connect {
    my $self = shift;
    my $dbh;
    eval {
        $dbh = DBI->connect($self->connectString, ,
                            $self->user, 
                            $self->password,
                            { RaiseError => 1 });
    }; if ($@ || $DBI::errstr) {
        Confess "Failed to connect to DB: $@ : $DBI::errstr";
    }
    
    $self->dbh($dbh);
}

sub execute [$sql:required] {
    my $self = shift;
    debugPrint 3, "DBEXEC: " . $sql . "\n";
    $self->dbh()->prepare($sql)->execute()
        or CONFESS "ERROR: $DBI::errstr";
}

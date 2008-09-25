
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

use Sili::C permissive => 1;
use Sili::NamedParams classes => 1; #, debuglevel => 1;
use Data::Dumper;

sub tester {
  print "This is a test in main::tester\n";
  0;
}


my $thg1 = new Sili::C( name => 'nestedTest1',
                        doc => 'hello world',
#                        permissive => 1,
                        fn => sub [$ast:ARRAY] {
                          push @$ast, 'hi there from nested test1';
                          print Dumper($self), Dumper( $ast );
                          1;
                        } );

my $thg2 = new Sili::C( name => 'nestedTest2',
                        doc => 'hello world',
                        fn => sub [$ast:ARRAY] {
                          push @$ast, 'hi there from nested test2';
                          print Dumper($self), Dumper( $ast );
                          0;
                        } );
$thg1->addChild( $thg2 );


$silis = [
          new Sili::C( name => 'phase1',
                       doc => 'hello world',
                       fn => sub [$ast:ARRAY] {
                         push @$ast, 'hi there';
                         print Dumper($self), Dumper( $ast );
                         return 0;
                       } ),

          new Sili::C( name => 'phase2',
                       doc => 'hello world2',
                       fn => 'tester' ),

          new Sili::C( name => 'phase3',
                       doc => 'hello world2',
                       fn => 'main::tester' ),

          $thg1,
          ];


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
package Def;
use Sili::Ness;
defineClass
    isa => Sili::Ness,
    param( name => 'name',
           required => 1,
           doc => 'The name of the definition'),
    param( name => 'description',
           doc => 'The description of the definition' ),
    param( name => 'ROOT',
           doc => 'The root location on disk where the definition occurs' ),
    param( name => 'SILI',
           doc => 'A Pointer to the env definition file' ),
    param( name => 'target',
           isa => 'Target',
           doc => 'A target that can be applied to the Def' ),
    ;

package Target;
use Sili::Ness;
defineClass
    isa => Sili::Ness,
    param( name => 'name',
           doc => 'The name of the target'),
    param( name => 'command',
           doc => 'The command to run in the directory' ),
    ;

package TargetX;
use Sili::Ness;
defineClass
    isa => Sili::Ness,
    param( name => 'name',
           doc => 'The name of the target'),
    param( name => 'command',
           doc => 'The command to run in the directory' ),
    ;


package main;
use Sili::Ness;
use Env;

# usually silis wouldn't = silid... but in this case they do.
$silis = [
          new Def( name => 'sili',
                   description => 'The sili codeline',
                   ROOT => $HOME . '/wk/thesiliproject',
                   SILI => $SILID,
                   target => new Target( name => 'build',
                                         command => 'makex' )),
          new Def( name => 'tests',
                   description => 'The tests in the sili codeline',
                   ROOT => $HOME . '/wk/thesiliproject/tests',
                   SILI => $SILID ),

          new Def( name => 'compiler_test',
                   description => 'silis_c_1.pl',
                   ROOT => $HOME . '/wk/thesiliproject/tests',
                   SILI => $HOME . '/wk/thesiliproject/tests/silis_c_1.pl' ),

          ];


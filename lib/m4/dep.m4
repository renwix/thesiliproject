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

# this file extends the base "m4" language to include dependencies.
m4_changequote(<+++,+++>)
m4_changequote([,])

# the dep.m4 library "loads" itself.
m4_define([_dep_lib_loaded],[1])

# fatal errors:
m4_define([m4_fatalerror], [m4_errprint([m4: fatal error: $*
])m4_m4exit(1)])

# the code that checks dependencies.
m4_define([m4_dep],
  [m4_ifdef([_$1_loaded],[],
    [m4_pushdef([_$1_loaded],[1])[]m4_ifelse([m4_shift($*)],[],
                                     [$1],
                                     [$1(m4_shift([$*]))])])])
m4_define([m4_lib_dep],[m4_ifdef([_$1_lib_loaded],,[m4_pushdef([_$1_lib_loaded],[1])m4_include($1.m4)])])

m4_define([GLOBAL_VAR],
  [m4_ifelse($#,1,
    [_GLOBAL_$1],
    [m4_pushdef([_GLOBAL_$1],
      [$2])])])

# a global variable can be a requirement for a macro. Without it, a fatalerror occurs.
# If the global is defined, then return the value, if not, then fatalerror.
m4_define([m4_req],
[m4_ifdef([_GLOBAL_$1],
  [GLOBAL_VAR($1)],
  [m4_fatalerror([You need to define $1 with [GLOBAL_VAR($1)]])])])


#  [m4_ifelse($#,1,
#    [m4_ifdef([_GLOBAL_$1],,
#      [m4_fatalerror(You need to define $1 with [GLOBAL_VAR($1)])])],
#      [GLOBAL_VAR($1, $2)])])

# test cases
m4_define([DEP_COMMENTS], [These are some test comments])
m4_define([DEP_DEPENDENCY_TEST], [m4_dep([DEP_COMMENTS])])
m4_define([_DEP_TEST],[
DEP_DEPENDENCY_TEST
DEP_DEPENDENCY_TEST
dep is loaded: _dep_lib_loaded
])


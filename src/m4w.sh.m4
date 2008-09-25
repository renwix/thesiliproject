<: # -*-sh-*-

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

use Helpers::shell;
print Helpers::shell::shellScript(suppressChangeQuote => 1); 

# this script has access to the build/compile time m4 make macros
:>

#
# You can further influence the m4 command by specifying M4_FLAGS or M4_DEBUG
# in the environment to this command, or by passing it as an argument to this
# command. Anything the user specifies, comes before the defaults in the pathing.
# 
# This script processes stdio. That is, it just hands its input/output/error to
# the m4 process. 
#

M4_FLAGS="$M4_FLAGS -I[]PKG_LIB -I[]PKG_LIB/m4 -I[]PKG_LIB/shell -I[]PKG_LIB/db"

#
# This is required during the initial install phase. If the source directories
# exist, then they are included. From that point on, this should be harmless,
# but there might be an issue here or there when generating a file from .m4 to non,
# if the ../lib directory exists in the dir where the .m4 conversion happens,
# and there are m4 files there with the same name as the required libs
# and the required libs aren't in the path in front of this command
# and the required libs polute/collide/manipulate quotes in a way that the
# generated script doesn't work with.
# 
if test -d BOOTSTRAP_LIB; then
    M4_FLAGS="$M4_FLAGS -I[]BOOTSTRAP_LIB -I[]BOOTSTRAP_LIB/m4 -I[]BOOTSTRAP_LIB/shell -I[]BOOTSTRAP_LIB/db"
fi

M4_FLAGS="$M4_FLAGS -DSHELL=SHELL -DM4=M4 -DPKG_LIB=PKG_LIB -DPKG_TEMPLATES=PKG_TEMPLATES -DVERSION=VERSION"
M4_FLAGS="$M4_FLAGS -DPKG_BIN=PKG_BIN"


echo M4 ${M4_FLAGS} -DPRINTDASHN=\'PRINTDASHN\' ${M4DEBUG} --[prefix]-builtins 1>&2

M4 $* ${M4_FLAGS} -DPRINTDASHN="PRINTDASHN" ${M4DEBUG} --[prefix]-builtins

#
# Emacs Block
#
# Local Variables:
# mode: shell-script
# End:

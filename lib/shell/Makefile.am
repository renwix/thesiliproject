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

include $(top_srcdir)/autofiles/bootstrap.mk

TRANSFORM = $(top_srcdir)/lib/shell/transform.sh

relativePath = $(shell tmp=`cd $(top_srcdir); pwd`; pwd | perl -ple "s,$$tmp,,")

test_rule ::; @echo "relativePath is $(relativePath) top_srcdir is $(top_srcdir)"

srcFiles=absolutePathTest.src checkfile.src cleanup.src docmd.src docmdi.src docmdq.src docmdqi.src filesize.src lock.src printmsg.src require.src sshcommand.src
shFiles=$(patsubst %.src, %.sh, $(srcFiles))
HDshFiles=$(patsubst %.src, HD%.sh, $(srcFiles))
absPathSrcFiles=$(patsubst %.src, $(top_srcdir)/lib/shell/%.src, $(srcFiles))
HD%.sh %.sh	:	%.src
	cp $< $@
	cat $< | $(TRANSFORM) > HD$@

shellSnippets.m4 :
	cat $(absPathSrcFiles) > $@

$(shFiles) $(HDshFiles) :: $(srcFiles)
showfiles :; echo src=$(srcFiles) sh=$(shFiles) HDsh=$(HDshFiles)

bindir=$(pkgdatadir)$(relativePath)
bin_SCRIPTS = $(shFiles) $(HDshFiles) shellSnippets.m4
CLEANFILES = $(HDshFiles) $(shFiles) shellSnippets.m4

EXTRA_DIST = $(srcFiles) transform.sh shellScripts.m4





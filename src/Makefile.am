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

SUBDIRS = 

relativePath = $(shell tmp=`cd $(top_srcdir); pwd`; pwd | perl -ple "s,$$tmp,,")

test_rule ::; @echo "relativePath is $(relativePath) top_srcdir is $(top_srcdir)"

# SHORTNAMESCRIPTS = template keyCleaner getMD tarchive sili

# [fedora@localhost () thesiliproject]$ ls src/
# getMD         keyCleaner         m4w        Makefile     pp     sili.pl      tarchive.pl      template.pl      xfmPipe.pl
# getMD.pl      keyCleaner.pl      m4w.sh     Makefile.am  pp.pl  sili.pl.xfm  tarchive.pl.xfm  template.pl.xfm
# getMD.pl.xfm  keyCleaner.pl.xfm  m4w.sh.m4  Makefile.in  sili   tarchive     template         xfmPipe

sources = getMD.pl.xfm keyCleaner.pl.xfm template.pl.xfm tarchive.pl.xfm sili.pl.xfm m4w.sh.m4
preReqs = pp pp.pl m4w m4w.sh xfmPipe xfmPipe.pl
perlScripts = getMD.pl getMD keyCleaner.pl keyCleaner template.pl template tarchive.pl tarchive sili.pl sili

bin_SCRIPTS = $(preReqs) $(perlScripts)
CLEANFILES = pp m4w xfmPipe m4w.sh $(perlScripts)

EXTRA_DIST = pp.pl xfmPipe.pl $(sources)





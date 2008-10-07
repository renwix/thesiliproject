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

PKG_BIN         =       ${pkgdatadir}/bin
PKG_LIB         =       ${pkgdatadir}/lib
PKG_TEMPLATES   =       ${pkgdatadir}/templates
BOOTSTRAP_LIB   =       ${top_srcdir}/lib
XFMPIPE         =       perl -I$(BOOTSTRAP_LIB)/perl ${top_srcdir}/src/xfmPipe.pl
PP							=				perl -I$(BOOTSTRAP_LIB)/perl ${top_srcdir}/src/pp.pl
HELPER_DEPS			= 			$(top_srcdir)/lib/perl/Helpers/shell.pm $(top_srcdir)/lib/perl/Helpers/PerlObject.pm

PRINTDASHN      =       echo -n

export PATH            :=      ${top_srcdir}/src:$(PATH)
export PERL5LIB        :=      $(BOOTSTRAP_LIB)/perl:$(PERL5LIB)

M4_FLAGS        =       -I@abs_builddir@ \
												-I@abs_top_builddir@/lib \
												-I@abs_top_builddir@/lib/m4 \
												-I$(top_srcdir)/lib \
												-I$(top_srcdir)/lib/m4 \
												-DSHELL=$(BASH) \
												-DM4=$(M4) \
												-I$(PKG_LIB) \
												-DPKG_LIB=$(PKG_LIB) \
												-DPKG_BIN=$(PKG_BIN) \
												-DPKG_TEMPLATES=$(PKG_TEMPLATES) \
												-DBOOTSTRAP_LIB=$(BOOTSTRAP_LIB) \
												$(M4DEBUG) \
												-DPRINTDASHN="$(PRINTDASHN)" \
												-DPERL=$(PERL) \
												-DVERSION=$(VERSION)  \
												-Dprefix=$(prefix) \
												--prefix-builtins

# pmxfmfiles	= $(wildcard *.pm.xfm)
# nopmxfmfiles	= $(patsubst %.xfm,%,$(pmxfmfiles))

# plxfmfiles	= $(wildcard *.pl.xfm)
# noplxfmfiles	= $(patsubst %.xfm,%,$(plxfmfiles))

# shxfmfiles	= $(wildcard *.sh.xfm)
# noshxfmfiles	= $(patsubst %.xfm,%,$(shxfmfiles))

# shm4files	= $(wildcard *.sh.m4)
# noshm4files	= $(patsubst %.m4,%,$(shm4files))

%.pm	:	%.pm.xfm Makefile $(HELPER_DEPS)
	$(XFMPIPE) --file $< -dest $@ ; \
	if test $$? -ne 0; then echo error running $(XFMPIPE) --file $< -dest $@; exit 1 ; fi

%.pl	:	%.pl.xfm Makefile $(HELPER_DEPS)
	$(XFMPIPE) --file $< -dest $@ ; \
	if test $$? -ne 0; then echo error running $(XFMPIPE) --file $< -dest $@; exit 1 ; fi

%.sh	:	%.sh.xfm Makefile
	$(XFMPIPE) --file $< -dest $@ ; \
	if test $$? -ne 0; then echo error running $(XFMPIPE) --file $< -dest $@; exit 1 ; fi

%.sh	:	%.sh.m4 Makefile
	$(PP) < $< > $@.tmp ; \
	if test $$? -ne 0; then exit 1; fi ; \
	$(M4) $(M4_FLAGS) $@.tmp > $@ ; \
	if test $$? -ne 0; then exit 1; fi ; \
	rm -f $@.tmp ; chmod 755 $@

%	:	%.pl Makefile
	test -f $@ && chmod 755 $@ ; cp $< $@ ; chmod 755 $@

%	:	%.sh Makefile
	test -f $@ && chmod 755 $@ ; cp $< $@ ; chmod 755 $@

echoPath        :; @echo PATH is $$PATH and PERL5LIB is $$PERL5LIB



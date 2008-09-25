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

LOCAL_LIB	= $(shell sili.sh --libpath)

#
# Shell and Perl
# 
shxfmfiles	= $(wildcard *.sh.xfm)
noshxfmfiles	= $(patsubst %.xfm,%,$(shxfmfiles))
build :: $(noshxfmfiles)
clean ::; @rm -f $(noshxfmfiles)
%.sh	:	%.sh.xfm $(LOCAL_LIB)/perl/Helpers/shellHelpers.pm
	$(XFMPIPE) -file $< -dest $@

shm4files	= $(wildcard *.m4)
noshm4files	= $(patsubst %.m4,%,$(shm4files))
build :: $(noshm4files)
clean ::; @rm -f $(noshm4files)
%.sh	:	%.sh.m4 $(LOCAL_LIB)/perl/Helpers/shellHelpers.pm
	embedperl < $< > $@.tmp ; \
	$(M4) $(M4_FLAGS) < $@.tmp > $@ ; \
	rm -f $@.tmp ; \
	chmod 755 $@

cgixfmfiles	= $(wildcard *.cgi.xfm)
nocgixfmfiles	= $(patsubst %.cgi.xfm,%.cgi,$(cgixfmfiles))
build :: $(nocgixfmfiles)
clean ::; @rm -f $(nocgixfmfiles)
%.cgi	:	%.cgi.xfm $(LOCAL_LIB)/perl/Helpers/PerlScript.pm
	$(XFMPIPE) -file $< -dest $@


plxfmfiles	= $(wildcard *.pl.xfm)
noplxfmfiles	= $(patsubst %.pl.xfm,%.pl,$(plxfmfiles))
build :: $(noplxfmfiles)
clean ::; @rm -f $(noplxfmfiles)
%.pl	:	%.pl.xfm $(LOCAL_LIB)/perl/Helpers/PerlScript.pm $(LOCAL_LIB)/perl/Helpers/shellHelpers.pm
	$(XFMPIPE) -file $< -dest $@

pmxfmfiles	= $(wildcard *.pm.xfm)
nopmxfmfiles	= $(patsubst %.xfm,%,$(pmxfmfiles))
build :: $(nopmxfmfiles)
clean ::; @rm -f $(nopmxfmfiles)
%.pm	:	%.pm.xfm $(LOCAL_LIB)/perl/Helpers/PerlObject.pm $(LOCAL_LIB)/perl/Helpers/shellHelpers.pm
	$(XFMPIPE) -file $< -dest $@

#
# DB Files
# 
pkgxfmfiles	= $(wildcard *.pkg.xfm)
nopkgxfmfiles	= $(patsubst %.xfm,%,$(pkgxfmfiles))
build :: $(nopkgxfmfiles)
clean ::; @rm -f $(nopkgxfmfiles)
%.pkg	:	%.pkg.xfm
	$(XFMPIPE) -file $< -dest $@

pkbxfmfiles	= $(wildcard *.pkb.xfm)
nopkbxfmfiles	= $(patsubst %.xfm,%,$(pkbxfmfiles))
build :: $(nopkbxfmfiles)
clean ::; @rm -f $(nopkbxfmfiles)
%.pkb	:	%.pkb.xfm
	$(XFMPIPE) -file $< -dest $@

sqlxfmfiles	= $(wildcard *.sql.xfm)
nosqlxfmfiles	= $(patsubst %.xfm,%,$(sqlxfmfiles))
build :: $(nosqlxfmfiles)
clean ::; @rm -f $(nosqlxfmfiles)
%.sql	:	%.sql.xfm
	$(XFMPIPE) -file $< -dest $@


#
# Test harness
#
txfmfiles	= $(wildcard *.t.xfm)
notxfmfiles	= $(patsubst %.xfm,%,$(txfmfiles))
logtxfmfiles	= $(patsubst %.xfm,%.log,$(txfmfiles))
build	::	$(notxfmfiles)
test	::	$(logtxfmfiles)
%.t	:	%.t.xfm
	$(XFMPIPE) -file $< -dest $@

%.t.log : 	%.t
	./$< $(DEBUG) 2>$<.err


#
# all the regular rules will recurse
#
SUBDIRS = $(shell find . -type d -maxdepth 1 | cut -c3-)
test clean build ::
	@for dir in $(SUBDIRS); do \
		if test -f $$dir/Makefile; then \
			$(MAKE) -C $$dir $@ ; RC=$$? ; \
			if test $$RC -ne 0; then exit $$RC;	fi ; \
		fi ; \
	done


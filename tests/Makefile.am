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

EXTRA_DIST = $(TESTSUITE_AT) testsuite package.m4
DISTCLEANFILES       = atconfig $(check_SCRIPTS)
MAINTAINERCLEANFILES = Makefile.in $(TESTSUITE)

## ------------ ##
## package.m4.  ##
## ------------ ##

$(srcdir)/package.m4: $(top_srcdir)/configure.ac
	{                                      \
	  echo '# Signature of the current package.'; \
	  echo 'm4_define([AT_PACKAGE_NAME],      [@PACKAGE_NAME@])'; \
	  echo 'm4_define([AT_PACKAGE_TARNAME],   [@PACKAGE_TARNAME@])'; \
	  echo 'm4_define([AT_PACKAGE_VERSION],   [@PACKAGE_VERSION@])'; \
	  echo 'm4_define([AT_PACKAGE_STRING],    [@PACKAGE_STRING@])'; \
	  echo 'm4_define([AT_PACKAGE_BUGREPORT], [@PACKAGE_BUGREPORT@])'; \
	  echo 'm4_define([AT_TEST_ROOT], [@abs_top_builddir@/tests])'; \
	} >$(srcdir)/package.m4

#

## ------------ ##
## Test suite.  ##
## ------------ ##

TESTSUITE_AT = 	T-empty.at \
		siliness.at \
		silid.at

TESTSUITE = $(srcdir)/testsuite

AUTOTEST = $(AUTOM4TE) --language=autotest
$(TESTSUITE): package.m4 $(TESTSUITE_AT) $(TESTSUITE).at
	$(AUTOTEST) -I $(srcdir) testsuite.at -o $@.tmp
	mv $@.tmp $@

atconfig: $(top_builddir)/config.status
	cd $(top_builddir) && ./config.status tests/$@

clean-local:
	test ! -f $(TESTSUITE) || $(SHELL) $(TESTSUITE) --clean

check-local: atconfig atlocal $(TESTSUITE)
	$(SHELL) $(TESTSUITE)

check-full:
	FULL_TEST=1 $(MAKE) check


# Run the test suite on the *installed* tree.
installcheck-local:
	$(SHELL) $(TESTSUITE) AUTOTEST_PATH=$(exec_prefix)/bin


## ------------ ##
## genfile      ##
## ------------ ##

# check_PROGRAMS = genfile

# genfile_SOURCES = genfile.c argcv.c argcv.h

# localedir = $(datadir)/locale
# INCLUDES = -I$(top_srcdir)/lib -I../lib -I$(top_srcdir)/src
# AM_CPPFLAGS = -DLOCALEDIR=\"$(localedir)\"
# LDADD = ../lib/libtar.a $(LIBINTL) $(LIB_CLOCK_GETTIME)

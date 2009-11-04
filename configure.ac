
define([THIS_PACKAGE_NAME],[theSiliProject])
define([THIS_PACKAGE_BUGREPORT],[jimrenwick@gmail.com])
define([THIS_PACKAGE_TARNAME],[theSiliProject])
define([THIS_PACKAGE_VERSION],[0.01])
define([THIS_PACKAGE_PREFIX],[/usr/local])

dnl $1:script to run, $2: external directory
AC_DEFUN([EXTERNAL_SCRIPT],
[AC_MSG_CHECKING([external script $1])
# dnl might should be AC_CONFIG_COMMANDS?
(cd $2; ./$1 > $1.res 2>&1);
if test $? -ne 0; then
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([The external script $1 failed to execute correctly. Look at $2/$1.res])
else
  AC_MSG_RESULT([yes])
fi])


AC_INIT(THIS_PACKAGE_NAME,THIS_PACKAGE_VERSION)

AM_INIT_AUTOMAKE

AC_PREFIX_DEFAULT([THIS_PACKAGE_PREFIX/THIS_PACKAGE_NAME])

# things we use a lot that are probably safe to check for...
AC_PATH_PROG([M4],[m4])
AC_PATH_PROG([ECHO],[echo])
AC_PATH_PROG([PERL],[perl])
AC_PATH_PROG([BASH],[bash])
AC_PATH_PROG([MAKE],[make])
AC_PATH_PROG([MAKEINFO],[makeinfo])
AC_PATH_PROG([WGET],[wget])

AC_DEFUN([MY_ARG_WITH],
[AC_ARG_WITH([$1],
             AC_HELP_STRING([--with-$1], [use $1 (default is $2)]),
             ac_cv_use_$1=$withval, ac_cv_use_$1=no)
AC_CACHE_CHECK(whether to use $1, ac_cv_use_$1, ac_cv_use_$1=$2)])

AC_DEFUN([MY_ARG_ENABLE],
[AC_ARG_ENABLE([$1],
             AC_HELP_STRING([--enable-$1], [use $1 (default is $2)]),
             ac_cv_use_$1=$enableval, ac_cv_use_$1=$2)
AC_CACHE_CHECK(whether to use $1, ac_cv_use_$1, ac_cv_use_$1=$2)])


AC_MSG_CHECKING([for GNU m4])
${M4} --help >/dev/null 2>&1
if test $? -ne 0; then
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([make sure GNU m4 is picked first in your path])
else
  AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for GNU make])
${MAKE} --help >/dev/null 2>&1
if test $? -ne 0; then
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([make sure GNU make is picked first in your path])
else
  AC_MSG_RESULT([yes])
fi

AC_MSG_CHECKING([for working echo -n])
for x in /bin/echo /usr/bin/echo /usr/ucb/echo echo; do
    lines=`$x -n | wc -l` > /dev/null 2>&1
    if test $lines -eq 0 -a $? -eq 0 ; then
       PRINTDASHN="$x"
       AC_MSG_RESULT([${PRINTDASHN}])
       break
    fi
done

dnl MAKEINFO_REQUIRED_VERSION=4.2
dnl AC_MSG_CHECKING([for texinfo version >= ${MAKEINFO_REQUIRED_VERSION}])
dnl makeinfoVersion=`${MAKEINFO} --version | awk 'NR == 1 && $NF >= '${MAKEINFO_REQUIRED_VERSION}' {print $NF}'`
dnl if test -z "${makeinfoVersion=}"; then
dnl   AC_MSG_RESULT([no])
dnl   AC_MSG_ERROR([You need texinfo version >= ${MAKEINFO_REQUIRED_VERSION} .... See http://www.gnu.org/software/texinfo/])
dnl else
dnl   AC_MSG_RESULT([yes])
dnl fi

if test -z "$PRINTDASHN" ; then
   AC_MSG_ERROR([could find not an echo that understands the -n flag])
fi

AC_SUBST(PRINTDASHN)

AC_DEFUN([AC_CHECK_PERL_MODULES],[dnl
AC_MSG_CHECKING([for perl module $1])
$PERL -M$1 -e exit >/dev/null 2>&1
if test $? -ne 0; then
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([Run "$PERL -MCPAN -e 'install $1'", and then re-run configure])
else
  AC_MSG_RESULT([yes])
fi
])


dnl MY_ARG_ENABLE([xml], [no])
dnl test "x$ac_cv_use_xml" = "xyes" && {
dnl AC_CHECK_PERL_MODULES(XML::XPath)
dnl AC_CHECK_PERL_MODULES(XML::Simple)
dnl }
dnl 
dnl MY_ARG_ENABLE([maintainer], [no])
dnl test "x$ac_cv_use_maintainer" = "xyes" && {
dnl AC_CHECK_PERL_MODULES(WWW::Mechanize)
dnl AC_CHECK_PERL_MODULES(Log::Log4perl)
dnl }



dnl This will run the external scripts by default - disable with --disable-ext-scripts



# this is convienent for genning this statement:
# f Makefile.am | grep -v '~' | cut -c3- | sed -e 's/.am//g' | tr "\n" " " | perl -nle 'print "AC_CONFIG_FILES([$_])";'
AC_CONFIG_TESTDIR(tests)
AM_MISSING_PROG([AUTOM4TE], [autom4te])
AC_CONFIG_FILES(tests/Makefile tests/atlocal)


AC_CONFIG_FILES(src/Makefile lib/perl/DB/Makefile lib/Makefile Makefile lib/make/Makefile lib/perl/Makefile lib/m4/Makefile lib/perl/Sili/Makefile)


AC_OUTPUT



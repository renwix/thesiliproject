m4_dnl gpl
m4_dnl 
m4_dnl  Author: Renwix (renwix@gmail.com)
m4_dnl  Maintainer: Renwix
m4_dnl  Copyright (C) 2008 Renwix, all rights reserved.
m4_dnl  Created: Tue Sep 23 23:52:17 MDT 2008
m4_dnl 
m4_dnl 
m4_dnl=======================================================================
m4_dnl 
m4_dnl This file is part of theSiliProject, a humorous software organization,
m4_dnl design and development toolkit.
m4_dnl 
m4_dnl theSiliProject is free software: you can redistribute it and/or modify
m4_dnl it under the terms of the GNU General Public License as published by
m4_dnl the Free Software Foundation, either version 3 of the License, or
m4_dnl (at your option) any later version.
m4_dnl 
m4_dnl theSiliProject is distributed in the hope that it will be useful,
m4_dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
m4_dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
m4_dnl GNU General Public License for more details.
m4_dnl 
m4_dnl You should have received a copy of the GNU General Public License
m4_dnl along with theSiliProject. If not, see <http://www.gnu.org/licenses/>.
m4_dnl 
m4_dnl=======================================================================
m4_dnl 
m4_dnl /gpl
m4_changecom(`##')m4_dnl
#! SHELL
#
m4_include(m4/base.m4)
PROGNAME=${0##*/}
TMPFILE=/tmp/${PROGNAME}.$$

if [[ -n "${DEBUG}" ]]; then	
	set -x
fi

m4_ifelse(SHELL,/bin/bash, PSCMD="ps axc" , PSCMD="/bin/ps -eL") 

m4_define([_shell_include],[
m4_changequote(<++,++>)m4_dnl
m4_include(shell/$1<++++>.sh)
m4_changequote([,])m4_dnl
])m4_dnl

m4_define([shell_load_functions],[
m4_foreach([X],($*),[_shell_include(X)])
])m4_dnl

m4_define([shell_exit_handler],[
LOCALCLEAN=true
localclean [(][)] {
    rm -f /tmp/${PROGNAME}.$[]$[]*
    $*
}
])m4_dnl


m4_divert(-1)

m4_define([_checkLeadingDash], [m4_ifelse(m4_substr($1, 0, 1), -, 
						1, 
						0)])

m4_define([_chopLeadingDash], [m4_ifelse(_checkLeadingDash($1), 1, 
					m4_substr($1, 1), 
					$1)])


m4_define([_chopLeadingDashAddRightParen],[_chopLeadingDash($1)[)]])

m4_define([_switchCase], [
	_chopLeadingDashAddRightParen($1) export _chopLeadingDash($2)=TRUE;;])

m4_define([_variableCase], [
	_chopLeadingDashAddRightParen($1) export _chopLeadingDash($2)=$OPTARG;;])


m4_define([_getOptsString], [m4_ifelse(_checkLeadingDash($1), 0, 
					$1:, 
					_chopLeadingDash($1))])

m4_define([_caseElem], [m4_ifelse(_checkLeadingDash($1), 0, 
				_variableCase($1, $2),
				_switchCase($1, $2))])

m4_define([_shellUsageAtom],[-_chopLeadingDash($1) {_chopLeadingDash(m4_ifelse(_checkLeadingDash($1), 1, $2=TRUE, $2))} ])

m4_define([_arg2],[_chopLeadingDash($2)] )

m4_define([_addSpace],[$* ])

m4_define([_echoIfPrecededByDash],[m4_ifelse(m4_index($2, [-]), -1,,[_addSpace(_chopLeadingDash($2))])])

m4_define([_requireIfPrecededByDash],[m4_ifelse(m4_index($2, [-]), -1,,
test -z "${[_chopLeadingDash($2)]}" && {
	printmsg missing value for _chopLeadingDash($2)
	usage
}
)])

# _setDefaults is simple, if there is a $3, then set $2 to it before processing arguments
m4_define([_setDefaults],[
m4_ifelse($3,,,
if test -z "$[]_chopLeadingDash($2)"; then
    _chopLeadingDash($2)=$3
fi
)
])

m4_define([_usageDefaults],[m4_ifelse($3,,,printmsg _chopLeadingDash($2) defaults to \"$3\" if not specified on the command line
)])

m4_define([_printPickLists2],[ ]$1)

m4_define([_printPickLists],[m4_ifelse($4,,,printmsg _chopLeadingDash($2) must be one of the following :[]m4_foreach([X], $4, [_cat([_printPickLists2],(X))])
)])

m4_define([_validatePickLists2],"$[]$2" != "$1" -a )

m4_define([_validatePickLists],[m4_ifelse($4,,,
if test -n "$[]_chopLeadingDash($2)"; then 
  if test m4_foreach([X], $4, [_cat([_validatePickLists2],(X,_chopLeadingDash($2)))]) 1 -eq 1; then 
	printmsg $_chopLeadingDash($2) is not a valid value for _chopLeadingDash($2)
	usage
  fi
fi
)])

# ###################################################################
# shellArgs((c, $CONNECTSTRING), (n, NAME))
# This gens the case statement and the usage statement
# for the args that are passed in.
# NOTE:
# If you pass in a ]$] as part of the variable name, the generated
# code will set = $OPTARG, if no ]$] then it sets it =TRUE
#
# a dash before the flag means a value is assigned
#

m4_define([shell_getopt],[

usage () {
  printmsg  I am unhappy ...... a usage message follows for your benefit
  printmsg  Usage is m4_foreach([X], ($@), [_cat([_shellUsageAtom], X)])
m4_define([requiredVariables],m4_foreach([X], ($*), [_cat([_echoIfPrecededByDash], X)]))
m4_ifelse(requiredVariables,,printmsg command can be run with no arguments if one choses,printmsg  Required variables: requiredVariables)
m4_for(($*),[_usageDefaults])
m4_for(($*),[_printPickLists])
  cleanup 1
} 

OPTIND=0
while getopts :m4_for(($*), [_getOptsString]) c 
    do case $c in        m4_for(($*), [_caseElem])
	:[)] printmsg $OPTARG requires a value
	   usage;;
	\?[)] printmsg unknown option $OPTARG
	   usage;;
    esac
done

m4_for(($*),[_setDefaults])
m4_for(($*),[_validatePickLists])

m4_foreach([X], ($*), [_cat([_requireIfPrecededByDash], X)])

])

m4_define([setOptList],[
m4_pushdef(optList,flagval(($*),optList))
])

m4_define([shell_getopt1.1],[

setOptList($*)

optList
delist[]optList

])

m4_define([shellGetopt],[m4_dnl
m4_pushdef(macroVersion,flagval(($*),macroVersion))
macroVers[]ion is macroVersion
m4_ifelse(macroVersion,,shell_getopt($*),
	m4_ifelse(macroVersion,macroVersion,
		m4_indir(shell_getopt1.1,$*),
		[fatal_error(unknown version macroVersion passed to [shellGetopt()])]
		)
	)
m4_popdef(macroVersion)
])

m4_divert[]

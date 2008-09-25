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

package Helpers::ssh;

use Carp;
use Helpers::shell;
use File::Basename;


1;

sub nl { print "\n"; }

sub moduleName {
    my $ret; 
    $_= basename(`pwd`); 
    chomp; 
    $ret .= $_;
    return $ret;
}

sub sshShellScript {
  my $ret; my %arg = @_;
  my $arg = { %arg };
  $ret .= Helpers::shell::shellScript(getopts => "(h, -host),(u, -user)" . ($arg->{getopts} ? "," . $arg->{getopts} : ""),
                                      r => $arg->{r},
                                      suppressChangeQuote => true);
  $ret .=  q(printmsg spawning SSH here doc: $SSHCOMMAND ${user}@${host});$ret .= "\n";
  $ret .=  q($SSHCOMMAND -l ${user} ${host} <<EOF );$ret .= "\n";
  $ret .=  q(shell_load_functions(HDprintmsg,HDcleanup,HDrequire,HDfilesize,HDdocmd,HDcheckfile,HDdocmdi));$ret .= "\n";
  unless ($arg->{suppressChangeQuote}) {
    $ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
  }
  if ($arg->{p4}) {
    $ret .= "export P4USER=\$P4USER\n";
    $ret .= "export P4CLIENT=\$P4CLIENT\n";
    $ret .= "export P4PASSWD=\$P4PASSWD\n";
    $ret .= "export P4PORT=\$P4PORT\n";
  }	
  return $ret;
}

sub sshScriptOnly {
  my $ret; my %arg = @_;
  my $arg = { %arg };
  $ret .=  q(printmsg spawning SSH here doc: $SSHCOMMAND ${user}@${host});$ret .= "\n";
  $ret .=  q($SSHCOMMAND -l ${user} ${host} <<EOF );$ret .= "\n";
  $ret .=  q(shell_load_functions(HDprintmsg,HDcleanup,HDrequire,HDfilesize,HDdocmd,HDcheckfile,HDdocmdi));$ret .= "\n";
  unless ($arg->{suppressChangeQuote}) {
    $ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
  }
  return $ret;
}

sub endSshShellScript {
  my (%arg) = @_;
  my $ret; 
  $ret .=  q(EOF);$ret .= "\n";
  $ret .=  q();$ret .= "\n";
  $ret .=  q(RC=$?);$ret .= "\n";
  $ret .=  q(if test $RC -ne 0; then);$ret .= "\n";
  $ret .=  q(    cleanup $RC remote command failed);$ret .= "\n";
  $ret .=  q(fi);$ret .= "\n";
  $ret .=  q();$ret .= "\n";
  unless ($arg{suppressCleanup}) {
    $ret .=  q(cleanup 0);$ret .= "\n";
  }
  return $ret;
  
}

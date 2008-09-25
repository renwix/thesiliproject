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

package Helpers::shell;
use File::Basename;
use Carp;

sub moduleName {$_= basename(`pwd`); chomp; return $_}

sub shellScript {
    my $ret; my %arg = @_;
    my $arg = \%arg;
    $ret .= q(m4_define(`SHELL',/bin/bash)m4_dnl ` -*-shell-script-*-);$ret .= "\n";
    $ret .= q(m4_include(shell/shellScripts.m4)m4_dnl);$ret .= "\n";
    $ret .= q(shell_load_functions(printmsg,cleanup,require,filesize,docmd,docmdi,checkfile,sshcommand));$ret .= "\n";
    $ret .= q();$ret .= "\n";
    $ret .= q(unset QUIET);$ret .= "\n";
    if (exists $arg->{getopts}) {
        $ret .= qq(shell_getopt($arg->{getopts}));$ret .= "\n";
    }
    unless ($arg->{suppressChangeQuote}) {
	$ret .=  q(m4_changequote(!*!,*!*));$ret .= "\n";
    }
    map { $ret .= "require $_\n" if $_ } (@{$arg->{r}}) ;
    $ret .= "\n";$ret .= "\n";
    return $ret;
}

sub _generatedTemplateName {
    my ($t);
    ($t = $_[0]) =~ s/\.xfm$//;
    return $t;
}

sub _scpCopy {
    my ($src, $destination) = @_;
    $src = _generatedTemplateName($src);
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $src \$user\@\$host:$destination/$src\n";
}

sub _scpCopyReName {
    my ($src, $destination) = @_;
    $src = _generatedTemplateName($src);
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $src \$user\@\$host:$destination\n";
}

sub _scpGet {
    my ($src, $destination) = @_;
    return "docmd scp -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey \$user\@\$host:$src $destination/\n";
}

sub _sshmkdir {
    my ($destination) = @_;
    return "docmd ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey \$user\@\$host \"mkdir -p $destination\"\n";
}


sub printmsg {
    my $o =<<'EOF';
use File::Basename;

sub printmsg (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$) @_.\n" ;
}

sub printmsgn (@) { 
    my $date = localtime;
    print STDERR $date . ":" . basename($0) . ":($$) @_\n" ;
}

EOF

}

sub docmd {
    my $o =<<'EOF';
use Carp;

sub docmd (@) {    
    printmsg "@_" ;
#    system(@_);

    my $pid = open (CHILD, "@_ |") || CONFESS "unable to open a pipe for command @_";
    my @stdout = <CHILD>;
    my $ret = close(CHILD);

    my $rc;
    if ($? == -1) {
        $rc = -1; printmsg "failed to execute: $!";
        exit $rc;
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        printmsg "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump";
        exit $rc;
    }
    else {
        $rc = $? >> 8;
        if ($rc || ! $ret) {
            print STDOUT @stdout;
            printmsg "child process exited with value $rc - Exiting!";
            exit $rc || $ret;
        }
    }
    return @stdout;
}
EOF

}


sub docmdi (@) {
    my $o =<<'EOF';
sub docmdi {
    
    #
    # Usually, with this one, we only care about the print statements if debug is turned on.
    # 
    my $printmsg;
    use UNIVERSAL qw(can);
    if (can('main', 'debugPrint')) {
        $printmsg = sub { debugPrint( 1, @_ ) };
    } else {
        $printmsg = \&printmsg;
    }

    $printmsg->( "@_" );
#    system(@_);

    my $pid = open (CHILD, "@_ |") || CONFESS "unable to open a pipe for command @_";
    my @stdout = <CHILD>;
    my $ret = close(CHILD);

    my $rc = 0;
    if ($? == -1) {
        $rc = -1; $printmsg->( "failed to execute: $!" );
    }
    elsif ($? & 127) {
        $rc = $? & 127;
        $printmsg->( "child process died with signal $rc, ", ($? & 128) ? 'with' : 'without', " coredump" );
    }
    else {
        $rc = $? >> 8;
        if ($rc || ! $ret) {
            $printmsg->( "child process exited with value $rc - ignoring" );
        }
    }
    return wantarray ? @stdout : $rc || $ret;
}
EOF

}

1;

    

    

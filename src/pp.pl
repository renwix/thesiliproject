#!/usr/bin/perl

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

=pod

=head1 NAME

pp.pl - yet another perl templating language

=head1 SYNOPSIS

 > cat template | pp.pl > expanded_code

=head1 ARGUMENTS

=over 4

=item --start-tag

The start tag. defaults to '<:'.
    
=item --end-tag

The end tag. defaults to ':>'.

=item --keep

Keep: print the generated intermediate script on STDOUT.

=item --debug

The $debug command line flag and can be used with the &debugPrint subroutine.

=item --help

The help command line flag will print the help message.

=back

=head1 DESCRIPTION

Uses a templating language similar to JSP or ASP to expand and
transform a file with embedded perl.

=cut

use Expander;
use File::Basename;
use Sili::Ness;
use Env;
our ($debug, $opt_s, $opt_e, $opt_i, $opt_x, $opt_d, $opt_n);

# command line opts
my $__include_char = "-"; 
$__inclue_char = $ENV{__include_char} if $ENV{__include_char};
my $__expand_char = "="; 
$__expand_char = $ENV{__expand_char} if $ENV{__expand_char};
my $__start_tag = "<:"; 
$__start_tag = $ENV{__start_tag} if $ENV{__start_tag};
my $__end_tag = ":>"; 
$__end_tag = $ENV{__end_tag} if $ENV{__end_tag};
my $keep; $keep = $ENV{keep} if $ENV{keep};
$debug = "0"; $debug = $ENV{debug} if $ENV{debug};
my $help = "0"; $help = $ENV{help} if $ENV{help};

getopts
    'start-tag=s' => \$__start_tag,
    'end-tag=s'   => \$__end_tag,
    'include-char=s' => \$__include_char,
    'x|expand-char=s' => \$__expand_char,
    'debug' => \$debug,
    'no-eval|keep' => \$keep,
    ;

# processing
USAGE if $help;
my $expander = new Expander( __start_tag => $__start_tag,
                             __end_tag => $__end_tag,
                             __include_char => $__include_char,
                             __expand_char => $__expand_char,
                             __no_eval => $keep, );
my $src = $expander->expand( <STDIN> );
print $src if $keep;

exit 0;

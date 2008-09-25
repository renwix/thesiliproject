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

pp.pl    

=head1 SYNOPSIS

A library based, fast perl pre-processor

=head1 ARGUMENTS

=over 4

=item '-s'

The start tag.
    
=item '-e'

The end tag.

=item '-k'

Keep: pring the generated intermediate script on STDOUT.

=item '-d'

The $debug command line flag and can be used with the &debugPrint subroutine.

=item '-h'

The help command line flag will print the help message.

=back

=cut

use Getopt::Std qw(getopts);
use Expander;
use File::Basename;
our ($debug, $opt_s, $opt_e, $opt_i, $opt_x, $opt_d, $opt_n);

# command line opts
my $__include_char = "-"; $__inclue_char = $ENV{__include_char} if $ENV{__include_char};
my $__expand_char = "="; $__expand_char = $ENV{__expand_char} if $ENV{__expand_char};
my $__start_tag = "<:"; $__start_tag = $ENV{__start_tag} if $ENV{__start_tag};
my $__end_tag = ":>"; $__end_tag = $ENV{__end_tag} if $ENV{__end_tag};
my $keep; $keep = $ENV{keep} if $ENV{keep};
$debug = "0"; $debug = $ENV{debug} if $ENV{debug};
my $help = "0"; $help = $ENV{help} if $ENV{help};

getopts('d:ns:e:i:x:');
$__start_tag = $opt_s if $opt_s;
$__end_tag = $opt_e if $opt_e;
$__include_char = $opt_i if $opt_i;
$__expand_char = $opt_x if $opt_x;
$debug = $opt_d;
$no_eval = $opt_n;

# internal fns
sub debugPrint ($@) { 
  my $l = shift;
  return if ($main::debug < $l);
  my $c = '[' . (caller(1))[3] . ']';
  my $d = localtime;
  print STDERR "$c $d: " . basename($0) . ":($$): @_.\n" ;
}

sub printUsage {
  if (scalar @_ > 0) {
    print STDERR "@_\n";
    exit(1);
  } else {
    pod2usage({ -exitval => 1, 
                -verbose => ($debug ? $debug : 1),
                -output  => \*STDERR});
  }
}

# processing
printUsage() if $help;
my $expander = new Expander( __start_tag => $__start_tag,
                             __end_tag => $__end_tag,
                             __include_char => $__include_char,
                             __expand_char => $__expand_char,
                             __no_eval => $keep, );
my $src = $expander->expand( <STDIN> );
print $src if $keep;

exit 0;

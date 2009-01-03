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

getMD.pl - check ENV for exising variable definitions

=head1 SYNOPSIS

 > getMD.pl VAR1 VAR2

=head1 ARGUMENTS

=over 4

=item --format

By default this script produces shell output, but if this is set, then
another language can be generated. Allowed values are currently 'sh',
'perl'.

=back

=head1 DESCRIPTION

Given a list, of values, and an environment to check for those values, getMD
will return a string that can be evaled in the shell, or required into perl.

=cut

use Sili::Ness;
defineScript
    "getMD.pl - check ENV for exising variable definitions.
It will prompt if the variable doesn't exist in the environment.",
    param( name => 'format',
           tag => 'format=s',
           variable => '$format',
           doc => '
By default this script produces shell output, but if this is set, then
another language can be generated. Allowed values are currently:sh,perl'
    ),
    ;

my (@required, @output, %guts) = ();
my ($def_string, $cpp_string, $perl_string);

%guts = %ENV;

for (@ARGV) {
  # look for passthrough
  if (/^(.+?)=(.+)$/) {
    $guts{$1} = $2;
    push @output, $1;
    
    # look for the value in the env. ala varWarrior
  } elsif (exists $guts{$_}) {
    push @output, $_;
  } else {
    push @required, $_;
  }
}

for $var (@required) {
  $|=1;
  `echo "What is $var" >&2; stty echo`;
  $guts{$var} = <STDIN>; chomp $guts{$var};
}

for $var (@output, @required) {
  $guts{$var} =~ s/([\"\'])/\\$1/g; #'"
  debugPrint 1, "OUTPUT: $var -> $guts{$var}";
  $def_string .= "export $var=\"$guts{$var}\" ; ";
  $cpp_string .= " --define=$var='$guts{$var}'";
  $perl_string .= " \$main::$var = '$guts{$var}';";
  $perl_string .= " \$ENV{$var} = '$guts{$var}'; ";
}

unless ($format =~ /perl/i) {
  if ($def_string && $cpp_string) {
    print "$def_string export MACRO_DEFS=\"$cpp_string\"";
  } else {
    print "export MACRO_DEFS=\"\"";
  }
} else {
  print $perl_string;
}

exit 0;

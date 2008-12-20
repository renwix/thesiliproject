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

keyCleaner.pl - grep prefixed tags from an input file

=head1 SYNOPSIS

 > cat file | keyCleaner.pl MASK

=head1 DESCRIPTION

Given an input file and a mask, search that file for comment character
+ keyword pairs and assemble a list. Return the assembled list.

=head1 ARGUMENTS

=over 4

=item --commentChar

'The comment character.

=item --keywords

A list of keywords that should exist in the file.

=back

=cut


use Sili::Ness;

my $commentChar = '#'; my $keywords;
getopts 
    'commentChar=s' => \$commentChar,
    'keywords=s'    => \$keywords,
    ;
    
my @buffer = ();

while (<>) {
  for my $keyword (@keywords) {
    next unless s/^[(REM)(\/\/)\'(--)\#\;(\/\*)]*\s*$keyword\s+//;
    s/[\\(--)(\/\/)(\/\*)(\*\/)\#\'\r\n\f]/ /g;
    s/REM/ /g;
    s/\s+/ /g;
    push @buffer, $_;
  }
}
print join ' ', @buffer;

exit 0;


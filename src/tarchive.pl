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

tarchive.pl - A text based tar like utility

=head1 SYNOPSIS

 > tarchive.pl -x archive_file.tpl

=head1 ARGUMENTS

=over 4

=item --create

Set this commandline flag to create a new archive.

=item --extract || -x

Set this commandline flag to extract an existing archive

=item --rootDirectory

The root directory that the archive file should created from/extracted to

=item --archiveFile || -f

The archive file

=item --useXfmpipeHeader

Set this to include a "safe" xfmpipe header in the generated template
file. This is for convenience only.

=back

=head1 DESCRIPTION

A wrapper around the Template::SimpleTextArchive library.

=cut

use Template::SimpleTextArchive;
use Sili::Ness;

getopts
    'create' => \my $create,
    'x|extract' => \my $extract,
    'rootDirectory=s' => \my $root,
    'f|archiveFile=s' => \my $file,
    'useXfmpipeHeader' => \my $xfmpipeHeader,
 
USAGE unless $root && $file && ($create || $extract);

my $t = Template::SimpleTextArchive->new(rootDirectory => $root,
                                         archiveFile => $file,
                                         debug => $debug,
                                         defaultXfmpipeHeader => $xfmpipeHeader,
                                         verbose => $verbose);
if ($create) {
    $t->create();
} elsif ($extract) {
    $t->extract();
}

exit 0;

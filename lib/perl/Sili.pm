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

package Sili;

use 5.010000;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

# our @ISA = qw(Exporter);
# our %EXPORT_TAGS = ( 'all' => [ qw() ] );
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# our @EXPORT = qw();
our $VERSION = '0.01';

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Sili - Super Inappropriate Library Implementation

or was it the Silly and Intriguing Library Implementation

or was it the Super Imaginative Law-abiding Infidel

well, no matter. It is theSiliProject, a rose by any other...

=head1 SYNOPSIS

  use Sili::Ness;
  # not really - but we should have a class named that.

=head1 DESCRIPTION

Developers take code WAY too seriously. To be part of theSiliProject
the code has to:

=over 4

=item *

Make a knowledgable reader laugh when reading through the implementation.

=item *

Actually be useful for doing something

=item *

This isn't Perl Golf, it could be funny for the same reason that Ton
Hospel's code elicits laughter at the shear lunacy and "How did he
find that" and "What was Larry thinking" that is sure to follow, but
it is not the intent to create new forms of "eskimo kiss", or any of
the other short forms without a really good reason. It isn't about
obscurity, unless you are willing to write substantial documentation
around said obscurity.

=back

I thought long and hard about whether this project was 'Sili', 'Silli'
or just plain 'Si::'. The last one is pleasing because after a scotch
or two in the middle of the night, it starts to look like ants. Sili
wins out because it is pronounce 'CeeLee'... and lends itself an air
of something special when stuffed into a sentence that generally makes
sense. It might take the listener a good while to realize that you are
saying sili and not ceelee! As an American, it is even better with a
British accent.

=head1 SEE ALSO

The w3c OWL specs might be useful. Also try a google on OWL &&
s-expressions. That is bound to turn up a pdf describing a similar
mechanism to this lib, in a different language. Well - that is just
plain rude, here is the link:
http://www.mel.nist.gov/msid/conferences/SWESE/repository/8owl-vs-OOP.pdf

Mark Jason Dominus' Higher Order Perl book. Good stuff to bridge the
gap between a lisp and a perl.

m4 source code. Notice the similarities (and differences) to perl.

=head1 AUTHOR

Renwix (renwix), E<lt>renwick@x-ray-eyes.atE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Renwix

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

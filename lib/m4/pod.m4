m4_divert(-1)m4_dnl

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

m4_changecom()

m4_define(<++h1++>,<++=head1 $1

m4_shift($*)++>)

m4_define(<++h2++>,<++=head2 $1

m4_shift($*)++>)

m4_define(<++cb++>, <++
=item $1

m4_shift($*)++>)


m4_define(<++b++>, <++
=item _bullet_ident

<++$*++>++>)

m4_define(<++sb++>, <++m4_pushdef(<++_bullet_ident++>,<++$1++>)
=over
b(m4_shift($*))++>)

m4_define(<++eb++>, 
<++b(<++$*++>)

=back
m4_popdef(<++_bullet_ident++>)++>)

m4_define(<++ceb++>, 
<++cb($*)

=back
++>)
m4_define(<++h1++>,<++=head1 $1

m4_shift($*)++>)

m4_define(<++h2++>,<++=head2 $1

m4_shift($*)++>)

m4_define(<++cb++>, <++
=item $1

m4_shift($*)++>)


m4_define(<++b++>, <++
=item _bullet_ident

<++$*++>++>)

m4_define(<++sb++>, <++m4_pushdef(<++_bullet_ident++>,<++$1++>)
=over
b(m4_shift($*))++>)

m4_define(<++eb++>, 
<++b(<++$*++>)

=back
m4_popdef(<++_bullet_ident++>)++>)

m4_define(<++ceb++>, 
<++cb($*)

=back
++>)


m4_divert<++++>
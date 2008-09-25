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
m4_define([do_scsh],[m4_define([tmpfile],m4_maketemp([/tmp/fooXXXXXX]))m4_syscmd(echo "$*" > tmpfile)m4_esyscmd(scsh -s tmpfile)m4_syscmd(rm tmpfile)])m4_dnl
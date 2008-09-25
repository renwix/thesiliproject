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

package Expander;
use Data::Dumper;
use Carp;
=pod 

=head1 Expander.pm

Performance tuned expansion script

=head2 Trailing FileDescriptors

If a template alters the @Expander::_trailing_fd array as a result of
processing (being eval'ed), then that array is print join'ed onto the end
of the resulting prints. This is similar in spirit to the m4 multiple
file descriptor trick where text can get diverted to be re-attached
later... I.e. the end of processing.

=cut

{
  my $fields = [ 'start_tag', 
                 'end_tag', 
                 'include_char', 
                 'expand_char',
                 'resultant_code',
                 'text_to_be_parsed',
                 'tag_pattern',
                 'no_eval'
                 ];
  sub in_fields ($) { return grep { /$_[0]/ } @$fields }
}

@_trailing_fd = ();

sub AUTOLOAD {
  my $self = shift if ref $_[0] eq 'Expander';
  my $name;
  ($name = $AUTOLOAD) =~ s/.*:://;
  if ( Expander::in_fields( $name ) ) {  # getters and setters
    if (@_) {
      return $self->{'__' . $name} = shift;
    } else {
      return $self->{'__' . $name};
    }        
  } else { # everything else
    return &{*{'::' . $name}}(@_);
  }
}

# setup
sub new {
  my $class = shift; $class = (ref $class ? ref $class : $class);
  my %arg = (
             __start_tag => '<:',
             __end_tag => ':>',
             __include_char => '-',
             __expand_char => '=',
             ___resultant_code => '',
             __text_to_be_parsed => '',
             __no_eval => 0,
             @_,
             );
  
  my $self = bless \%arg, $class;
  $self->tag_pattern( qr{
                         $self->{__start_tag}
                         (.+?)
                         $self->{__end_tag}
                       }smx) unless $self->tag_pattern;
  return $self;
}

sub parse {
  my $this = shift;
  $this->push_text_to_parse( join '', @_ );
  while ($this->text_to_be_parsed =~ $this->tag_pattern) {
    $this->safe_print($`) if $`;
    my $__potential_code = $1;
    $this->text_to_be_parsed( "$'" ); #' # text is now the text trailing the match
    
    $this->debugPrint( 1, "<<$`>> : <<$__potential_code>> : <<$'>>" );
    if (substr($__potential_code, 0, 1) eq $this->include_char) { # include block
      $this->push_text_to_parse( __load_file(substr($__potential_code, 1)) );
    } elsif (substr($__potential_code, 0, 1) eq $this->expand_char) { # print block
      my $equals_expr = substr($__potential_code, 1);
      $equals_expr =~ s/\;\s*$//;
      $this->push_expansion( 'print(' . $equals_expr . '); ' );
    } else { # real code
      $this->push_expansion( $__potential_code );
    }
  }
  $this->safe_print($this->text_to_be_parsed);
}

sub expand {
  my $this = shift;
  $this->push_text_to_parse( join '', @_ );
  $this->parse();
  unless ($this->no_eval) {
    my $code = $this->resultant_code; # make sure I'm not evaling the AUTOLOAD call
    eval $code;
    if ($@) {
      confess "error expanding code: $@";
    }
  }
  
  #
  # If there were some special vars set, then add them to the output (trailing file descriptors in m4'speak)
  # and append them to the resultant_code too
  # 
  if (scalar @_trailing_fd) {
    print join '', @_trailing_fd;
    $this->push_expansion( "print( join '', \@_trailing_fd )" );
  }
  
  return $this->resultant_code;
}

sub dump {
  my $this = shift;
  return $this->resultant_code;
}


# ##########################################
sub __load_file {
  my $f = '';
  open(F, "<$_[0]") || die "Unable to open $_[0]: $!";
  $f = join '', <F>;
  close(F);
  return $f;
}

sub push_text_to_parse { my $t = shift; $t->text_to_be_parsed( $_[0] . $t->text_to_be_parsed ) }

sub push_expansion {
  my ($this, $data) = @_; 
  $this->resultant_code( $this->resultant_code . $data );
}


sub safe_print { 
  my ($this, $data) = @_;
  $data =~ s/\[/\\[/g; $data =~ s/\]/\\]/g; # escape our quote chars
  $this->push_expansion( 'print(q[' . $data . ']); ' );
}

sub debugPrint { 
  my $this = shift;
  my $level = shift;
  if ($this->{debug} >= $level || $main::debug >= $level) {
    use File::Basename;
    my ($caller) = (caller(1))[3];
    $caller = "[$caller]: " if $caller;
    my $date = localtime;
    print STDERR $caller . $date . ": " . basename($0) . ":($$): @_.\n" ;
  }
}

1;

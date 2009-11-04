#!/usr/bin/perl

while (@ARGV) {
  my $f = shift;
  my $pod = '';
  open(F, "<$f") || die "unable to open $f: $!";
  my $l = join '', (<F>);
  close(F);
  while( $l =~ /=pod(.+?)=cut/msg ) {
    $pod .= $1;
  }
  # what is it?
  if ($f =~ s/.pm$//) {
    $pkg = grep { s/package\s+// } $l;
    $pkg =~ s/:+/\//g;

  }
}
exit 0;


package Sili::Pickler;

use Data::Dumper;
use Sili::NamedParams classes => 1;
use Sili::Ness;

$Data::Dumper::Purity = 1;
$Data::Dumper::Varname = 'OBJ_CONTAINER';

defineClass
    "Utilities for freezing and thawing siliness"
    ;

sub freeze [$sili:required:ARRAY,
            $fh=*STDOUT] {
  print $fh Dumper( [ $sili ] );
}

sub thaw [$file:required] {
  open F, "<$file" || CONFESS "unable to open $file: $!";
  my $code = join '', (<F>);
  local $OBJ_CONTAINER1;
  eval $code;
  if ($@) {
      CONFESS "unable to load Sili::Ness in $file: $@";
  }
  return @$OBJ_CONTAINER1;
}

1;

      

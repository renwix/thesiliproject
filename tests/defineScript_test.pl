#!/usr/bin/perl

use Sili::Ness;

defineScript
    "This is a test script, doing more work than AT can provide",
    param( name => 'X',
           variable => '$X',
           tag => 'X:s',
           required => 1,
           doc => 'First test variable' ),
    param( name => 'Y',
           variable => '$Y',
           doc => 'First test variable' )
    ;

print "X = > $X\n";
print "Y = > $Y\n";

exit 0;



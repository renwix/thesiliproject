package Sili::ERS::Utils;

use Data::Dumper;
use FileHandle;
use Sili::NamedParams classes => 1;
use Sili::Ness;

defineClass
    "This is a container for mixins."
    ;

my $logHandle;
my $logLocation = 'STDERR';

sub logMessage [$node:req, $level:req, $message] {
    unless (defined $Sili::ERS::Utils::logHandle) {
        $Sili::ERS::Utils::logHandle = new FileHandle( ">& $logLocation" );
    }
    
    if ($main::debug >= $level) {
        my ($caller) = (caller(1))[3];
        $caller = "[$caller]:" if $caller;
        my $date = localtime;
        print $Sili::ERS::Utils::logHandle 
            $caller . $date . ":" . basename($0) . 
            ":pid=$$:nodeID=" . ($node ? $node->nodeID : '') . 
            ": $message.\n" ;
    }
}


package Sili::ERS::DB;

use Data::Dumper;
use FileHandle;
use Sili::NamedParams classes => 1;
use Sili::Ness;

defineClass
    'This is an interface declaration for the Sili::ERS database drivers. The type of driver used is derived from the environment at runtime and passed to the Nodes as necessary.'
    ;

sub registerNodeStart {
    CONFESS "Sili::ERS::DB abstract 'registerNodeStart()' called";
}

sub registerTimeout {
    CONFESS "Sili::ERS::DB abstract 'registerTimeout()' called";
}

sub getNodeData {
    CONFESS "Sili::ERS::DB abstract 'getNodeData()' called";
}

sub getNodesInState {
    CONFESS "Sili::ERS::DB abstract 'getNodesInState()' called";
}

sub registerComplete {
    CONFESS "Sili::ERS::DB abstract 'registerComplete()' called";
}

sub createNewNode {
    CONFESS "Sili::ERS::DB abstract 'createNewNode()' called";
}

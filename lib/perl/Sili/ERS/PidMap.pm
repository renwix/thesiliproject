package Sili::ERS::PidMap;

use Data::Dumper;
use Sili::ERS::Utils;
use Sili::NamedParams classes => 1;
use Sili::Ness;

defineClass
    "When the Sili::ERS runs, it has a mapping in memory about the work that it is performing. That map is also persisted in a persistence layer. This object is the map in memory between the OS process and the Sili::ERS::Node that it represents. "
    param( name => '_data',
           default => {},
           isa => 'HASH',
           doc => 'INTERNAL hash used to track data associated with this map' ),
    ;

sub add [$node:isaSili/ERS/Node:req] {
    if (exists $self->_data->{ $node->pid }) {
        CONFESS "pid/node is already in the PidMap! ", 
          Dumper($node), $self->toString;
    }
    logMessage( node => $node, 
                level => 1, 
                message => "pidMap add node, pid=" . $node->pid );
    return $this->_data->{ $node->pid } = $node;
}

sub get [$pid:req] {
    unless (exists $self->_data->{ $pid }) {
        CONFESS "Unable to find pid '$pid' in the PidMap! ", $self->toString();
    }
    my $node = $self->_data->{$pid};
    logMessage( node => $node, 
                level => 2, 
                message => "pidMap get node (a REAP), pid=" . $node->pid );
    return $node;
}

sub runningPidsExist {
    return scalar keys %{ $self->_data };
}

sub getReapableNodes {
    my @o = ();
    for my $node ( values %{ $self->_data } ) {
        push @o, $node if $node->reapable;
        # check the nodes that aren't attached to the current signal handler.
        if ($node->watching) {
            push @o, $node unless $node->watchPid();
        }
    }
    return @o;
}

sub findRunningNodeWith [$parallelKey:isaSili/ERS/ParallelKey] {
    return undef unless $parallelKey;
    for my $node ( values %{ $self->_data } ) {
        return $node 
            if $parallelKey->isTheSameAs( theOther => $node->parallelKey );
    }
    return undef;
}



sub delete [$node:isaSili/ERS/Node] {
    my $pid = $node->pid;
    return $node 
        if $pid < 0; # internal error was raised. Presumably nothing to delete

    unless (exists $self->_data()->{ $pid }) {
        CONFESS "Unable to find pid '$pid' in the PidMap! ";
    }
    my $node = $self->_data->{ $pid };
    delete $self->{_data}->{ $pid };
    return $node;
}

sub toString {
    $self->debugPrint( 0, "== PidMap Dumping State ==\n", Dumper( $self ) );
}

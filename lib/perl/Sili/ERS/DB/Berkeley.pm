package Sili::ERS::DB::Berkeley;

use BerkeleyDB;
use Data::Dumper;
use File::Path;
use Sili::NamedParams classes => 1;
use Sili::Ness;
use strict;

defineClass
    'BerekelyDB implementation of Sili::ERS persistence'
    param( name => 'db_root',
           default => "$ENV{HOME}/.sili",
           doc => 'The location of the BerkeleyDB Environment files' ),
    param( name => 'db_schema',
           default => "$ENV{USER}",
           doc => 'The schema where data should be written' ),
    param( name => 'dbh',
           doc => 'The db handle for this object' ),
    ;

sub init {
    my $self = shift;
    mkpath( $self->db_location . '/' . $self->db_schema );
    $env = new BerkeleyDB::Env
        -Home         => $self->db_location,
        -LockDetect => DB_LOCK_DEFAULT,
        -Flags => DB_CREATE | DB_INIT_CDB | DB_INIT_LOCK
        or CONFESS "ERROR: $self->db_location: $! $BerkeleyDB::Error";
        ;

    $taskdb = new BerkeleyDB::Hash
        -Filename => $self->db_schema . '/tasks',
        -Flags => DB_CREATE,
        -Property => DB_RENUMBER,
        -Env => $env
        or CONFESS "ERROR: $self->db_schema/tasks: $! $BerkeleyDB::Error";

    $self->dbh( $taskdb );
    return $self;
}

sub createNewNode [$node:isaSili/ERS/Node:req] {
    my ($max_id, $v);

    # lock the db and create
    my $lock = $self->dbh->cds_lock();
    my $c1 = $self->dbh->db_cursor();
    if ($c1->c_get($max_id, $v, DB_LAST) == 0) {
        $max_id++;
        $node->node_id( $max_id );
        $self->dbh->db_put($max_id, $node);
    } else {
        CONFESS "BDB error: $! $BerkeleyDB::Error\n";
    }
    $lock->cds_unlock();
}

sub registerNodeStart [$node:isaSili/ERS/Node:req] {

    # lock the db and register
    my $lock = $self->dbh->cds_lock();
    $node->state( 'running' );
    $self->dbh->db_put($node->nodeID, $node);
    $lock->cds_unlock();
}

sub getNodeData [$node:isaSili/ERS/Node] {
    my ($bdb_node);

    my $c1 = $self->dbh->db_cursor();
    if ($c1->c_get($node->nodeID, $bdb_node, DB_SET) == 0) {
        my @parent_path = $self->_getParentInfo( $node->nodeID );
        $node->parentNodeIDPath( [ @parent_path ] );
        $node->masterNodeID( $parent_path[ 0 ] || $node->nodeID );
        $self->dbh->db_put($node->nodeID, $node);        
    } else {
        CONFESS "BDB error: $! $BerkeleyDB::Error\n";
    }
}

sub _getParentInfo [$node_id:req,
                    $accumulator] {
    my ($bdb_node);
    $accumulator ||= [ $node_id ];

    my $c1 = $self->dbh->db_cursor();
    if ($c1->c_get($node_id, $bdb_node, DB_SET) == 0) {
        if (defined $bdb_node->parent_id) {
            unshift @$accumlator, $bdb_node->parent_id;
            $self->_getParentInfo( $bdb_node->parent_id, $accumulator );
        }
    } else {
        CONFESS "BDB error: $! $BerkeleyDB::Error\n";
    }
    return @$accumulator;
}

sub registerComplete [$node:isaSili/ERS/Node:req] {
    my $state = 'success';
    if ($node->returnCode != 0) {
        $state = 'failure';
    }
    $node->state( $state );
    $node->state( substr($node->message, 0, 2040) . ' ...' );
    
    # lock the db and change state
    my $lock = $self->dbh->cds_lock();
    $self->dbh->db_put($node->nodeID, $node);
    $lock->cds_unlock();
}

# full table scan
sub getNodesInState [$state='new'] {
    my ($id, $bdb_node, @res);
    my $c1 = $self->dbh->db_cursor();
    while ($c1->c_get($id, $bdb_node, DB_NEXT) == 0) {         
        push @res, $bdb_node if $bdb_node->state eq $state;
    }
    return @res;
}

# sub registerTimeout {
#     CONFESS "Sili::ERS::DB abstract 'registerTimeout()' called";
# }


1;

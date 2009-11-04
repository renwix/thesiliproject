package Sili::ERS::Node;

use File::Path;
use Sili::ERS::ProcessInfo;
use Sili::ERS::ParallelKey;
use Sili::Enging::Utils;
use Sili::NamedParams classes => 1;
use Sili::Ness;
use Sili::Pickler;

defineClass
    "This is the Node that is used in the engine. The main reason you would want to choose this engine versus some other is that this one logs/persists all STDIO/transition data in a DB or on disk. It is really handy for fault tolerant applications."
    isa 'Sili::Ness',
    param( name => 'name',
           doc => 'The name of the node',
           required => 1 ),
    param( name => 'command',
           doc => 'The name of the command that the node should run during exection(). If not specified, the execute() command looks for scripts that match the name of the Node.' ),
    param( name => 'children',
           doc => 'Any child nodes of this one.' ),
    param( name => 'parent',
           isa => 'Sili::ERS::Node',
           doc => 'A pointer to this nodes parent node.' ),
    param( name => 'transitionableReturnCode',
           doc => 'Only execute this node if the return code from this nodes parent is the same as what is defined in this field.' ),
    param( name => 'timeoutInSeconds',
           doc => 'If specified, then SIGKILL command after timeout.' ),
    param( name => 'timeoutCommand',
           doc => 'The command that should get run when the timeout occurs.' ),
    param( name => 'queryObject',
           isa => 'Sili::Ness',
           doc => 'A graph expansion helper. This is regular Siliness, but only partially populated. It is used to resolve all the matching objects in the environment and generate a list of Siliness that returns nodes for execution.' ),
    param( name => 'calculators',
           isa => 'ARRAY',
           default => '[]',
           doc => 'mem space for Siliness, required for heuristic.' ),
    
    # internal data is calculated/maintained during engine execution
    param( name => 'logRoot',
           doc => 'INTERNAL field for the location of log and staging files.'),
    param( name => 'nodeID',
           doc => 'INTERNAL ID for this node.' ),
    param( name => 'state',
           doc => 'INTERNAL gets set to what node is currently doing' ),
    param( name => 'parallelKey',
           isa => 'Sili::ERS::ParallelKey',
           default => 'new Sili::ERS::ParallelKey',
           doc => 'INTERNAL object that contains this nodes PK information' ),
    param( name => 'pid',
           doc => 'INTERNAL the pid that the command ran against.' ),
    param( name => 'graphFile',
           required => 1,
           doc => 'INTERNAL file pointer containing nodes graph/children.' ),
    param( name => 'envFile',
           doc => 'INTERNAL file pointer to nodes environment.'),
    param( name => 'watching',
           doc => 'INTERNAL boolean indicates if nodes sighandler is detached from SIGCHLD.' ),
    param( name => 'reapable',
           doc => 'INTERNAL boolean indicates if nodes command is complete/reapable.'),
    param( name => 'returnCode',
           doc => 'INTERNAL command execution results.'),
    param( name => 'signalNum',
           doc => 'INTERNAL signal code that the executing command received.' ),
    param( name => 'parentNodeIDPath',
           doc => 'INTERNAL to capture my parent information. This is used for generating log file pathing, but could be used for anything. It needs to be a nodeID list separated by /' ),
    param( name => 'masterNodeID',
           doc => 'INTERNAL my original ancestors information.'),
    param( name => 'logLocation',
           doc => 'INTERNAL location of log and staging files. This is derived from the runtime persistence information and is relative to the logRoot.'),
    param( name => 'message',
           doc => 'INTERNAL processing information - errors'),
    ;


sub execute [$pidMap:required:isaSili/ERS/PidMap,
             $dbh:isaSili/ERS/DB] {

  # ParallelKey management
  # basically, if there is someone else running with my pk.hash, then
  # I can't go. Don't put me in the pidmap, don't update my db status
  # don't create the child. Do nothing.
  if ( $pidMap->findRunningNodeWith( parallelKey => $self->parallelKey ) ) {
      logMessage( node => $self, 
                  level => 1, 
                  message => "node running with parallelkey '" . 
                     $self->parallelKey->serialize . "' already." );
      return;
  }

  # setup the staging area
  my $logLocation = $self->logRoot(); 
  $logLocation =~ s!/+$!!; 
  $logLocation .= $self->parentNodeIDPath();
  my $fileout = $logLocation . '/' . ($self->name ? $self->name : 'stdio');
  logMessage( node => $self, 
              level => 1, 
              message => "Logfile Location is '$logLocation'. " .
                "Output fileroot is: $fileout" );
  $self->logLocation( $logLocation );

  # QueryObjects
  # These don't get processed, just handed to the heuristics engine
  # to resolve what to do next. In otherwords, these are reapable immediately.
  if ($self->queryObject()) {
      $self->reapable( 1 );
      $self->pid( "$self" ); # has to be unique
      $self->returnCode( 0 );
      $pidMap->add( node => $self );
      return;
  }

  # prep the child environment & create it 
  my $pickler = new Sili::Pickler();
  my $envSilis = $pickler->thaw( $self->envFile );
  my %childEnv = map { $_->parse } @$envSilis; # TODO
  %childEnv = ( %main::ENV, %childEnv );
  logMessage( node => $self, 
              level => 3, 
              message => "Child Environment is " . Dumper(\%childEnv) );
  my $masterNodeID = $self->masterNodeID;
        
  # setup the command that we are executing
  my $node_id = $self->nodeID;
  $self->command( 'exit 0' ) unless $self->command; # healthy default
  my @execList = $self->_bashCommandArgProcessing( 
    command => "/bin/bash --noprofile --norc -c '" . $self->command . "'" );
  logMessage( node => $self, 
              level => 1, 
              message => "child will exec: @execList" );
        
  # DONT USE docmd.. have to be careful with what child
  # processes get spawned. Have to find a real perl way to do it.
  # docmd( "mkdir -p $logLocation" );
  mkpath( $logLocation );
        
  # make the dbh "safe" across the fork
  $dbh->dbh->{InactiveDestroy} = 1;
        
  # All the setup work is complete, so now fork and exec the child
  my $pid = fork(); 
  if ($pid) { # parent process

      # reopen stdio
      open STDOUT, ">&", $Sili::ERS::Utils::logHandle || 
          CONFESS "unable to reopen STDOUT: ./log.1: $@";
      open STDERR, ">&", $Sili::ERS::Utils::logHandle || 
          CONFESS "unable to reopen STDERR: ./log.2: $@";

      # Save myself in memory and in the persistence layer
      $self->pid( $pid );
      $pidMap->add( node => $self );
      $dbh->registerNodeStart( node => $self );

      # insert a timeout watcher
      if ($self->timeoutInSeconds()) {
          $dbh->registerTimeout( node => $self );
      }
  } else { # child process
      
      # Log management
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
      $mon++; $year += 1900;
      my $date = "$year-$mon-$mday $hour.$min.$sec";
            
      # reopen STDIO
      open STDOUT, ">> $fileout.1" || 
          CONFESS "unable to open logging for stdout: $fileout.1: $@";
      open STDERR, ">> $fileout.2" || 
          CONFESS "unable to open logging for stderr: $fileout.2: $@";

      print STDOUT "\n$date($pid) : ---------- BEGIN EXECUTION ----------\n";
      print STDOUT "\n" . join (' ' , @execList) . "\n";
      print STDERR "\n$date($pid) : ---------- BEGIN EXECUTION ----------\n";

      # bind the child env
      %ENV = (%childEnv, 
              STAGING => $logLocation,
              node_id => $node_id,
              master_node_id => $masterNodeID,
          );
            
      # put myself in the staging directory - which I am going to make the
      # log directory too... I am not convinced there is a reason to separate
      # these things.
      # chdir $logLocation;

      # And run the command
      exec @execList;
      # I only get here if there is a resource or env size issue.
  }
}


sub reap [$dbh:isaSili/ERS/DB:required,
          $pidMap:isaSili/ERS/PidMap:required,
          $errorMessage] {
  eval {
      kill $self->graphFile;
  }; if ($@) {
      logMessage( node => $self, 
                  level => 0, 
                  message => "Unable to remove graphFile: " . 
                  $self->graphFile . ": $@");
  }
  $pidMap->delete( node => $self );
  $dbh->registerComplete( node => $self, 
                          returnCode => $self->returnCode,
                          errorMessage => substr($errorMessage, 0, 512) );
}


sub watchPid [$pidMap:isaSili/ERS/PidMap:required] {
  my $ret = 0;
  my $pi = new Sili::ERS::ProcessInfo( pid => $self->pid, 
                                       command => $self->command );
  if ($pi->exists) {
      $self->watching( 1 );
      $self->reapable( 0 );
      logMessage( node => $self, 
                  level => 1, 
                  message => "Found pid related to node. Registering a Watch" );
      $ret = 1;
  } else {
      $self->watching( 0 );
      $self->reapable( 1 );
      $self->returnCode( 1 );
  }
  $pidMap->add( node => $self );
  return $ret;
}


#
# This algorithm was originally taken from bash 2.05
# 
sub _bashCommandArgProcessing 
  [$command='exit 0'] { 

  my @args = split /\s+/, $command;
  my @execList = ();
  my $folding;
  my $pusharg;
  for my $arg (@args) {
      logMessage( node => $self, 
                  level => 4, 
                  message => "there are $#execList args in \@execList for command '$command'" );
      logMessage( node => $self, 
                  level => 4, 
                  message => "examing argument $arg" );	
      if ($folding) {
          $pusharg = $arg;
          $pusharg =~ s/\'//g;
          $folding.=" $pusharg";
          logMessage( node => $self, 
                      level => 4, 
                      message => "folded argument is now $folding" );
          if ($arg =~ m/\'$/) {
              logMessage( node => $self, 
                          level => 4, 
                          message => "pushing $folding" );
              push @execList, $folding;
              logMessage( node => $self, 
                          level => 4, 
                          message => "there are $#execList args in \@execList" );
              $folding="";
          }
      } else {
          if ($arg =~ m/^\'.+?\'$/) {
              $arg =~ s/\'//g;		
              logMessage( node => $self, 
                          level => 4, 
                          message => "pushing $arg" );
              push @execList, $arg;
              logMessage( node => $self, 
                          level => 4, 
                          message => "there are $#execList args in \@execList for command '$command'");		
          } elsif ($arg =~ m/^\'/) {
              $arg =~ s/\'//g;
              $folding=$arg;
              logMessage( node => $self, 
                          level => 4, 
                          message => "folded argument is now $folding" );
          } else {
              $arg =~ s/\'//g;	    
              push @execList, $arg;
          }
      }	    
  }
  return @execList;
}


sub toUrl {
  my $o;
  $o = $self->_urlAppend( $o, 'name' );
  $o = $self->_urlAppend( $o, 'envFile' );
  $o = $self->_urlAppend( $o, 'graphFile' );
  $o = $self->_urlAppend( $o, 'parallelKey', $self->parallelKey->serialize() )
      if $self->parallelKey;
  return $o; 
}
sub _urlAppend {  # INTERNAL heler for the above fn
  my ($self, $base, $field, $value) = @_;
  my $o;
  if ($base) {
      $o .= $base . '&';
  } else {
      $o .= '?';
  }
  if (defined $value) {
      $o .= "$field=" . $value;
  } else {
      $o .= "$field=" . $self->{$field} if $self->{$field};
  }
  return $o;
}

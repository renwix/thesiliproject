package Sili::ERS::ProcessInfo;

use Data::Dumper;
use FileHandle;
use Sili::NamedParams classes => 1;
use Sili::Ness;

defineClass
    'There are perl process table access libraries, but they are all
os version specific. This uses the "ps" command to get the data in
what is hopefully a less os specific version. It also alleviates the
external dependencies that would be created by using a different lib.'
    param( name => "pid", 
           doc => 'The pid that the process table data should be grepped for' ),
    param( name => 'command',
           doc => 'The command that the process table should be grepped for' ),
    ;

sub exists [$pid,$command] {
    $command = $self->command unless $command;
    $pid = $self->pid unless $pid;

    # make our regexps safe
    $command =~ s/\s+/\\s+/;
    my ($result) = `ps -p 29831 -o command=`;
    if ($result =~ /$command/) {
        return 1;
    } else {
        return 0;
    }
}

package Sili::ERS::ParallelKey;

use Data::Dumper;
use Sili::NamedParams classes => 1;
use Sili::Ness;

defineClass
    isa Sili::Ness,
    param( name => '_data',
           default => {},
           isa => 'HASH',
           doc => 'INTERNAL this objects data' ),
    param( name => '_delim',
           default => chr(0xfe),
           doc => 'INTERNAL delimiter char for ParallelKey serialization' ),
    ;

sub add [$keyword] {
    $self->{_data}->{ $keyword } = 1;
    return $self;
}

sub get [$keyword] {
    if (exists $self->{_data}->{ $keyword }) {
        return $self->{_data}->{ $keyword };
    } else {
        return undef;
    }
}

sub isTheSameAs [$theOther:isaSili/ERS/ParallelKey:req] {
    if ($self->serialize eq $theOther->serialize) {
        return 1;
    } else {
        return 0;
    }        
}


sub serialize {
    my $d = $self->_delim;
    my @cleanKeys = map { s/\s+//;  s/-/_/g; lc } keys %{ $self->_data };
    return join $d, sort { $a <=> $b } @cleanKeys;
}

sub deserialize [$data:req] {
    my $d = $self->_delim;
    $self->_data( { map { $_ => 1 } split /\Q$d\E/, $data } );
    return $self;
}

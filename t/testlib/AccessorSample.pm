package testlib::AccessorSample;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub _has {
    my ($name) = @_;
    my ($package) = caller;
    my $method = "${package}::${name}";

    no strict "refs";
    *{$method} = sub {
        my ($self, $v) = @_;
        $self->{$name} = $v if @_ > 1;
        return $self->{$name};
    };
}

_has "foo";
_has "bar";
_has "buzz";

sub bomb {
    die "boom!";
}

1;


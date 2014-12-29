use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Data::Focus::Applicative::Identity;

{
    package Data::Focus::Applicative::Identity;
    use strict;
    use warnings FATAL => "all";
    
    sub pure {
        my ($class, $datum) = @_;
        return $class->build_result(undef, $datum);
    }

    sub pure_ap {
        my ($class, $func, $f_datum) = @_;
        return $class->build_result(sub { $func->($_[1]) }, undef, $f_datum);
    }

    sub equals {
        my ($self, $other) = @_;
        return $self->run_identity eq $other->run_identity;
    }
}

my $c = "Data::Focus::Applicative::Identity";

{
    note("--- identity law");
    my $id = sub { $_[0] };
    ok $c->pure_ap($id, $c->pure("hoge"))->equals($c->pure("hoge"));
}

done_testing;


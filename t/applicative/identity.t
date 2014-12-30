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

    ## $func <$> $f_data[0] <*> $f_data[1] <*> ...
    sub fmap_ap {
        my ($class, $func, @f_data) = @_;
        return $class->build_result(sub { shift; $func->(@_) }, undef, @f_data);
    }

    sub equals {
        my ($class, $self, $other) = @_;
        return $self->run_identity eq $other->run_identity;
    }
}

my $c = "Data::Focus::Applicative::Identity";

{
    note("--- functor and applicative functor laws");
    my $id = sub { $_[0] };
    ok($c->equals( $c->fmap_ap($id, $c->pure("hoge")), $id->($c->pure("hoge")) ), "functor first law");

    my $f = sub { $_[0] + 10 };
    my $g = sub { $_[0] * 20 };
    my $fg = sub { $f->($g->($_[0])) };
    my $fmapf_fmapg = sub { $c->fmap_ap($f, $c->fmap_ap($g, $_[0]))  };
    ok($c->equals( $c->fmap_ap($fg, $c->pure(1)),
                   $fmapf_fmapg->($c->pure(1)) ),
       "functor second law");

    ok($c->equals( $c->fmap_ap($g, $c->pure(5)), $c->pure($g->(5)) ), "applicative functor homomorphism law");
}

{
    note("--- build_result common spec");
    my @args = ();
    my $original = {};
    my $pure = $c->build_result(sub { push @args, \@_ }, $original);
    is scalar(@args), 0, "builder not called";
    isa_ok $pure, $c;
    isa_ok $pure, "Data::Focus::Applicative";

    @args = ();
    my $built = $c->build_result(sub { push @args, \@_ }, $original, map { $c->pure($_) } 10, 20, 30);
    ## Number of execution of the $builder depends on Functor implementation
    if(@args == 0) {
        note("builder is not called for $c");
    }else {
        foreach my $arg (@args) {
            identical $arg->[0], $original, "arg0 is the original";
            is scalar(@$arg), 4, "4 args given";
        }
    }
    isa_ok $built, $c;
    isa_ok $built, "Data::Focus::Applicative";
}

### 

{
    note("--- tests for Identity functor");
    is($c->pure("foobar")->run_identity, "foobar", "pure, run_identity()");

    my $ref = [];
    identical($c->pure($ref)->run_identity, $ref, "pure, run_identity() returns identical object");
}

{
    my $count = 0;
    my $result = $c->fmap_ap(sub { $count++; $_[0] * $_[1] * $_[2] }, map { $c->pure($_) } 3, 4, 5);
    is $count, 1, "mapper called once";
    is $result->run_identity, 60, "result OK";
}

done_testing;


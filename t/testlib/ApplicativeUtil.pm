package testlib::ApplicativeUtil;
use strict;
use warnings FATAL => "all";
use Exporter qw(import);
use Test::More;
use Test::Identity;

our @EXPORT_OK = qw(make_applicative_methods test_functor_basic);

sub make_applicative_methods {
    my ($target_class, $equals_code) = @_;
    no strict "refs";
    *{"${target_class}::pure"} = sub {
        my ($class, $datum) = @_;
        return $class->build_result(undef, $datum);
    };

    ## $func <$> $f_data[0] <*> $f_data[1] <*> ...
    *{"${target_class}::fmap_ap"} = sub {
        my ($class, $func, @f_data) = @_;
        return $class->build_result(sub { shift; $func->(@_) }, undef, @f_data);
    };

    *{"${target_class}::equals"} = sub {
        my ($class, $self, $other) = @_;
        $equals_code->($self, $other);
    };
}

sub test_functor_basic {
    my ($c) = @_;
    {
        note("--- $c: functor and applicative functor laws");
        my $id = sub { $_[0] };
        ok($c->equals( $c->fmap_ap($id, $c->pure("hoge")), $id->($c->pure("hoge")) ), "$c: functor first law");

        my $f = sub { $_[0] + 10 };
        my $g = sub { $_[0] * 20 };
        my $fg = sub { $f->($g->($_[0])) };
        my $fmapf_fmapg = sub { $c->fmap_ap($f, $c->fmap_ap($g, $_[0]))  };
        ok($c->equals( $c->fmap_ap($fg, $c->pure(1)),
                       $fmapf_fmapg->($c->pure(1)) ),
           "$c: functor second law");

        ok($c->equals( $c->fmap_ap($g, $c->pure(5)), $c->pure($g->(5)) ), "$c: applicative functor homomorphism law");
    }

    {
        note("--- $c: build_result common spec");
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
}

1;

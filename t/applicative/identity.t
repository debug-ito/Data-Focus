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

    sub fmap {
        my ($class, $func, $f_datum) = @_;
        return $class->build_result(sub { $func->($_[1]) }, undef, $f_datum);
    }

    sub equals {
        my ($class, $self, $other) = @_;
        return $self->run_identity eq $other->run_identity;
    }
}

my $c = "Data::Focus::Applicative::Identity";

## fmap id v = id v

## pure id <*> v = v <- Applicative identity law

## id <$> v = id v = v

## fmap f x = pure f <*> x  <- Applicative - Functor law

## ならば、 f <$> x <*> y <*> z = pure f <*> x <*> y <*> z -> composition lawは検証できるか？ いや、右辺を作ることができない。うーむ。

##  pure f <*> pure x = pure (f x)  => f <$> pure x = pure ( f x )  homomorphism law (これは検証できそう)


{
    my $id = sub { $_[0] };
    ok($c->equals( $c->fmap($id, $c->pure("hoge")), $id->($c->pure("hoge")) ), "functor first law");

    my $f = sub { $_[0] + 10 };
    my $g = sub { $_[0] * 20 };
    my $fg = sub { $f->($g->($_[0])) };
    my $fmapf_fmapg = sub { $c->fmap($f, $c->fmap($g, $_[0]))  };
    ok($c->equals( $c->fmap($fg, $c->pure(1)),
                   $fmapf_fmapg->($c->pure(1)) ),
       "functor second law");
}

done_testing;


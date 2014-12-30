use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Data::Focus::Applicative::Const::First;
use lib "t";
use testlib::ApplicativeUtil qw(make_applicative_methods test_functor_basic test_const_basic);

my $c = "Data::Focus::Applicative::Const::First";

make_applicative_methods($c, sub {
    my ($da, $db) = map { $_->get_const } @_;
    return (defined($da) && defined($db)) ? $da eq $db : !(defined($da) xor defined($db));
});

test_functor_basic($c);
test_const_basic($c);

is($c->pure(10)->get_const, undef);
is($c->mempty, undef);

note("--- mconcat");
foreach my $case (
    {label => "empty", input => [], exp => undef},
    {label => "all undef", input => [undef, undef, undef], exp => undef},
    {label => "single", input => [10], exp => 10},
    {label => "multi", input => [undef, 20, 30, undef, 50], exp => 20}
) {
    is($c->mconcat(@{$case->{input}}), $case->{exp}, "mconcat: $case->{label}");
}

is($c->fmap_ap(sub { die "this should not be called" }, map { $c->new($_) } undef, undef, 30, 20, 10)->get_const,
   30,
   "fmap_ap");

done_testing;

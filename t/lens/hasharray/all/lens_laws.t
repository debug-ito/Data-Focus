use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus::Lens::HashArray::All;
use Data::Focus::LensTester;
use lib "t";
use testlib::SampleObject;

my $tester = Data::Focus::LensTester->new(
    test_whole => sub { is_deeply($_[0], $_[1]) },
    test_part => sub { is_deeply($_[0], $_[1]) },
    parts => [
        undef, 1, "str", \(100), testlib::SampleObject->new,
        ["a", "b"], {foo => "bar"}
    ]
);

my %targets = (
    scalar => sub { "aaa" },
    scalar_ref => sub { \(100) },
    obj => sub { testlib::SampleObject->new },
    undef => sub { undef },
    empty_hash => sub { +{} },
    hash => sub { +{foo => "bar", fizz => "buzz"} },
    empty_array => sub { +[] },
    array => sub { +[0, 1, 2, 3] },
);

foreach my $case (
    {target => "scalar", exp_focal_points => 0},
    {target => "scalar_ref", exp_focal_points => 0},
    {target => "obj", exp_focal_points => 0},
    {target => "undef", exp_focal_points => 0},
    {target => "empty_hash", exp_focal_points => 0},
    {target => "empty_array", exp_focal_points => 0},
    {target => "hash", exp_focal_points => 2},
    {target => "array", exp_focal_points => 4},
) {
    foreach my $immutable (0, 1) {
        my $label = "$case->{target}, immutable=$immutable";
        subtest $label => sub {
            my $lens = Data::Focus::Lens::HashArray::All->new(immutable => $immutable);
            $tester->test_lens_laws(
                target => $targets{$case->{target}}, lens => $lens,
                exp_focal_points => $case->{exp_focal_points},
                exp_mutate => !$immutable
            );
        };
    }
}

done_testing;

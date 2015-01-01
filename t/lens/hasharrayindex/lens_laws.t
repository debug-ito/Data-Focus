use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus::LensTester;
use Data::Focus::Lens::HashArray::Index;
use lib "t";
use testlib::SampleObject;

my $tester = Data::Focus::LensTester->new(
    test_whole => sub {
        is_deeply(@_) or do {
            diag("whole1: " . explain($_[0]));
            diag("whole2: " . explain($_[1]));
        };
    },
    test_part  => sub { is_deeply(@_) },
    parts => [
        undef, 10, "aaa", \("bbb"),
        [10, 20], {}, {foo => "bar"},
        {hoge => [8, 9], buzz => {a => "A"}},
    ]
);

my %targets = (
    scalar => sub { "aaa" },
    hash => sub {
        +{
            foo => "bar",
            undef => undef,
            aa => [0,1,2],
        }
    },
    array => sub {
        +[20, undef, "AAA", bb => {hoge => "HOGE"}]
    },
    scalar_ref => sub {
        my $s = 999;
        return \$s;
    },
    obj => sub {
        testlib::SampleObject->new;
    },
    undef => sub { undef },
);

my @cases = (
    {target => "scalar", key => "hoge", exp_focal_points => 0},
    {target => "hash", key => "foo", exp_focal_points => 1},
    {target => "hash", key => "undef", exp_focal_points => 1},
    {target => "hash", key => "aa", exp_focal_points => 1},
    {target => "hash", key => "non-existent", exp_focal_points => 1},
    {target => "array", key => 0, exp_focal_points => 1},
    {target => "array", key => 1, exp_focal_points => 1},
    {target => "array", key => 2.5, exp_focal_points => 1},
    {target => "array", key => -3, exp_focal_points => 1}, ## in-range negative index. writable.
    {target => "array", key => 20, exp_focal_points => 1}, ## out-of-range positive index. writable.
    {target => "scalar_ref", key => "foo", exp_focal_points => 0},
    {target => "obj", key => "bar", exp_focal_points => 0},
    {target => "undef", key => "str", exp_focal_points => 1}, ## autovivification
    {target => "undef", key => 5, exp_focal_points => 1}, ## autovivification
);

foreach my $case (@cases) {
    my $lens = Data::Focus::Lens::HashArray::Index->new(
        key => $case->{key},
    );
    subtest "$case->{target}, $case->{key}" => sub {
        $tester->test_lens(
            lens => $lens, target => $targets{$case->{target}},
            exp_focal_points => $case->{exp_focal_points},
            exp_mutate => 1
        );
    };
}

TODO: {
    local $TODO = "TBW";
    fail("slice cases");
    fail("out-of-range negative index. it croaks when set");
    fail("non-number index for array. it may emit warnings");
}

done_testing;

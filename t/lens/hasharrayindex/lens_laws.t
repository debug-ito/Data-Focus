use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus::LensTester;
use Data::Focus::Lens::HashArrayIndex;
use lib "t";
use testlib::SampleObject;

my $tester = Data::Focus::LensTester->new(
    test_whole => sub { is_deeply(@_) },
    test_part  => sub { is_deeply(@_) },
    parts => [
        undef, 10, "aaa", \("bbb"),
        [10, 20], {}, {foo => "bar"},
        {hoge => [8, 9], buzz => {a => "A"}},
    ]
);

my $scalar = sub { "aaa" };

my $hash = sub {
    +{
        foo => "bar",
        undef => undef,
        aa => [0,1,2],
    }
};

my $array = sub {
    +[20, undef, "AAA", bb => {hoge => "HOGE"}]
};

my $scalar_ref = sub {
    my $s = 999;
    return \$s;
};

my $obj = sub {
    testlib::SampleObject->new
};

my $undef = sub { undef };

my @cases = (
    {target => $scalar, key => "hoge", exp_focal_points => 0},
    {target => $hash, key => "foo", exp_focal_points => 1},
    {target => $hash, key => "undef", exp_focal_points => 1},
    {target => $hash, key => "aa", exp_focal_points => 1},
    {target => $hash, key => "non-existent", exp_focal_points => 1},
    {target => $array, key => 0, exp_focal_points => 1},
    {target => $array, key => 1, exp_focal_points => 1},
    {target => $array, key => "str", exp_focal_points => 0},
    {target => $array, key => -3, exp_focal_points => 1}, ## in-range negative index. writable.
    {target => $array, key => -20, exp_focal_points => 0}, ## out-of-range negative index. non-writable.
    {target => $array, key => 20, exp_focal_points => 1},
    {target => $scalar_ref, key => "foo", exp_focal_points => 0},
    {target => $obj, key => "bar", exp_focal_points => 0},
    {target => $undef, key => "str", exp_focal_points => 1}, ## autovivification
    {target => $undef, key => 5, exp_focal_points => 1}, ## autovivification
);

foreach my $case (@cases) {
    my $lens = Data::Focus::Lens::HashArrayIndex->new(
        key => $case->{key},
    );
    $tester->test_lens(
        lens => $lens, target => $case->{target},
        exp_focal_points => $case->{exp_focal_points},
        exp_mutate => 1
    );
}

TODO: {
    local $TODO = "TBW";
    fail("slice cases");
}

done_testing;

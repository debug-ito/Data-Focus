use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus::LensTester;
use Data::Focus::Lens::HashArray::Index;
use lib "t";
use testlib::SampleObject;

my $tester = Data::Focus::LensTester->new(
    test_whole => sub {
        is_deeply(@_);
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

foreach my $case (
    {target => "scalar", key => "hoge", exp_focal_points => 0},
    {target => "hash", key => "foo", exp_focal_points => 1},
    {target => "hash", key => "undef", exp_focal_points => 1},
    {target => "hash", key => "aa", exp_focal_points => 1},
    {target => "hash", key => "non-existent", exp_focal_points => 1},
    {target => "hash", key => ["foo", "undef", "non-existent"], exp_focal_points => 3},
    {target => "hash", key => ["foo", "foo", "foo", "foo"], exp_focal_points => 4},
    {target => "array", key => 0, exp_focal_points => 1},
    {target => "array", key => 1, exp_focal_points => 1},
    {target => "array", key => 2.5, exp_focal_points => 1}, ## cast to int. without warning.
    {target => "array", key => -3, exp_focal_points => 1}, ## in-range negative index. writable.
    {target => "array", key => 20, exp_focal_points => 1}, ## out-of-range positive index. writable.
    {target => "array", key => [1, 10, 0], exp_focal_points => 3},
    {target => "array", key => [2,2,2,2], exp_focal_points => 4},
    {target => "scalar_ref", key => "foo", exp_focal_points => 0},
    {target => "obj", key => "bar", exp_focal_points => 0},

) {
    my $lens = Data::Focus::Lens::HashArray::Index->new(
        key => $case->{key},
    );
    my $keys = ref($case->{key}) ? join(",", @{$case->{key}}) : $case->{key};
    subtest "$case->{target}, $keys" => sub {
        $tester->test_lens_laws(
            lens => $lens, target => $targets{$case->{target}},
            exp_focal_points => $case->{exp_focal_points},
            exp_mutate => 1,
        );
    };
}

note("--- undef target. autovivification breaks get-set law");
foreach my $case (
    {target => "undef", key => "str", exp_focal_points => 1},
    {target => "undef", key => 5, exp_focal_points => 1},
    {target => "undef", key => ["foo", "bar"], exp_focal_points => 2},
    {target => "undef", key => [0, 3, 7], exp_focal_points => 3},
    {target => "undef", key => ["a", "a", "a"], exp_focal_points => 3},
    {target => "undef", key => [1,1,1], exp_focal_points => 3},
) {
   my $lens = Data::Focus::Lens::HashArray::Index->new(
       key => $case->{key}
   );
   my %test_args = (
       lens => $lens, target => $targets{$case->{target}},
       exp_focal_points => $case->{exp_focal_points},
       exp_mutate => 0 ## autovivification
   );
   my $keys = ref($case->{key}) ? join(",", @{$case->{key}}) : $case->{key};
   subtest "$case->{target}, $keys" => sub {
       $tester->test_set_set(%test_args);
       $tester->test_set_get(%test_args);
   };
}

done_testing;

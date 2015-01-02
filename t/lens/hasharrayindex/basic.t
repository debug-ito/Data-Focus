use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;
use lib "t";
use testlib::SampleObject;

sub lens {
    my ($key) = @_;
    return Data::Focus::Lens::HashArray::Index->new(key => $key);
}

sub make_label {
    my ($target, $key) = @_;
    return "$target, " . join(":", ref($key) ? @$key : $key);
}

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

note("--- get() / list()");

foreach my $case (
    {target => "hash", key => "foo", exp_g => "bar", exp_l => ["bar"]},
    {target => "hash", key => "undef", exp_g => undef, exp_l => [undef]},
    {target => "hash", key => "non-existent", exp_g => undef, exp_l => [undef]},
    {target => "hash", key => ["undef", "foo", "non-existent"], exp_g => undef, exp_l => [undef, "bar", undef]},
    {target => "hash", key => ["foo", "foo", "foo", "foo"], exp_g => "bar", exp_l => ["bar", "bar", "bar", "bar"]},
    {target => "array", key => 0, exp_g => 20, exp_l => [20]},
    {target => "array", key => 1, exp_g => undef, exp_l => [undef]},
    {target => "array", key => 2.4, exp_g => "AAA", exp_l => ["AAA"]},
    {target => "array", key => -3, exp_g => "AAA", exp_l => ["AAA"]},
    {target => "array", key => 20, exp_g => undef, exp_l => [undef]},
    {target => "array", key => [3, 10, 0], exp_g => "bb", exp_l => ["bb", undef, 20]},
    {target => "array", key => [2,2,2,2], exp_g => "AAA", exp_l => [("AAA") x 4]},
    {target => "scalar", key => "aaa", exp_g => undef, exp_l => []},
    {target => "scalar_ref", key => "aaa", exp_g => undef, exp_l => []},
    {target => "obj", key => "aaa", exp_g => undef, exp_l => []},
    {target => "undef", key => "str", exp_g => undef, exp_l => [undef]},
    {target => "undef", key => 10, exp_g => undef, exp_l => [undef]},
    {target => "undef", key => ["key", 10, 11], exp_g => undef, exp_l => [undef, undef, undef]},
) {
    my $label = make_label($case->{target}, $case->{key});
    subtest $label => sub {
        my $gen = $targets{$case->{target}};
        my $target = $gen->();
        my $lens = lens($case->{key});
        my $got_g = focus($target)->get($lens);
        is_deeply $got_g, $case->{exp_g}, "get()";
        my @got_l = focus($target)->list($lens);
        is_deeply \@got_l, $case->{exp_l}, "list()";
        is_deeply $target, $gen->(), "target is not modified by getters";
    };
}

note("--- set()");

foreach my $case (
    {target => "hash", key => "aa", val => 10, exp => {foo => "bar", undef => undef, aa => 10}},
    {target => "hash", key => "non-existent", val => "aaa",
     exp => {foo => "bar", undef => undef, aa => [0,1,2], "non-existent" => "aaa"}},
    {target => "hash", key => [0, 5, "aa"], val => 18,
     exp => {foo => "bar", undef => undef, aa => 18, 0 => 18, 5 => 18}},
    {target => "hash", key => ["foo", "foo", "foo"], val => 0,
     exp => {foo => 0, undef => undef, aa => [0,1,2]}},
    {target => "array", key => 4, val => [],
     exp => [20, undef, "AAA", "bb", []]},
    {target => "array", key => 6, val => "foo",
     exp => [20, undef, "AAA", "bb", {hoge => "HOGE"}, undef, "foo"]},
    {target => "array", key => -3, val => "aaa",
     exp => [20, undef, "aaa", "bb", {hoge => "HOGE"}]},
    {target => "array", key => [0, 2, 4], val => 80,
     exp => [80, undef, 80, "bb", 80]},
    {target => "array", key => [3, 7, 5], val => "xx",
     exp => [20, undef, "AAA", "xx", {hoge => "HOGE"}, "xx", undef, "xx"]},
    {target => "array", key => [-2, -1, -2, -1], val => "xx",
     exp => [20, undef, "AAA", "xx", "xx"]},

    ## negative index and positive out-of-range index. It expands the array for each key.
    {target => "array", key => [7, -2, 10, -2], val => "xx",
     exp => [20, undef, "AAA", "bb", {hoge => "HOGE"}, undef, "xx", "xx", undef, "xx", "xx"]},

    {target => "scalar", key => "hoge", val => "XXX", exp => "aaa"},
    {target => "scalar_ref", key => "hoge", val => "XXX", exp => \(999)},
    {target => "obj", key => "hoge", val => "XXX", exp => testlib::SampleObject->new()},
) {
    my $label = make_label($case->{target}, $case->{key});
    subtest $label => sub {
        my $target = $targets{$case->{target}}->();
        my $lens = lens($case->{key});
        my $got = focus($target)->set($lens, $case->{val});
        is_deeply $got, $case->{exp}, "set()";
        if(ref($target)) {
            identical $got, $target, "destructive update";
        }
    };
}

done_testing;

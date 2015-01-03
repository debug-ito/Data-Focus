use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Scalar::Util qw(refaddr);
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;
use lib "t";
use testlib::SampleObject;

sub lens {
    my ($key, $immutable) = @_;
    return Data::Focus::Lens::HashArray::Index->new(key => $key, immutable => $immutable);
}

sub make_label {
    my ($target, $key, $immutable) = @_;
    my $imm_str = $immutable ? "immutable" : "mutable";
    return "$target, " . join(":", ref($key) ? @$key : $key) . " ($imm_str)";
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
    foreach my $immutable (0, 1) {
        my $label = make_label($case->{target}, $case->{key}, $immutable);
        subtest $label => sub {
            my $gen = $targets{$case->{target}};
            my $target = $gen->();
            my $lens = lens($case->{key}, $immutable);
            my $got_g = focus($target)->get($lens);
            is_deeply $got_g, $case->{exp_g}, "get()";
            my @got_l = focus($target)->list($lens);
            is_deeply \@got_l, $case->{exp_l}, "list()";
            is_deeply $target, $gen->(), "target is not modified by getters";
        };
    }
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

    {target => "scalar", key => "hoge", val => "XXX", exp => "aaa", exp_immutable => 1},
    {target => "scalar_ref", key => "hoge", val => "XXX", exp => \(999), exp_immutable => 1},
    {target => "obj", key => "hoge", val => "XXX", exp => testlib::SampleObject->new(), exp_immutable => 1},
) {
    foreach my $immutable (0, 1) {
        my $label = make_label($case->{target}, $case->{key}, $immutable);
        subtest $label => sub {
            my $gen = $targets{$case->{target}};
            my $target = $gen->();
            my $lens = lens($case->{key}, $immutable);
            my $got = focus($target)->set($lens, $case->{val});
            is_deeply $got, $case->{exp}, "set()";
            if(ref($target)) {
                if($case->{exp_immutable} || $immutable) {
                    isnt refaddr($got), refaddr($target), "non-destructive update";
                    is_deeply $target, $gen->(), "target is preserved";
                }else {
                    identical $got, $target, "destructive update";
                }
            }
        };
    }
}

note("--- set() with autovivification");

foreach my $case (
    {key => "str", val => 10, exp => {str => 10}},
    {key => 3, val => 5, exp => [undef, undef, undef, 5]},
    {key => ["a", 4, "b"], val => "x", exp => {a => "x", 4 => "x", b => "x"}},
    {key => -3, val => "x", exp => {-3 => "x"}},
    {key => [4, 3, 4, 0], val => "x", exp => ["x", undef, undef, "x", "x"]},
    {key => "+1", val => "x", exp => {"+1" => "x"}},
) {
    foreach my $immutable (0, 1) {
        my $label = make_label("undef", $case->{key}, $immutable);
        subtest $label => sub {
            my $lens = lens($case->{key}, $immutable);
            my $got = focus(undef)->set($lens, $case->{val});
            is_deeply $got, $case->{exp};
        };
    }
}

done_testing;

use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Data::Focus qw(focus);

note("-- preliminary tests");

{
    my $target = {
        undef => undef,
        string => "STRING",
        num => 100,
        code => sub { "this is code" },
        empty_hash => {},
        empty_array => [],
        hash => {
            10 => "ten",
            five => 5,
        },
        array => [
            undef,
            "STR in array",
            200,
            undef,
            { hash => "in array" },
            [ "ARRAY", "in array" ],
            undef
        ],
    };

    my $f = focus($target);
    isa_ok $f, "Data::Focus";
    note("--- get()");
    
    foreach my $case (
        {lenses => ["undef"], exp_g => undef, exp_l => [undef]},
        {lenses => ["string"], exp_g => "STRING", exp_l => ["STRING"]},
        {lenses => ["num"], exp_g => 100, exp_l => [100]},
        {lenses => ["non-existent"], exp_g => undef, exp_l => [undef]},
    ) {
        my $label = join("/", @{$case->{lenses}});
        is $f->get(@{$case->{lenses}}), $case->{exp_g}, "$label: get()";
        is_deeply [$f->list(@{$case->{lenses}})], $case->{exp_l}, "$label: list()";
    }
}

TODO: {
    local $TODO = "TBW";
    fail("non-focused set/over. set/over when focused on hash/array in general");
    fail("slice, ALL, RECURSE traverser. get/list/set/over");
    fail("setters. destructive / non-destructive");
    fail("over()");
    fail("autovivification or not");
    fail("how to chooose hash or array. especially when autovivifying");
    fail("focusing deeper into str/int/undef/non-existent");
    fail("nested target and lens composition of different types. maybe traverse -> index, index -> traverse.");

    fail("slice lens: duplicate keys (get/set/over)");

    fail("common 'lens law' tests");

    fail("Data::Diver adaptor?");

    fail("option to expect specific number of focal points?? If the expectation fails, it croaks");
}

done_testing;


use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;

{
    note("--- example without lens");
    my $target = ["hoge", { foo => "bar" }];
    my $part = $target->[1]{foo};
    $target->[1]{foo} = "buzz";

    is $part, "bar";
    is_deeply $target, ["hoge", {foo => "buzz"}];
}

{
    note("--- example with lens");
    my $target = ["hoge", { foo => "bar" }];
    my $lens_1   = Data::Focus::Lens::HashArray::Index->new(key => 1);
    my $lens_foo = Data::Focus::Lens::HashArray::Index->new(key => "foo");
    my $part = focus($target)->get($lens_1, $lens_foo);
    focus($target)->set($lens_1, $lens_foo, "buzz");

    is $part, "bar";
    is_deeply $target, ["hoge", {foo => "buzz"}];
}

{
    note("--- example with coerced lens");
    
    my $target = ["hoge", { foo => "bar" }];
    my $part = focus($target)->get(1, "foo");
    focus($target)->set(1, foo => "buzz");

    is $part, "bar";
    is_deeply $target, ["hoge", {foo => "buzz"}];
}

{
    note("--- example slices");
    my $target = ["a", "b", "c"];
    my @abc = focus($target)->list([0, 1, 2]);

    is_deeply \@abc, ["a", "b", "c"];
}

done_testing;

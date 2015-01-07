use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus qw(focus);

{
    note("--- example");
    
    my $target = { foo => "bar" };
    my $part = focus($target)->get("foo");
    focus($target)->set(foo => "buzz");

    is $part, "bar";
    is_deeply $target, {foo => "buzz"};
}

done_testing;

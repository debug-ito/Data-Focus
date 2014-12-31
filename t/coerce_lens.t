use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus qw(focus);

sub create_target {
    return +{
        foo => [
            20, 30,
            {hoge => "HOGE"},
        ],
        bar => "buzz",
    };
}

is focus(create_target(), "foo", 2, "hoge")->get, "HOGE", "focus() lens coerce";
is(
    Data::Focus->new(target => create_target(), lens => "bar")->get,
    "buzz",
    "new() single lens coerce"
);
is focus(create_target)->into("foo", 1)->get, 30, "into() lens coerce";
is focus(create_target)->get("foo", 2, "hoge"), "HOGE", "get() lens coerce";
is_deeply [focus(create_target)->list("foo", [0,1])], [20, 30], "list() lens coerce";

is_deeply(
    focus(create_target)->set("foo", 0 => "quux"),
    +{ foo => ["quux", 30, {hoge => "HOGE"}], bar => "buzz" },
    "set() lens coerce"
);

is_deeply(
    focus(create_target)->over("foo", [0,1] => sub { 3 * $_[0] }),
    +{ foo => [60, 90, {hoge => "HOGE"}], bar => "buzz" },
    "over() lens coerce"
);

done_testing;

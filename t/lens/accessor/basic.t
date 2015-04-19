use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Fatal;
use Data::Focus qw(focus);
use Data::Focus::Lens::Accessor;
use lib "t";
use testlib::AccessorSample;
use testlib::Identity qw(identical);

sub lens {
    my ($name) = @_;
    return Data::Focus::Lens::Accessor->new(method => $name);
}

{
    my $target = testlib::AccessorSample->new;
    is focus($target)->get(lens("foo")), undef;
    my $ret = focus($target)->set(lens("foo"), "FOO");
    isa_ok $ret, "testlib::AccessorSample";
    identical $ret, $target, "set() returns the identical target";
    is $target->foo, "FOO";
    is focus($target)->get(lens("foo")), "FOO";
}

{
    my $target = testlib::AccessorSample->new;
    like exception { focus($target)->get(lens("bomb")) }, qr{boom}, "exception from the accessor method propagates.";
}

done_testing;

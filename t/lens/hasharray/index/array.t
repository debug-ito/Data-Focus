use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Fatal;
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;

note("edges cases for array targets");

{
    my $target = [0,1,2,3];
    my $lens = Data::Focus::Lens::HashArray::Index->new(key => -10);
    like(
        exception { focus($target)->set($lens, 10) },
        qr/negative out-of-range index/i,
        "set to negative out-of-range index raises an exception"
    );
}

{
    my @warns = ();
    local $SIG{__WARN__} = sub { push @warns, $_[0] };
    my $lens = Data::Focus::Lens::HashArray::Index->new(key => "str");
    my $got = focus([0,1,2,3])->set($lens, "AAA");
    is_deeply $got, ["AAA", 1,2,3], "string index cast to 0";
    note("warns:");
    note(explain \@warns);
}

done_testing;

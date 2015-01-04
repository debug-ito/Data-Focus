use strict;
use warnings FATAL => "all";
use Test::More;
use Test::Identity;
use Scalar::Util qw(refaddr);
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;

note("immutable lens creates minimal instances");

sub not_identical {
    my ($o1, $o2, $msg) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    isnt refaddr($o1), refaddr($o2), $msg;
}

sub gen_target {
    +[
        {
            a => "foo",
            numnum => [
                0, 1, 2, 3
            ]
        },
        {
            b => "hoge",
            num => [
                0, 1, 2, 3
            ]
        },
        {
            c => "quux",
            num => [
                0, 1, 2, 3
            ]
        }
    ];
}

my $target = gen_target();

my $result = focus($target)->set(
    Data::Focus::Lens::HashArray::Index->new(
        key => [0, 1], immutable => 1
    ),
    Data::Focus::Lens::HashArray::Index->new(
        key => ["a", "num"], immutable => 1
    ),
    Data::Focus::Lens::HashArray::Index->new(
        key => 2, immutable => 1
    ),
    "XXX"
);

is_deeply $target, gen_target(), "target preserved";
is_deeply(
    $result,
    [
        {
            a => "foo",
            numnum => [0, 1, 2, 3],
            num => [undef, undef, "XXX"],
        },
        {
            b => "hoge",
            a => [undef, undef, "XXX"],
            num => [0, 1, "XXX", 3],
        },
        {
            c => "quux",
            num => [0, 1, 2, 3],
        }
    ],
    "result OK"
);

not_identical($result, $target);
not_identical($result->[0], $target->[0]);
not_identical($result->[1], $target->[1]);
identical($result->[2], $target->[2]);

identical($result->[0]{numnum}, $target->[0]{numnum});
not_identical($result->[1]{num}, $target->[1]{num});
identical($result->[2]{num}, $target->[2]{num});

done_testing;

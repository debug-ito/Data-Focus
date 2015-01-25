use strict;
use warnings;
use Data::Focus qw(focus);

my $target = [{foo => "bar"}];
my @lenses = map { Data::Focus->coerce_to_lens($_) } 0, "foo";
my $val = focus($target)->get(@lenses) for 1..100;


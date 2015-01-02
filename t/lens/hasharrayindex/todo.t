use strict;
use warnings;
use Test::More;

fail("slice, ALL, RECURSE traverser. get/list/set/over");
fail("setters. destructive / non-destructive");
fail("out-of-range negative index. it croaks when set");
fail("non-number index for array. it may emit warnings");
fail("autovivification or not");
fail("how to chooose hash or array. especially when autovivifying");
fail("focusing deeper into undef. multi-level autovivification");
fail("slice lens: duplicate keys (get/set/over)");
fail("autovivify an array when keys like '+5' are used... or should it be hash??");

fail("combination of negative index and out-of-range positive index for array target. it breaks the set-set law.");
## {target => "array", key => [1, -1, 10], exp_focal_points => 3},


done_testing;


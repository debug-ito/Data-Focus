use strict;
use warnings;
use Test::More;

fail("slice, ALL, RECURSE traverser. get/list/set/over");
fail("setters. destructive / non-destructive");
fail("over()");
fail("out-of-range negative index. it croaks when set");
fail("non-number index for array. it may emit warnings");
fail("autovivification or not");
fail("how to chooose hash or array. especially when autovivifying");
fail("focusing deeper into str/int/undef/non-existent");
fail("slice lens: duplicate keys (get/set/over)");
fail("autovivify an array when keys like '+5' are used... or should it be hash??");

done_testing;


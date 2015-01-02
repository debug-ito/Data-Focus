use strict;
use warnings;
use Test::More;

fail("slice, ALL, RECURSE traverser. get/list/set/over");
fail("setters. destructive / non-destructive");
fail("out-of-range negative index. it croaks when set");
fail("non-number index for array. it may emit warnings");
fail("focusing deeper into undef. multi-level autovivification");

done_testing;


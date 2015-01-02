use strict;
use warnings;
use Test::More;

fail("slice, ALL, RECURSE traverser. get/list/set/over");
fail("setters. destructive / non-destructive");
fail("immutable option");
fail("non-number index for array. it may emit warnings");
fail("focusing deeper into undef. multi-level autovivification");
fail("set different values to duplicate keys");

done_testing;


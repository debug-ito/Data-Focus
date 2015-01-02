use strict;
use warnings FATAL => "all";
use Test::More;

fail("into() method");
fail("new() method");
fail("nested target and lens composition of different types. maybe traverse -> index, index -> traverse.");
fail("try to focus deeper into zero focal points");

done_testing;

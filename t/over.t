use strict;
use warnings FATAL => "all";
use Test::More;

fail("over() method.");

fail("over() method should call the callback the same time as # of focal points.");
fail("And is passed part data in the same order as they are got by list()");
fail("Probably this test should go into LensTester");
fail("Handling of duplicate keys are undefined. It's up to lens implementation");

## We don't have to test over() method on individual lenses. Testing set() method alone is enough.

done_testing;

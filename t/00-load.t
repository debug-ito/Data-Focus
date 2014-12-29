use 5.006;
use strict;
use warnings;
use Test::More;
 
BEGIN {
    foreach my $name (
        "", "::Applicative", "::Applicative::Identity"
    ) {
        use_ok( "Data::Focus$name" );
    }
}
 
diag( "Testing Data::Focus $Data::Focus::VERSION, Perl $], $^X" );

done_testing;

use 5.006;
use strict;
use warnings;
use Test::More;
 
plan tests => 1;
 
BEGIN {
    use_ok( 'Data::Focus' ) || print "Bail out!\n";
}
 
diag( "Testing Data::Focus $Data::Focus::VERSION, Perl $], $^X" );

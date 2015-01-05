package testlib::Identity;
use strict;
use warnings;
use Exporter qw(import);
use Test::More;
use Scalar::Util qw(refaddr);

our @EXPORT_OK = qw(check_identity);

sub check_identity {
    my ($got_obj, $exp_obj, $exp_identical, $label) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    $label = "" if not defined $label;
    my $got_addr = refaddr($got_obj);
    my $exp_addr = refaddr($exp_obj);
    if(!defined($exp_addr)) {
        if($exp_identical) {
            return ok !defined($got_addr), "$label: exp_obj is not a reference. got_obj should not be a reference either.";
        }else {
            return pass "$label: exp_obj is not a reference. Anything is non-identical to it";
        }
    }else {
        if($exp_identical) {
            return is $got_addr, $exp_addr, "$label: identical";
        }else {
            return isnt $got_addr, $exp_addr, "$label: non-identical";
        }
    }
}

1;

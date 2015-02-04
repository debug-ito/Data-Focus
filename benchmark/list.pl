use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;
use Benchmark qw(timethese);
use Data::Focus qw(focus);
use JSON qw(encode_json);
use Data::Focus::Lens::HashArray::All;

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

my $ALL = Data::Focus::Lens::HashArray::All->new;

my %bench_codes = (
    focus_lens => sub {
        my ($target) = @_;
        return focus($target)->list($ALL);
    },
    direct => sub {
        my ($target) = @_;
        return @$target;
    }
);

my @cases = ();
GetOptions(
    "c|case=s" => \@cases,
    "h|help" => \&usage,
);
@cases = keys %bench_codes if !@cases;

my @sizes = @ARGV;
usage if !@sizes;
my %result = ();

foreach my $size (@sizes) {
    local *STDOUT = *STDERR;
    my $target = [(0) x $size];
    my $ret = timethese(-3, {map {
        my $case = $_;
        ($case => sub { my @got = $bench_codes{$case}->($target) });
    } @cases});
    $result{$size} = focus($ret)->over($ALL, sub { $_[0]->iters });
}
print encode_json \%result;


__END__

=pod

=head1 NAME

list.pl - benchmark list() method

=head1 SYNOPSIS

    $ list.pl [OPTIONS] LIST_SIZES
    $ list.pl -c direct -c focus 0 1 2 5 10 > result.json

=head1 OPTIONS

=over

=item -c, --case CASE

Benchmark case. Multiple cases are allowed. Default is "direct" and "focus_lens".

=item -h, --help

Show this message.

=back

=cut



use strict;
use warnings;
use Benchmark qw(timethese);
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::All;
use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;
use JSON qw(encode_json);

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

GetOptions(
    "h|help" => \&usage,
);

my @levels = @ARGV;

usage if !@levels;

my $target = {};
my $lens = Data::Focus->coerce_to_lens(2);
my $ALL = Data::Focus::Lens::HashArray::All->new;
my %result = ();

foreach my $level (@levels) {
    local *STDOUT = *STDERR;
    my $ret = timethese(-3, {
        focus => sub { focus($target)->into((2) x $level) },
        focus_lens => sub { focus($target)->into(($lens) x $level) },
    });
    $result{$level} = focus($ret)->over($ALL, sub { $_[0]->iters });
}
print encode_json(\%result);


__END__

=pod

=head1 NAME

into.pl - benchmark for into()

=head1 SYNOPSIS

    $ into.pl NEST_LEVELS
    $ into.pl 1 2 5 7 10 > result.json

=cut

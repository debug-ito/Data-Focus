#!/usr/bin/env perl
use v5.10.0;
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case bundling);
use Gnuplot::Builder qw(gscript gdata);
use JSON qw(decode_json);

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

GetOptions(
    "h|help" => \&usage
);

my $result_str = do { local $/; <> };
my $result = decode_json($result_str);
my $base_count = do {
    my ($min_level) = sort {$a <=> $b} keys %$result;
    $result->{$min_level}{direct};
};
my @datasets = map {
    my $key = $_;
    gdata(sub {
        my ($d, $writer) = @_;
        $writer->(qq{"$key"\n});
        foreach my $level (sort {$a <=> $b} keys %$result) {
            my $val = $result->{$level}{$key} / $base_count * 100;
            $writer->("$level $val\n");
        }
    });
} qw(direct diver focus);

my $script = gscript(
    key => "autotitle columnhead",
    "style data" => "lp",
)->setq(
    xlabel => "depth of nest",
    ylabel => "relative count of iterations [%]",
);

$script->plot(@datasets);

__END__

=pod

=head1 NAME

plot_get.pl - plot the result of get.pl

=head1 SYNOPSIS

    $ get.pl 1 10 20 > result.json
    $ plot_get.pl result.json

=head1 AUTHOR

Toshio Ito

=cut

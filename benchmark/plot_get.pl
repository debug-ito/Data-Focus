#!/usr/bin/env perl
use v5.10.0;
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case bundling);
use Gnuplot::Builder qw(gscript gdata);
use File::Slurp::Tiny qw(read_file);
use JSON qw(decode_json);

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

GetOptions(
    "h|help" => \&usage,
    "base-key=s" => \(my $base_key = "direct"),
);

my @datasets;
my $base_count;

foreach my $filename (@ARGV) {
    my $result_str = read_file($filename);
    my $result = decode_json($result_str);
    if(!defined($base_count)) {
        my ($min_level) = sort {$a <=> $b} keys %$result;
        $base_count = $result->{$min_level}{$base_key};
    }
    foreach my $key (qw(direct diver focus focus_lens)) {
        my $d = gdata(sub {
            my ($d, $writer) = @_;
            foreach my $level (sort {$a <=> $b} keys %$result) {
                my $val = $result->{$level}{$key};
                if(defined($base_count)) {
                    $val = $val / $base_count * 100;
                }
                $writer->("$level $val\n");
            }
        })->setq(
            title => "$filename - $key"
        );
        push @datasets, $d;
    }
}

usage if !@datasets;

if(!defined($base_count)) {
    warn "base_count is not available. Use raw count. Try --base-key option.\n";
}

my $script = gscript(
    "style data" => "lp",
)->setq(
    xlabel => "depth of nest",
    ylabel => defined($base_count) ? "relative count of iterations [%]" : "count of iterations",
);

$script->plot(@datasets);

__END__

=pod

=head1 NAME

plot_get.pl - plot the result of get.pl

=head1 SYNOPSIS

    $ git checkout master
    $ get.pl 1 10 20 > master.json
    $ git checkout unstable
    $ get.pl 1 10 20 > unstable.json
    $ plot_get.pl [OPTION] master.json unstable.json

=head1 OPTIONS

=over

=item --base-key KEY

The entry key whose data is used as the base. Default: "direct".

=item -h, --help

Show this message.

=back

=head1 AUTHOR

Toshio Ito

=cut

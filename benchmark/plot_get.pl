#!/usr/bin/env perl
use v5.10.0;
use strict;
use warnings;
use Gnuplot::Builder qw(gscript gdata);
use JSON qw(decode_json);

my $result_str = do { local $/; <> };
my $result = decode_json($result_str);
my @datasets = map {
    my $key = $_;
    gdata(sub {
        my ($d, $writer) = @_;
        $writer->(qq{"$key"\n});
        foreach my $level (sort {$a <=> $b} keys %$result) {
            $writer->("$level $result->{$level}{$key}\n");
        }
    });
} qw(direct diver focus);

my $script = gscript(
    key => "autotitle columnhead",
    "style data" => "lp",
);

$script->plot(@datasets);

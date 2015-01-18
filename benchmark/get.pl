#!/usr/bin/env perl
use v5.10.0;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case bundling);
use strict;
use warnings;
use Benchmark qw(timethese);
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;
use Data::Focus::Lens::HashArray::All;
use Data::Diver qw(Dive);
use JSON qw(encode_json);

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

GetOptions(
    "h|help" => \&usage,
);

my $ALL_LENS = Data::Focus::Lens::HashArray::All->new;

sub create_nested_arrays {
    my ($level) = @_;
    my $data = "a";
    foreach (1 .. $level) {
        $data = [$data];
    }
    return $data;
}

sub create_direct_accessor {
    my ($level) = @_;
    my $subscripts = "[0]" x $level;
    return eval qq{sub { \$_[0]->$subscripts }};
}

sub create_diver_accessor {
    my ($level) = @_;
    return sub { Dive($_[0], (0) x $level) };
}

sub create_focus_accessor {
    my ($level) = @_;
    return sub { focus($_[0])->get((0) x $level) };
}

my %results = ();
my @levels = @ARGV;
usage if !@levels;

foreach my $level (@levels){
    local *STDOUT = *STDERR;
    my %accessors = map {
        my $accessor_maker = do { no strict "refs"; \&{"create_${_}_accessor"} };
        ($_ => $accessor_maker->($level))
    } qw(direct diver focus);
    my $target = create_nested_arrays($level);
    foreach my $name (keys %accessors) {
        my $val = $accessors{$name}->($target);
        die "$name returns a wrong value: $val" if $val ne "a";
    }
    my $result_for_level = timethese(-3, {map {
        my $key = $_;
        ($key => sub { my $x = $accessors{$key}->($target) })
    } keys %accessors});
    
    $results{$level} = focus($result_for_level)->over($ALL_LENS, sub { $_[0]->iters });
}

print encode_json(\%results);

__END__

=pod

=head1 NAME

get.pl - benchmark for getting an element from a deeply nested structure.

=head1 SYNOPSIS

    $ get.pl NEST_LEVELS
    
    $ get.pl 1 10 30 > result.json

=head1 AUTHOR

Toshio Ito

=cut

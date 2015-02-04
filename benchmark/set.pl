use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;
use Benchmark qw(timethese);
use Data::Focus qw(focus);
use JSON qw(encode_json);
use Data::Focus::Lens::HashArray::All;

sub usage { pod2usage(-verbose => 2, -noperldoc => 1) }

sub create_nested_arrays {
    my ($level) = @_;
    my $data = "a";
    foreach (1 .. $level) {
        $data = [$data];
    }
    return $data;
}

sub create_direct_setter {
    my ($level) = @_;
    my $subscripts = "[0]" x $level;
    return eval qq{sub { \$_[0]->$subscripts = \$_[1] }};
}

sub create_focus_setter {
    my ($level) = @_;
    return sub { focus($_[0])->set((0) x $level, $_[1]) };
}

sub create_focus_lens_setter {
    my ($level) = @_;
    my $lens = Data::Focus->coerce_to_lens($level);
    return sub { focus($_[0])->set(($lens) x $level, $_[1]) };
}


my $ALL = Data::Focus::Lens::HashArray::All->new;

my @cases;
GetOptions(
    "c|case" => \@cases,
    "h|help" => \&usage,
);
@cases = qw(direct focus focus_lens) if !@cases;

my @levels = @ARGV;
usage if !@levels;

my %result;
foreach my $level (@levels) {
    local *STDOUT = *STDERR;
    my $target = create_nested_arrays($level);
    my %bench = map {
        my $case = $_;
        no strict "refs";
        my $setter = &{"create_${case}_setter"}($level);
        ($case => sub { $setter->($target, 999) });
    } @cases;
    my $ret = timethese(-3, \%bench);
    $result{$level} = focus($ret)->over($ALL, sub { $_[0]->iters });
}
print encode_json \%result;


__END__

=pod

=head1 NAME

set.pl - benchmark set() method

=head1 SYNOPSIS

    $ set.pl [OPTIONS] NEST_LEVELS
    $ set.pl -c focus 1 2 5 7 10 > result.json

=head1 OPTIONS

=over

=item -c, --case

Benchmark cases to run. You can specify more than one cases.
The default is "direct", "focus" and "focus_lens"

=item -h, --help

Show this message.

=back

=head1 AUTHOR

Toshio Ito

=cut

use v5.10.0;
use strict;
use warnings;
use Benchmark qw(cmpthese);
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;
use Data::Diver qw(Dive);

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

foreach my $level (1, 10, 50){
    my %accessors = map {
        my $accessor_maker = do { no strict "refs"; \&{"create_${_}_accessor"} };
        ($_ => $accessor_maker->($level))
    } qw(direct diver focus);
    my $target = create_nested_arrays($level);
    say "### level $level";
    say "$_: " . $accessors{$_}->($target) foreach keys %accessors;
    cmpthese(-3, {map {
        my $key = $_;
        ($key => sub { my $x = $accessors{$key}->($target) })
    } keys %accessors});
}

package Data::Focus::Util;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT_OK = qw(create_whole_mapper);

sub create_whole_mapper {
    my ($app_class, $part_mapper, @lenses) = @_;
    while(defined(my $lens = pop @lenses)) {
        $part_mapper = $lens->apply($part_mapper, $app_class);
    }
    return $part_mapper;
}

1;

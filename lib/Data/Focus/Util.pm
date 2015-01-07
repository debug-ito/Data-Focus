package Data::Focus::Util;
use strict;
use warnings;
use Exporter qw(import);
use Data::Focus::Lens::HashArray::Index;

## internal use only

our @EXPORT_OK = qw(create_whole_mapper coerce_to_lens);

sub create_whole_mapper {
    my ($app_class, $part_mapper, @lenses) = @_;
    while(defined(my $lens = pop @lenses)) {
        $part_mapper = $lens->apply($part_mapper, $app_class);
    }
    return $part_mapper;
}

sub coerce_to_lens {
    my ($maybe_lens) = @_;
    eval { $maybe_lens->isa("Data::Focus::Lens") }
        ? $maybe_lens
        : Data::Focus::Lens::HashArray::Index->new(key => $maybe_lens); ## default lens (for now)
}

1;

package Data::Focus::Util;
use strict;
use warnings;
use Exporter qw(import);
use Data::Focus::Lens::HashArray::Index;

## internal use only

our @EXPORT_OK = qw(coerce_to_lens);

sub coerce_to_lens {
    my ($maybe_lens) = @_;
    eval { $maybe_lens->isa("Data::Focus::Lens") }
        ? $maybe_lens
        : Data::Focus::Lens::HashArray::Index->new(key => $maybe_lens); ## default lens (for now)
}

1;

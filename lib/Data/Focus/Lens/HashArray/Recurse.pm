package Data::Focus::HashArray::Recurse;
use strict;
use warnings;

1;
__END__

=pod

=head1 NAME

Data::Focus::HashArray::Recurse - recursively traverse hash/array

=head1 SYNOPSIS

    use Data::Focus qw(focus);
    use Data::Focus::Lens::HashArray::Recurse;
    
    my $target = [
        {foo => 1, bar => 2},
        3,
        [4, 5, 6],
        [],
        {}
        {hoge => 7}
    ];
    
    my $lens = Data::Focus::Lens::HashArray::Recurse->new;
    
    my $result = focus($target)->over($lens, sub { $_[0] * 100 });
    
    ## $result is:
    ## [
    ##     {foo => 100, bar => 200},
    ##     300,
    ##     [400, 500, 600],
    ##     [],
    ##     {},
    ##     {hoge => 700}
    ## ]

=head1 DESCRIPTION

L<Data::Focus::Lens::HashArray::Recurse> is a L<Data::Focus::Lens> class
that recursively traverses a data structure made of hashes and arrays.
It creates focal points on everything it finds on the traversal.

=head1 CLASS METHODS

=head2 $lens = Data::Focus::Lens::HashArray::Recurse->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<immutable> => BOOL (optional, default: false)

If set to true, the target hash/array is treated as immutable.
This means every updating operation using the C<$lens> creates a new hash/array in a copy-on-write fashion.

=back

=head1 OBJECT METHODS

=head2 apply

See L<Data::Focus::Lens>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

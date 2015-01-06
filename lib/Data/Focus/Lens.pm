package Data::Focus::Lens;
use strict;
use warnings;
use overload "." => sub {
    my ($self, $other, $swap) = @_;
    require Data::Focus::Lens::Composite;
    return Data::Focus::Lens::Composite->new(
        $swap ? ($other, $self) : ($self, $other)
    );
};

1;
__END__

=pod

=head1 NAME

Data::Focus::Lens - base class for lenses

=head1 DESCRIPTION

L<Data::Focus::Lens> is the base class for all lenses in L<Data::Focus> framework.

This class implements nothing except for operator overloads. See L</OVERLOADS> for detail.

=head1 ABSTRACT OBJECT METHODS

B<< This interface is experimental for now. You should not implement them by hand. Use L<Data::Focus::LensMaker> instead. >>

All lens implementations must implement the following methods.

=head2 $whole_mapper = $lens->apply($part_mapper, $applicative_class)

Create a mapper for a whole data structure (C<$whole_mapper>) from a mapper for a part of the data (C<$part_mapper>).

Both of C<$part_mapper> and C<$whole_mapper> are code-refs, and they have the same signature.

    $f_after_data = $mapper->($before_data)

where C<$before_data> is the data before mapping, and C<$f_after_data> is the data after mapping wrapped
in a L<Data::Focus::Applicative> object.

C<$applicative_class> is the name of a L<Data::Focus::Applicative> subclass.
The return value from C<$part_mapper> and C<$whole_mapper> must be an object of this class.
Generally speaking, it defines the "context" in which this lens operation is performed.

=head1 OVERLOADS

The C<"."> operator is overloaded. It means lens composition.

    $composite_lens = $lens1 . $lens2

See L<Data::Focus::Lens::Composite> for detail.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

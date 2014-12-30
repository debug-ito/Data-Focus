package Data::Focus::Applicative::Const::List;
use strict;
use warnings;
use parent qw(Data::Focus::Applicative::Const);

sub mempty { [] }
sub mconcat {
    my ($class, @data) = @_;
    return [map { @$_ } @data];
}

1;

__END__

=pod

=head1 NAME

Data::Focus::Applicative::Const::List - Const applicative functor with List monoid

=head1 DESCRIPTION

B<< Internal use only. >>

This functor accepts an array-ref as its value.

=head1 METHODS

See L<Data::Focus::Applicative::Const>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

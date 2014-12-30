package Data::Focus::Applicative::Const::First;
use strict;
use warnings;
use parent qw(Data::Focus::Applicative::Const);

sub mempty { undef }
sub mconcat {
    my $class = shift;
    my $datum = $class->mempty;
    while(@_) {
        $datum = shift;
        return $datum if defined $datum;
    }
    return $datum;
}

1;
__END__

=pod

=head1 NAME

Data::Focus::Applicative::Const::First - Const applicative functor with First monoid

=head1 DESCRIPTION

B<< Internal use only. >>

=head1 METHODS

See L<Data::Focus::Applicative::Const>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

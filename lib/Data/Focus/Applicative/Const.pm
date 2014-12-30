package Data::Focus::Applicative::Const;
use strict;
use warnings;
use parent qw(Data::Focus::Applicative);

sub new {
    my ($class, $datum) = @_;
    return bless \$datum, $class;
}

sub build_result {
    my ($class, $builder, $original, @f_parts) = @_;
    return @f_parts == 0 ? $class->new($class->mempty)
        : $class->new($class->mconcat(map { $_->get_const } @f_parts));
}

sub get_const {
    return ${$_[0]};
}

sub mempty { die "not implemented" }
sub mconcat { die "not implemented" }

1;
__END__

=pod

=head1 NAME

Data::Focus::Applicative::Const - Const applicative functor for Data::Focus

=head1 DESCRIPTION

B<< Internal use only. >>

A L<Data::Focus::Applicative> class for Haskell's L<Constant|http://hackage.haskell.org/package/transformers/docs/Data-Functor-Constant.html>
applicative functor.

This is an abstract class.
Subclasses must implement C<mempty()> and C<mconcat()> class methods,
which define the L<Monoid|http://hackage.haskell.org/package/base/docs/Data-Monoid.html> behind this class.

=head1 CLASS METHODS

=head2 build_result

See L<Data::Focus::Applicative>.

=head2 $f_datum = Data::Focus::Applicative::Const->new($datum)

=head2 $monoid = Data::Focus::Applicative::Const->mempty()

Must be implemented in subclasses.

=head2 $monoid = Data::Focus::Applicative::Const->mconcat(@monoids)

Must be implemented in subclasses.

=head1 OBJECT METHODS

=head2 $datum = $f_datum->get_const()

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut


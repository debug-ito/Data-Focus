package Data::Focus::Applicative::Identity;
use strict;
use warnings;
use parent qw(Data::Focus::Applicative);

sub new {
    my ($class, $datum) = @_;
    return bless \$datum, $class;
}

sub build_result {
    my ($class, $builder, $original, @f_parts) = @_;
    return (@f_parts == 0) ? $class->new($original)
        : $class->new($builder->($original, map { $_->run_identity } @f_parts));
    ## should we type-check @f_parts?
}

sub create_part_mapper {
    my ($class, $updater) = @_;
    return sub { $class->new($updater->(shift)) };
}

sub run_identity {
    return ${$_[0]};
}

1;
__END__

=pod

=head1 NAME

Data::Focus::Applicative::Identity - Identity applicative functor for Data::Focus

=head1 DESCRIPTION

B<< Internal use only. >>

A L<Data::Focus::Applicative> class for Haskell's L<Identity|http://hackage.haskell.org/package/transformers/docs/Data-Functor-Identity.html>
applicative functor.

=head1 CLASS METHODS

=head2 build_result

=head2 create_part_mapper

See L<Data::Focus::Applicative>.

=head2 $f_datum = Data::Focus::Applicative::Identity->new($datum)

=head1 OBJECT METHODS

=head2 $datum = $f_datum->run_identity()

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


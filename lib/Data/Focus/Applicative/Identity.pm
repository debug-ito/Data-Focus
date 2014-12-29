package Data::Focus::Applicative::Identity;
use strict;
use warnings;
use parent qw(Data::Focus::Applicative);

sub build_result {
    my ($class_self, $rebuilder, $original, @f_parts) = @_;
    return (@f_parts == 0) ? $original : $rebuilder->($original, @f_parts);
    ## In Identity applicative functor, f b = b, f t = t
}


1;
__END__

=pod

=head1 NAME

Data::Focus::Applicative::Identity - Identity applicative functor for Data::Focus

=head1 DESCRIPTION

B<< Internal use only. >>

An L<Data::Focus::Applicative> class for Haskell's L<Identity|http://hackage.haskell.org/package/transformers/docs/Data-Functor-Identity.html>
applicative functor.


=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


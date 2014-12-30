package Data::Focus::Applicative;
use strict;
use warnings;

1;
__END__

=pod

=head1 NAME

Data::Focus::Applicative - applicative functor spec for Data::Focus

=head1 DESCRIPTION

B<< Internal use only. >>

This class specifies the common interface for all applicative functors used in L<Data::Focus> distribution.

=head1 CLASS METHODS

=head2 $f_result = $class->build_result($builder, $original, @f_parts)

Build the C<$f_result> from C<$original> data and C<@f_parts> using C<$builder>.

In pseudo-Haskell, this is equivalent to

    build_result :: Applicative f => (s -> b -> b -> ... -> t) -> s -> [f b] -> f t
    build_result builder original f_parts =
      case f_parts of
        [] -> pure original
        (p:ps) -> builder original <$> p <*> (ps !! 0) <*> (ps !! 1) ...

I think this is the only pattern where applicative functors are used in Lens implementations.

C<$builder> is a code-ref, which may be called zero or more times

    $built_data = $builder->($original, @parts)

where C<@parts> are the data inside C<@f_parts> applicative functors.

C<$builder> is supposed to set C<@parts> into C<$original> (whether or not it's destructive),
and return the C<$built_data>.

C<@f_parts> are zero or more L<Data::Focus::Applicative> objects.
C<$f_result> is a L<Data::Focus::Applicative> object.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

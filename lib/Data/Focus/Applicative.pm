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

All applicative functors must inherit L<Data::Focus::Applicative>, and implement the following methods.


=head1 ABSTRACT CLASS METHODS

=head2 $f_result = $class->build_result($builder, $original, @f_parts)

Build the C<$f_result> from C<$original> data and C<@f_parts> using C<$builder>.

In pseudo-Haskell, this is equivalent to

    build_result :: Applicative f => (b -> b -> ... -> t) -> s -> [f b] -> f t
    build_result builder original f_parts =
      case f_parts of
        [] -> pure original
        (p:ps) -> builder <$> p <*> (ps !! 0) <*> (ps !! 1) ...

I think this is the only pattern where applicative functors are used in Lens implementations.

C<$builder> is a code-ref, which may be called zero or more times

    $built_data = $builder->(@parts)

where C<@parts> are the data inside C<@f_parts> applicative functors.

C<$builder> is supposed to set C<@parts> into C<$original> (whether or not it's destructive),
and return the C<$built_data>.

C<@f_parts> are zero or more L<Data::Focus::Applicative> objects.
C<$f_result> is a L<Data::Focus::Applicative> object.

=head2 $part_mapper = $class->create_part_mapper($updater)

Create the finest C<$part_mapper> for L<Data::Focus::Lens>.

In Haskell, this method is like

    create_part_mapper :: Applicative f => (a -> b) -> (a -> f b)

C<$updater> is a code-ref. This code-ref is supposed to modify the finest part and return the result.
Subclasses may or may not use C<$updater> to create C<$part_mapper>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

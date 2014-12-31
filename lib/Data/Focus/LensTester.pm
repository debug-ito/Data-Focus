package Data::Focus::LensTester;
use strict;
use warnings;

1;
__END__

=pod

=head1 NAME

Data::Focus::LensTester - tester for Lens implementations

=head1 SYNOPSIS

TODO: write this.

=head1 DESCRIPTION

L<Data::Focus::LensTester> tests common properties for all lenses called "lens laws".

Concepturally, the lens laws are described as follows.

=over

=item set-get law

    focus( focus($target)->set($lens, $part) )->get($lens) == $part

=item get-set law

    focus($target)->set( $lens, focus($target)->get($lens) ) == $target

=item set-set law

    focus( focus($target)->set($lens, $part1) )->set($lens, $part2) == focus($target)->set($lens, $part2)

=back

L<Data::Focus::LensTester> tests these laws with given set of C<$part>s.

=head2 Tests and Focal Points

Depending on how many focal points the lens creates on the target, L<Data::Focus::LensTester> decides which of the laws to be tested.

=over

=item 0 focal point

It tests "get-set" and "set-set" laws. "set-get" law cannot be met.

=item 1 focal point

It tests all three laws.

=item more than one focal points

It tests "set-get" and "set-set" laws.

In "set-get" law, the C<set()> method should set all focal points to the same value.

=back

=head1 CLASS METHODS

=head2 $tester = Data::Focus::LensTester->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<test_whole> => CODE (mandatory)

A code-ref that tests if two "whole" data are the same.
A whole data is a data whose level of complexity is the same as the target data.

This code-ref is called like:

    $test_whole->($whole1, $whole2)

C<$test_whole> must test equality between C<$whole1> and C<$whole2> in a L<Test::More> way.

=item C<test_part> => CODE (mandatory)

A code-ref that tests if two "part" data are the same.
A part data is a data that can be included in a whole data.

This code-ref is called like:

    $test_part->($part1, $part2)

C<$test_part> must test equality between C<$part1> and C<$part2> in a L<Test::More> way.

=item C<parts> => ARRAYREF_OF_PARTS (mandatory)

List of "part" data used for testing. At least two parts are necessary.

=back

=head1 OBJECT METHODS

=head2 $tester->test_lens(%args)

Test a L<Data::Focus::Lens> object to see if it follows the lens law.

Fields in C<%args> are:

=over

=item C<lens> => L<Data::Focus::Lens> object (mandatory)

The lens to be tested.

=item C<target> => CODE (mandatory)

A code-ref that returns the target object. It is called without argument.

    $target_data = $target->()

The C<$target> code-ref must return a brand-new C<$target_data> object for every call.

=item C<exp_focal_points> => INT (mandatory)

Expected number of focal points the lens creates for the target.

=item C<exp_mutate> => BOOL (mandatory)

If set to true, the lens is expected to mutate the target itself (destructive update).
If set to false, the lens is expected to preserve the target (non-destructive update).

=back

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

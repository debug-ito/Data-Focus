package Data::Focus::LensTester;
use strict;
use warnings;
use Carp;
use Test::More;
use Data::Focus qw(focus);
use Scalar::Util qw(refaddr);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        map { ($_ => $args{$_}) } qw(test_whole test_part parts)
    }, $class;
    foreach my $key (qw(test_whole test_part)) {
        croak "$key must be a code-ref" if ref($self->{$key}) ne "CODE";
    }
    croak "parts must be an array-ref" if ref($self->{parts}) ne "ARRAY";
    return $self;
}

sub test_lens {
    my ($self, %args) = @_;
    my $lens = $args{lens};
    croak "lens must be Data::Focus::Lens object" if !eval { $lens->isa("Data::Focus::Lens") };
    my $target = $args{target};
    croak "target must be a code-ref" if ref($target) ne "CODE";
    my $exp_focal_points = $args{exp_focal_points};
    croak "exp_focal_points must be Int" if !defined($exp_focal_points) || $exp_focal_points !~ /^\d+$/;
    my $exp_mutate = $args{exp_mutate};

    subtest "focal points" => sub {
        my @ret = focus($target->())->list($lens);
        is scalar(@ret), $exp_focal_points, "list() returns $exp_focal_points focal points";
    };

    $self->_test_set_set($target, $lens, $exp_focal_points, $exp_mutate);
    if($exp_focal_points == 0) {
        $self->_test_get_set($target, $lens, $exp_focal_points, $exp_mutate);
    }elsif($exp_focal_points == 1) {
        $self->_test_get_set($target, $lens, $exp_focal_points, $exp_mutate);
        $self->_test_set_get($target, $lens, $exp_focal_points, $exp_mutate);
    }else {
        $self->_test_set_get($target, $lens, $exp_focal_points, $exp_mutate);
    }
}

sub _test_set_set {
    my ($self, $target, $lens, $exp_focal_points, $exp_mutate) = @_;
    subtest "set-set law" => sub {
        foreach my $i1 (0 .. $#{$self->{parts}}) {
            foreach my $i2 (0 .. $#{$self->{parts}}) {
                next if $i1 == $i2;
                my ($part1, $part2) = @{$self->{parts}}[$i1, $i2];
                my $left_target = $target->();
                my $right_target = $target->();
                my $left_result = focus( focus($left_target)->set($lens, $part1) )->set($lens, $part2);
                my $right_result = focus($right_target)->set($lens, $part2);
                $self->{test_whole}->($left_result, $right_result);
                _check_mutate("left", $left_target, $left_result, $exp_mutate, $exp_focal_points);
                _check_mutate("right", $right_target, $right_result, $exp_mutate, $exp_focal_points);
            }
        }
    };
}

sub _check_mutate {
    my ($label, $original, $result, $exp_mutate, $exp_focal_points) = @_;
    if(defined($exp_mutate) && $exp_focal_points > 0) {
        ## if there's no focal point, the result is the same object as the target.
        if($exp_mutate) {
            is(refaddr($original), refaddr($result), "$label: mutated");
        }else {
            isnt(refaddr($original), refaddr($result), "$label: not mutated");
        }
    }
}

sub _test_set_get {
    my ($self, $target, $lens, $exp_focal_points, $exp_mutate) = @_;
    subtest "set-get law" => sub {
        foreach my $part (@{$self->{parts}}) {
            my $left_target = $target->();
            my $left_set = focus($left_target)->set($lens, $part);
            my @left_parts = focus($left_set)->list($lens);
            $self->{test_part}->($_, $part) foreach @left_parts;
            _check_mutate("set_get", $left_target, $left_set, $exp_mutate, $exp_focal_points);
        }
    };
}

sub _test_get_set {
    my ($self, $target, $lens, $exp_focal_points, $exp_mutate) = @_;
    subtest "get-set law" => sub {
        foreach my $part (@{$self->{parts}}) {
            my $left_target = $target->();
            my $left_result = focus($left_target)->set($lens, focus($left_target)->get($lens));
            $self->{test_whole}->($left_result, $left_target);
            _check_mutate("get_set", $left_target, $left_result, $exp_mutate, $exp_focal_points);
        }
    };
}

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

=item C<exp_mutate> => BOOL (optional)

If set to true, the lens is expected to mutate the target itself (destructive update).
The setter methods should return the same instance as the target.

If set to false, the lens is expected to preserve the target (non-destructive update).
The setter methods should return a different instance from the target.

If not specified, the mutation check is not performed.

=back

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

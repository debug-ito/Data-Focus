package Data::Focus::Lens::HashArrayIndex;
use strict;
use warnings;
use parent qw(Data::Focus::Lens);
use Carp;

our @CARP_NOT = qw(Data::Focus::Lens Data::Focus);

sub new {
    my ($class, %args) = @_;
    my $keys = [];
    if(exists($args{key})) {
        if(ref($args{key}) eq "ARRAY") {
            $keys = $args{key};
        }else {
            $keys = [$args{key}];
        }
    }
    croak "key must be mandatory" if !@$keys;
    croak "key must be defined" if grep { !defined($_) } @$keys;
    my $self = bless {
        keys => $keys,
        immutable => $args{immutable},
    }, $class;
    return $self;
}

{
    my $getter = sub {
        my ($self, $whole) = @_;
        my $type = ref($whole);
        if(!defined($whole)) {
            ## slots for autovivification
            return map { undef } @{$self->{keys}};
        }elsif($type eq "ARRAY") {
            foreach my $key (@{$self->{keys}}) {
                if($key !~ /^\d+$/) {
                    croak "Key $key: The target is an ARRAY. Key must be integer.";
                }
            }
            return @{$whole}[@{$self->{keys}}];
        }elsif($type eq "HASH") {
            return @{$whole}{@{$self->{keys}}};
        }else {
            ## no slot. cannot set.
            return ();
        }
    };
    
    my $setter = sub {
        my ($self, $whole, @parts) = @_;
        if(!defined($whole)) {
            ## autovivifying
            if(grep { $_ !~ /^\d+$/ } @{$self->{keys}}) {
                return +{ map { $self->{keys}[$_] => $parts[$_] } 0 .. $#{$self->{keys}} };
            }else {
                my $ret = [];
                $ret->[$self->{keys}[$_]] = $parts[$_] foreach 0 .. $#{$self->{keys}};
                return $ret;
            }
        }
        my $type = ref($whole);
        if($type eq "ARRAY") {
            foreach my $key (@{$self->{keys}}) {
                if($key !~ /^\d+$/) {
                    croak "Key $key: The target is an ARRAY. Key must be integer.";
                }
            }
            $whole->[$self->{keys}[$_]] = $parts[$_] foreach 0 .. $#{$self->{keys}}; ## destructive
            return $whole;
        }elsif($type eq "HASH") {
            $whole->{$self->{keys}[$_]} = $parts[$_] foreach 0 .. $#{$self->{keys}}; ## destructive
            return $whole;
        }else {
            confess "This should not be executed because the getter should return an empty list.";
        }
    };

    sub apply {
        my ($self, $part_mapper, $applicative_class) = @_;
        return sub {
            my ($whole) = @_;
            my @parts = $self->$getter($whole);
            return $applicative_class->build_result(sub {
                $self->$setter(@_)
            }, $whole, map { $part_mapper->($_) } @parts);
        };
    }
}

1;

__END__

=pod

=head1 NAME

Data::Focus::Lens::HashArrayIndex - a lens to focus on element(s) of hash/array

=head1 DESCRIPTION

This is an implementation of L<Data::Focus::Lens>,
which focuses on one or more elements in hashes and arrays.

Conceptually, this lens does the same as hash/array dereferences and slices.

    $hash->{key}
    @{$hash}{qw(key1 key2 key3)}
    $array->[4]
    @{$array}[3,4,5]

This lens never autovivifies when reading, while by default it DOES autovivify when writing.

Detailed behaviors of this lens are described below for each target type.

=head2 HASH target

If the target is a hash-ref, this lens bahaves as hash dereference and slice.

Duplicate keys in a slice are allowed.
If different values are set to those keys, only the last one takes effect.

## TBW: non-existent keys?

=head2 ARRAY target

If the target is an array-ref, this lens bahaves as array dereference and slice.
The keys are cast to integers.

Positive out-of-range indices are allowed.
C<get()> and C<list()> returns C<undef> for those indices.
When set, it extends the array.

Negative indices are allowed.
They create focal points from the end of the array,
i.e., index of C<-1> means the last element in the array.

Out-of-range negative indices are read-only.
They always return C<undef>.
If you try to set values, it croaks.

Duplicate indices in a slice are allowed.
If different values are set to those indices, only the last one takes effect.

## TBW: non-existent keys?

=head2 undef target

## TBW: how to autovivify?

=head2 other targets

## TBW: no focal point for those cases.

=head1 CLASS METHODS

=head2 $lens = Data::Focus::Lens::HashArrayIndex->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<key> => STR or ARRAYREF_OF_THEM (mandatory)

Key to focus. When you specify an array-ref, the C<$lens> behaves like slice.

=item C<immutable> => BOOL (optional, default: false)

If set to true, the target hash/array is treated as immutable.
This means every updating operation using the C<$lens> creates a new hash/array in a copy-on-write fashion.

=item ???

## TODO: Option to change handling of non-existent keys. I think it affects $focused->list() and setters (autovivification when writing). How should we name it?

=back

=head1 OBJECT METHODS

=head2 apply

See L<Data::Focus::Lens>.

=head1 TODO

Maybe we could use less featured and faster version of this, like Data::Focus::Lens::HashArrayIndex::Lite.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

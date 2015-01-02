package Data::Focus::Lens::HashArray::Index;
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
            my @indices = map { int($_) } @{$self->{keys}};
            return @{$whole}[@indices];
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
            my @indices = map { int($_) } @{$self->{keys}};
            $whole->[$indices[$_]] = $parts[$_] foreach 0 .. $#indices; ## destructive
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

Data::Focus::Lens::HashArray::Index - a lens to focus on element(s) of hash/array

=head1 DESCRIPTION

This is an implementation of L<Data::Focus::Lens>,
which focuses on one or more elements in a hash or array.

Conceptually, this lens does the same as hash/array dereferences and slices.

    $hash->{key}
    @{$hash}{qw(key1 key2 key3)}
    $array->[4]
    @{$array}[3,4,5]

This lens never autovivifies when reading, while it DOES autovivify when writing.

Detailed behaviors of this lens are described below for each target type.

=head2 HASH target

If the target is a hash-ref, this lens behaves as hash dereference and slice.

Duplicate keys in a slice are allowed.
If different values are set to those keys, only the last one takes effect.

It returns C<undef> for non-existent keys. You can set values for them.

=head2 ARRAY target

If the target is an array-ref, this lens behaves as array dereference and slice.
The keys are cast to integers.

Positive out-of-range indices are allowed.
C<get()> and C<list()> return C<undef> for those indices.
When set, it extends the array.

Negative indices are allowed.
They create focal points from the end of the array,
e.g., index of C<-1> means the last element in the array.

Negative out-of-range indices are read-only.
They always return C<undef>.
If you try to set values, it croaks.

Duplicate indices in a slice are allowed.
If different values are set to those indices, only the last one takes effect.

=head2 undef target

When reading, it always returns C<undef>.

When writing, it autovivifies if the written value is defined. It does not autovivify if the written value is C<undef>.

When autovivifying, it creates  an array-ref if and only if the keys are all non-negative integers.
Otherwise, it creates a hash-ref.

=head2 other targets

For other types of targets including scalar-refs and blessed objects,
the lens creates no focal point.
This means C<get()> returns C<undef> and C<set()> does nothing.

=head1 CLASS METHODS

=head2 $lens = Data::Focus::Lens::HashArray::Index->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<key> => STR or ARRAYREF_OF_THEM (mandatory)

Key to focus. When you specify an array-ref, the C<$lens> behaves like slice.

=item C<immutable> => BOOL (optional, default: false)

If set to true, the target hash/array is treated as immutable.
This means every updating operation using the C<$lens> creates a new hash/array in a copy-on-write fashion.

=back

=head1 OBJECT METHODS

=head2 apply

See L<Data::Focus::Lens>.

=head1 TODO

Maybe we could use less featured and faster version of this, like Data::Focus::Lens::HashArray::Index::Lite.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

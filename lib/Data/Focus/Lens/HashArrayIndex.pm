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
            confess "This should not be executed. Something is wrong.";
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

This lens never autovivifies when reading, while it DOES autovivify when writing by default.

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

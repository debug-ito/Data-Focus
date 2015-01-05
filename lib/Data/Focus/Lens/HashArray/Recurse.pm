package Data::Focus::Lens::HashArray::Recurse;
use strict;
use warnings;
use parent qw(Data::Focus::Lens);
use Sub::Recursive qw(recursive $REC);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        immutable => !!$args{immutable}
    }, $class;
    return $self;
}

sub _set_array {
    my ($self, $whole, @parts) = @_;
    if($self->{immutable}) {
        return \@parts;
    }else {
        @$whole = @parts;
        return $whole;
    }
}

sub _set_hash {
    my ($self, $whole, $keys, @parts) = @_;
    my $ret = $self->{immutable} ? {%$whole} : $whole;
    $ret->{$keys->[$_]} = $parts[$_] foreach 0 .. $#$keys;
    return $ret;
}

sub apply {
    my ($self, $part_mapper, $app_class) = @_;
    return recursive {
        my ($data) = @_;
        my $type = ref($data);
        if($type eq "ARRAY") {
            my @fparts = map { $REC->($_) } @$data;
            return $app_class->build_result(sub {
                my $data = shift;
                return $self->_set_array($data, @_);
            }, $data, @fparts);
        }elsif($type eq "HASH") {
            my @keys = keys %$data;
            my @fparts = map { $REC->($_) } @{$data}{@keys};
            return $app_class->build_result(sub {
                my $data = shift;
                return $self->_set_hash($data, \@keys, @_);
            }, $data, @fparts);
        }else {
            return $part_mapper->($data);
        }
    };
}

1;
__END__

=pod

=head1 NAME

Data::Focus::Lens::HashArray::Recurse - recursively traverse a tree of hashes and arrays

=head1 SYNOPSIS

    use Data::Focus qw(focus);
    use Data::Focus::Lens::HashArray::Recurse;
    
    my $target = [
        {foo => 1, bar => 2},
        3,
        [4, 5, 6],
        [],
        {}
        {hoge => 7}
    ];
    
    my $lens = Data::Focus::Lens::HashArray::Recurse->new;
    
    my $result = focus($target)->over($lens, sub { $_[0] * 100 });
    
    ## $result is:
    ## [
    ##     {foo => 100, bar => 200},
    ##     300,
    ##     [400, 500, 600],
    ##     [],
    ##     {},
    ##     {hoge => 700}
    ## ]

=head1 DESCRIPTION

L<Data::Focus::Lens::HashArray::Recurse> is a L<Data::Focus::Lens> class
that recursively traverses a data structure made of hashes and arrays.
It creates focal points on everything it finds on the traversal.

The traversal is depth-first.
Siblings in a hash are traversed in random order.
Siblings in an array are traversed from the index 0.

=head1 CLASS METHODS

=head2 $lens = Data::Focus::Lens::HashArray::Recurse->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<immutable> => BOOL (optional, default: false)

If set to true, the target hash/array is treated as immutable.
This means every updating operation using the C<$lens> creates a new hash/array in a copy-on-write fashion.

=back

=head1 OBJECT METHODS

=head2 apply

See L<Data::Focus::Lens>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>

=cut

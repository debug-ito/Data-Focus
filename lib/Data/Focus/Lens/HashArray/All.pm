package Data::Focus::Lens::HashArray::All;
use strict;
use warnings;
use parent qw(Data::Focus::Lens);
use Carp;
use Data::Focus::LensMaker ();

sub new {
    my ($class, %args) = @_;
    return bless {
        immutable => !!$args{immutable}
    }, $class;
}

sub _getter {
    my ($self, $whole) = @_;
    my $type = ref($whole);
    if($type eq "ARRAY") {
        return @$whole;
    }elsif($type eq "HASH") {
        my @keys = sort keys %$whole;
        return @{$whole}{@keys};
    }else {
        return ();
    }
}

sub _setter {
    my ($self, $whole, @parts) = @_;
    my $type = ref($whole);
    if($type eq "ARRAY") {
        if($self->{immutable}) {
            return \@parts;
        }else {
            @$whole = @parts;
            return $whole;
        }
    }elsif($type eq "HASH") {
        my @keys = sort keys %$whole;
        my $ret = $self->{immutable} ? {%$whole} : $whole;
        $ret->{$keys[$_]} = $parts[$_] foreach 0 .. $#keys;
        return $ret;
    }else {
        confess "This should not happen because there should be no focal point.";
    }
}

Data::Focus::LensMaker::make_lens_from_accessors(\&_getter, \&_setter);


1;
__END__

=pod

=head1 NAME

Data::Focus::Lens::HashArray::All - focus on all elements in a hash/array

=head1 SYNOPSIS

    use Data::Focus qw(focus);
    use Data::Focus::Lens::HashArray::All;
    
    my $lens = Data::Focus::Lens::HashArray::All->new;
    my $hash = {foo => 1, bar => 2};
    
    my $result_hash = focus($hash)->over($lens, sub { $_[0] * 10 });
    
    ## $result_hash: {foo => 10, bar => 20}
    
    my $array = [1, 2, 3];
    my $result_array = focus($array)->over($lens, sub { $_[0] * 100 });
    
    ## $result_array: [100, 200, 300]

=head1 DESCRIPTION

L<Data::Focus::Lens::HashArray::All> is a L<Data::Focus::Lens> class that focuses on all elements (values) in a hash or array.
If the hash or array has no element, it creates no focal point.

If the target is not a hash or array, it creates no focal point.

=head1 CLASS METHODS

=head2 $lens = Data::Focus::Lens::HashArray::All->new(%args)

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

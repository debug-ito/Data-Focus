package Data::Focus::Lens::Composite;
use strict;
use warnings;
use parent qw(Data::Focus::Lens);
use Data::Focus::Util;

sub new {
    my ($class, @lenses) = @_;
    return bless \@lenses, $class;
}

sub apply {
    my ($self, $part_mapper, $applicative_class) = @_;
    return Data::Focus::Util::create_whole_mapper($applicative_class, $part_mapper, @$self);
}


1;
__END__

=pod

=head1 NAME

Data::Focus::Lens::Composite - a lens composed of multiple lenses

=head1 SYNOPSIS

    my $composite1 = Data::Focus::Lens::Composite->new($lens1, $lens2, $lens3);
    
    ## or
    
    my $composite2 = $lens1 . $lens2 . $lens3;
    
    ## Then, you can write
    
    my $value1 = focus($target)->get($composite1);
    my $value2 = focus($target)->get($composite2);
    
    ## instead of
    
    my $value3 = focus($target)->get($lens1, $lens2, $lens3);

    ## $value1 == $value2 == $value3

=head1 DESCRIPTION

L<Data::Focus::Lens::Composite> is a L<Data::Focus::Lens> class that is composed of multiple lenses.

=head1 CLASS METHODS

=head2 $composite = Data::Focus::Lens::Composite->new(@lenses)

Compose C<@lenses> to create a C<$composite> lens.

C<@lenses> are composed in the same order as you pass them to C<into()>, C<get()> etc methods of L<Data::Focus>.

If C<@lenses> is empty, it returns a no-op lens.

=head1 OBJECT METHODS

=head2 apply

See L<Data::Focus::Lens>.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

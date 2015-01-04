package Data::Focus::Lens::Composite;
use strict;
use warnings;


1;
__END__

=pod

=head1 NAME

Data::Focus::Lens::Composite - a lens composed of multiple lenses

=head1 SYNOPSIS

    my $composite = Data::Focus::Lens::Composite->new($lens1, $lens2, $lens3);
    
    ## or
    
    my $composite = $lens1->compose($lens2, $lens3);
    
    ## or
    
    my $composite = $lens1 . $lens2 . $lens3;
    
    ## Then, you can write
    
    my $value = focus($target)->get($composite);
    
    ## instead of
    
    my $value = focus($target)->get($lens1, $lens2, $lens3);

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

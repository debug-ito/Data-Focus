package Data::Focus;
use strict;
use warnings;

our $VERSION = "0.01";

1;
__END__

=pod

=head1 NAME

Data::Focus - generic getter/setter/traverser for complex data structures

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EXPORTABLE FUNCTIONS

These functions are exported only by request.

=head2 $focused = focus($target, @lenses)

Alias of C<< Data::Focus->new(target => $target, lens => \@lenses) >>.
It creates a L<Data::Focus> object. C<@lenses> are optional.

=head1 CLASS METHODS

=head2 $focused = Data::Focus->new(%args)

The constructor. Fields in C<%args> are:

=over

=item C<target> => SCALAR (mandatory)

=item C<lens> => LENS or ARRAYREF_OF_LENSES (optional)

=back

=head1 OBJECT METHODS

=head2 $deeper_focused = $focused->into(@lenses)

=head2 $datum = $focused->get(@lenses)

=head2 @data = $focused->list(@lenses)

=head2 $modified_target = $focused->set(@lenses, $datum)

=head2 $modified_target = $focused->over(@lenses, $updater)

=head1 SEE ALSO

=head1 REPOSITORY

L<https://github.com/debug-ito/Data-Focus>

=head1 BUGS AND FEATURE REQUESTS

Please report bugs and feature requests to my Github issues
L<https://github.com/debug-ito/Data-Focus/issues>.

Although I prefer Github, non-Github users can use CPAN RT
L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Focus>.
Please send email to C<bug-Data-Focus at rt.cpan.org> to report bugs
if you do not have CPAN RT account.


=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Toshio Ito.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut


package Data::Focus;
use strict;
use warnings;
use Data::Focus::Lens::HashArrayIndex;
use Carp;

our $VERSION = "0.01";

sub new {
    my ($class, %args) = @_;
    croak "target param is mandatory" if !exists($args{target});
    my $target = $args{target};
    my $lenses = [];
    if(exists($args{lens})) {
        if(ref($args{lens}) eq "ARRAY") {
            $lenses = $args{lens};
        }else {
            $lenses = [$args{lens}];
        }
    }
    @$lenses = map {
        eval { $_->isa("Data::Focus::Lens") }
            ? $_
            : Data::Focus::Lens::HashArrayIndex->new(key => $_)  ## default lens (for now)
    } @$lenses;
    my $self = bless {
        target => $target,
        lenses => $lenses
    }, $class;
    return $self;
}

sub into {
    my ($self, @lenses) = @_;
    my $deeper = ref($self)->new(
        target => $self->{target},
        lens => [@{$self->{lenses}}, @lenses]
    );
    return $deeper;
}

sub _create_whole_mapper {
    my ($app_class, @lenses) = @_;
    my $part_mapper = sub { $app_class->new(shift) };
    while(defined(my $lens = pop @lenses)) {
        $part_mapper = $lens->apply($part_mapper, $app_class);
    }
    return $part_mapper;
}

sub get {
    my ($self, @lenses) = @_;
    require Data::Focus::Applicative::Const::First;
    my $whole_mapper = _create_whole_mapper("Data::Focus::Applicative::Const::First", @{$self->{lenses}}, @lenses);
    return $whole_mapper->($self->{target})->get_const;
}

sub list {
    my ($self, @lenses) = @_;
    require Data::Focus::Applicative::Const::List;
    my $whole_mapper = _create_whole_mapper("Data::Focus::Applicative::Const::List", @{$self->{lenses}}, @lenses);
    my $traversed_list = $whole_mapper->($self->{target})->get_const;
    return wantarray ? @$traversed_list : $traversed_list->[0];
}

sub over {
    my $updater = pop;
    my ($self, @lenses) = @_;
    TBW;
}

sub set {
    my $datum = pop;
    my $self = shift;
    return $self->over(@_, sub { $datum });
}

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


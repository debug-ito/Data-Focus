package Data::Focus;
use strict;
use warnings;
use Data::Focus::Lens::HashArray::Index;
use Carp;
use Exporter qw(import);

our $VERSION = "0.01";

our @EXPORT_OK = qw(focus);

sub focus {
    my ($target, @lenses) = @_;
    return __PACKAGE__->new(target => $target, lens => \@lenses);
}

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
    @$lenses = map { _coerce_to_lens($_) } @$lenses;
    my $self = bless {
        target => $target,
        lenses => $lenses
    }, $class;
    return $self;
}

sub _coerce_to_lens {
    my ($maybe_lens) = @_;
    eval { $maybe_lens->isa("Data::Focus::Lens") }
        ? $maybe_lens
        : Data::Focus::Lens::HashArray::Index->new(key => $maybe_lens);  ## default lens (for now)
}

sub into {
    my ($self, @lenses) = @_;
    my $deeper = ref($self)->new(
        target => $self->{target},
        lens => [@{$self->{lenses}}, map { _coerce_to_lens($_) } @lenses]
    );
    return $deeper;
}

sub _create_whole_mapper {
    my ($self, $app_class, $updater, @additional_lenses) = @_;
    my @lenses = (@{$self->{lenses}}, map { _coerce_to_lens($_) } @additional_lenses);
    my $part_mapper = $app_class->create_part_mapper($updater);
    while(defined(my $lens = pop @lenses)) {
        $part_mapper = $lens->apply($part_mapper, $app_class);
    }
    return $part_mapper;
}

sub get {
    my ($self, @lenses) = @_;
    require Data::Focus::Applicative::Const::First;
    my $whole_mapper = $self->_create_whole_mapper("Data::Focus::Applicative::Const::First", undef,
                                                   @lenses);
    my $ret = $whole_mapper->($self->{target})->get_const;
    return defined($ret) ? $$ret : undef;
}

sub list {
    my ($self, @lenses) = @_;
    require Data::Focus::Applicative::Const::List;
    my $whole_mapper = $self->_create_whole_mapper("Data::Focus::Applicative::Const::List", undef,
                                                   @lenses);
    my $traversed_list = $whole_mapper->($self->{target})->get_const;
    return wantarray ? @$traversed_list : $traversed_list->[0];
}

sub over {
    my $updater = pop;
    my ($self, @lenses) = @_;
    croak "updater param must be a code-ref" if ref($updater) ne "CODE";
    require Data::Focus::Applicative::Identity;
    my $whole_mapper = $self->_create_whole_mapper("Data::Focus::Applicative::Identity", $updater,
                                                   @lenses);
    return $whole_mapper->($self->{target})->run_identity;
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

- The concept of "focused", "target", "lenses".

=head2 Lenses

=head2 Lens Coercion

=head2 Traversals and Focal Points

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

Focus more deeply with the given C<@lenses> and return the L<Data::Focus> object.

C<$deeper_focused> is a new L<Data::Focus> object. C<$focused> remains unchanged.

For example, these lines do exactly the same thing.

    $result = $focused->into("foo", "bar")->get();
    $result = $focused->into("foo")->get("bar");
    $result = $focused->get("foo", "bar");

=head2 $datum = $focused->get(@lenses)

Get the focused C<$datum>.

The arguments C<@lenses> are optional.
If supplied, C<@lenses> are used to focus more deeply into the C<$focused> to return C<$datum>.

If it focuses on nothing (zero focal point), it returns C<undef>.

If it focuses on more than one values (multiple focal points), it returns the first value.

=head2 @data = $focused->list(@lenses)

Get the focused C<@data>.

The arguments C<@lenses> are optional.
If supplied, C<@lenses> are used to focus more deeply into the C<$focused> to return C<@data>.

If it focuses on nothing (zero focal point), it returns an empty list.

If it focuses on more than one values (multiple focal points), it returns all of them.

=head2 $modified_target = $focused->set(@lenses, $datum)

Set the focused value of the target to C<$datum>, and return the C<$modified_target>.

The arguments C<@lenses> are optional.
If supplied, C<@lenses> are used to focus more deeply into the C<$focused> to set the C<$datum>.

If it focuses on nothing (zero focal point), it modifies nothing. C<$modified_target> is exactly the same as the target object.

If it focuses on more than one values (multiple focal points), it sets all of them to C<$datum>.

=head2 $modified_target = $focused->over(@lenses, $updater)

Update the focused value of the target by C<$updater>, and return the C<$modified_target>.

The arguments C<@lenses> are optional.
If supplied, C<@lenses> are used to focus more deeply into the C<$focused> to execute C<$updater>.

C<$updater> is a code-ref. It is called like

    $modified_datum = $updater->($focused_datum)

where C<$focused_datum> is a datum in the target focused by the lenses.
C<$modified_datum> replaces the C<$focused_datum> in the C<$modified_target>.

If it focuses on nothing (zero focal point), C<$updater> is never called. C<$modified_target> is exactly the same as the target object.

If it focuses on more than one values (multiple focal points), C<$updater> is repeatedly called for each of them.
So C<$updater> should not have side-effects.

=head1 RELATIONSHIP TO HASKELL

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


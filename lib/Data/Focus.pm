package Data::Focus;
use strict;
use warnings;
use Data::Focus::Util qw(coerce_to_lens);
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
    @$lenses = map { coerce_to_lens($_) } @$lenses;
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
        lens => [@{$self->{lenses}}, map { coerce_to_lens($_) } @lenses]
    );
    return $deeper;
}

sub _create_whole_mapper {
    my ($self, $app_class, $updater, @additional_lenses) = @_;
    my @lenses = (@{$self->{lenses}}, map { coerce_to_lens($_) } @additional_lenses);
    return Data::Focus::Util::create_whole_mapper($app_class, $app_class->create_part_mapper($updater), @lenses);
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

TODO

=head1 DESCRIPTION

B<tl;dr>: This is a port of Haskell's L<lens-family-core|http://hackage.haskell.org/package/lens-family-core> package.

L<Data::Focus> provides a way to access data elements in a deep, complex and nested data structure.
So it's just a complicated version of L<Data::Diver>, but L<Data::Focus> has the following notable features.

=over

=item *

It provides a B<< generic way >> to access B<any> type of objects as long as they have appropriate "lenses".
It's like L<DBI> for data access.

=item *

It makes it easy to update B<immutable> objects. Strictly speaking, that means creating B<partially> modified copies of immutable objects.

=back

=head2 Concept

L<Data::Focus> focuses on some data parts in a complex data structure.
The complex data is called the B<target>.
With L<Data::Focus>, you can get/set/modify the data parts it focuses on.

L<Data::Focus> uses objects called B<lenses> to focus on data parts.
Lenses are like DBD::* modules for L<DBI> framework.
They know how to focus on the data parts in the target.
Different lenses are used to focus into different types of targets.

For example, consider the following code.

    my $target = { foo => "bar" };
    my $part = $target->{foo};
    $target->{foo} = "buzz";

In Perl, we can access the data part (C<"bar">) in the C<$target> by the subscript C<< ->{foo} >>.
A lens's job is exactly what C<< ->{foo} >> does here.

With L<Data::Focus> we can rewrite the above example to:

    use Data::Focus qw(focus);
    use Data::Focus::Lens::HashArray::Index;
    
    my $target = { foo => "bar" };
    my $lens = Data::Focus::Lens::HashArray::Index->new(key => "foo");
    my $part = focus($target)->get($lens);
    focus($target)->set($lens, "buzz");

I'm sure you don't wanna write this amount of code just to access an element in a hash. Be patient. I'll shorten them below.

#### =head2 Terminology

## The concept of "target" and "lenses". Data::Focus contains them.

## lenses are like DBD::* modules for DBI

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

=head1 HOW TO CREATE A LENS

=head1 RELATIONSHIP TO HASKELL

=head1 SEE ALSO

=over

=item *

L<Data::Diver>

=item *

L<JSON::Pointer>

=item *

L<Data::Path>

=item *

L<Data::SPath>

=item *

L<Data::DPath>

=item *

L<Data::FetchPath>

=item *

L<Data::PathSimple>

=item *

L<Data::SimplePath>

=item *

L<Data::Transformer>

=item *

L<Data::Walk>

=item *

L<Data::Traverse>

=back

=head1 TODO

=over

=item *

Option to expect specific number of focal points.
If it fails, it croaks.
(Haskell's statically typed Lens always has exactly one focal point. Maybe it's not Perl-friendly, though...)

=back

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

Copyright 2015 Toshio Ito.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut


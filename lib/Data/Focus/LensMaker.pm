package Data::Focus::LensMaker;
use strict;
use warnings;
use Exporter qw(import);
use Carp;

our @EXPORT_OK = qw(make_lens_from_accessors);

sub make_lens_from_accessors {
    my ($getter, $setter) = @_;
    my $calling_package = caller;
    confess "Top level call. Something is wrong." if !defined($calling_package);
    {
        no strict "refs";
        *{"${calling_package}::apply"} = _create_apply_from_accessors($getter, $setter);
    }
}

sub _create_apply_from_accessors {
    my ($getter, $setter) = @_;
    return sub {
        my ($self, $part_mapper, $applicative_class) = @_;
        return sub {
            my ($whole) = @_;
            my @parts = $self->$getter($whole);
            return $applicative_class->build_result(sub {
                my $ret = $self->$setter(@_);
                return $ret;
            }, $whole, map { $part_mapper->($_) } @parts);
        };
    };
}


1;
__END__

=pod

=head1 NAME

Data::Focus::LensMaker - utility to make your own lens

=head1 SYNOPSIS

    package Person;
    
    sub new {
        my ($class, $first_name, $last_name) = @_;
        return bless {
            first_name => $first_name,
            last_name => $last_name,
        }, $class;
    }
    
    sub first_name {
        my $self = shift;
        $self->{first_name} = $_[0] if @_;
        return $self->{first_name};
    }
    
    package Person::Lens::FirstName;
    use parent qw(Data::Focus::Lens);
    use Data::Focus::LensMaker qw(make_lens_from_accessors);
    
    sub new {
        my ($class) = @_;
        my $self;
        return bless \$self, $class;
    }
    
    sub _getter {
        my ($self, $target) = @_;
        return $target->first_name;
    }
    
    sub _setter {
        my ($self, $target, $set) = @_;
        $target->first_name($set);
        return $target;
    }
    
    make_lens_from_accessors(\&_getter, \&_setter);

=head1 DESCRIPTION

L<Data::Focus::LensMaker> is a helper module to create lens classes.

=head1 EXPORTABLE FUNCTIONS

The following functions are exported only by request.

=head2 make_lens_from_accessors($getter, $setter)

Generate necessary methods from C<$getter> and C<$setter>, and install them in the calling package.
See L</SYNOPSIS> for usage.

C<$getter> and C<$setter> are code-refs. They are supposed to be getter and setter methods defined in your lens class, respectively.

C<$getter> is supposed to extract the focused parts from the target data.

    @parts = $lens_self->$getter($target)

C<$getter> is called in the list context.
The number of C<@parts> determines the number of focal points the lens creates on the C<$target>.
If an empty list is returned, it means there's no focal point and nothing can be set there.

C<$setter> is supposed to set parts into the C<$target>, and return the result.

    $modified_target = $lens_self->$setter($target, @parts)

where C<@parts> are the data parts to be set to the C<$target>.
C<@parts> has the same length and order as the one retuned by C<$getter>.

It's up to the C<$setter> whether the operation is destructive or not.
If you modify the C<$target> itself in the C<$setter>, the lens is destructive.

=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=cut

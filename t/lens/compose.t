use strict;
use warnings FATAL => "all";
use Test::More;
use Data::Focus qw(focus);
use Data::Focus::Lens::HashArray::Index;
use Data::Focus::Lens::Composite;

sub lens {
    my ($key) = @_;
    Data::Focus::Lens::HashArray::Index->new(key => $key);
}

my $target = {
    foo => [
        {bar => "buzz"}
    ]
};
my $lens1 = lens("foo");
my $lens2 = lens(0);
my $lens3 = lens("bar");

{
    note("--- synopsis");
    ####
    my $composite1 = Data::Focus::Lens::Composite->new($lens1, $lens2, $lens3);
    
    ## or
    
    my $composite2 = $lens1->compose($lens2, $lens3);
    
    ## or
    
    my $composite3 = $lens1 . $lens2 . $lens3;
    
    ## Then, you can write
    
    my $value1 = focus($target)->get($composite1);
    my $value2 = focus($target)->get($composite2);
    my $value3 = focus($target)->get($composite3);
    
    ## instead of
    
    my $value = focus($target)->get($lens1, $lens2, $lens3);

    ####
    isa_ok $composite1, "Data::Focus::Lens";
    isa_ok $composite1, "Data::Focus::Lens::Composite";
    isa_ok $composite2, "Data::Focus::Lens";
    isa_ok $composite2, "Data::Focus::Lens::Composite";
    isa_ok $composite3, "Data::Focus::Lens";
    isa_ok $composite3, "Data::Focus::Lens::Composite";
    is $value,  "buzz";
    is $value1, "buzz";
    is $value2, "buzz";
    is $value3, "buzz";
}

{
    note("--- lens associative law");
    my $com1 = ($lens1 . $lens2) . $lens3;
    my $com2 = $lens1 . ($lens2 . $lens3);
    is focus($target)->get($com1), "buzz";
    is focus($target)->get($com2), "buzz";
}

{
    note("--- empty composite lens");
    my $lens = Data::Focus::Lens::Composite->new();
    isa_ok $lens, "Data::Focus::Lens::Composite";
    is_deeply focus($target)->get($lens), {foo => [{bar => "buzz"}]}, "empty composite lens is Identity lens";
}

done_testing;

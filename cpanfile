
requires "parent";
requires "Carp";
requires "Exporter";
requires "Scalar::Util";
requires "overload";

on 'test' => sub {
    requires 'Test::More' => "0";
    requires 'Test::Identity';
    requires 'Test::Fatal';
    requires 'Exporter';
    requires "Scalar::Util";
};

on 'configure' => sub {
    requires 'Module::Build', '0.42';
    requires 'Module::Build::Prereqs::FromCPANfile', "0.02";
};

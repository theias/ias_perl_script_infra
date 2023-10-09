#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'IAS::Infra' ) || print "Bail out!\n";
}

diag( "Testing IAS::Infra $IAS::Infra::VERSION, Perl $], $^X" );

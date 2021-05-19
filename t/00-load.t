#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 4;

BEGIN {
    use_ok( 'CoordinateConversion::IBM' ) || print "Bail out!\n";
    use_ok( 'CoordinateConversion::IBM::LatLon2UTM' ) || print "Bail out!\n";
    use_ok( 'CoordinateConversion::IBM::UTM2LatLon' ) || print "Bail out!\n";
    use_ok( 'CoordinateConversion::IBM::LatZones' ) || print "Bail out!\n";
}

diag( "Testing CoordinateConversion::IBM (no \$CoordinateConversion::IBM::VERSION), Perl $], $^X" );

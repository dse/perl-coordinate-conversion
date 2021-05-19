#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 22;

use CoordinateConversion::IBM::LatLon2UTM qw(latLon2UTM);
use CoordinateConversion::IBM::LatLon2UTM qw(utm2LatLon);

sub runTest {
    my ($lat, $lon, $utm) = @_;
    my ($zone, $latZone, $easting, $northing) = split(' ', $utm);

    my ($checkLat, $checkLon) = utm2LatLon($zone, $latZone, $easting, $northing);
    my ($checkZone, $checkLatZone, $checkEasting, $checkNorthing) = latLon2UTM($lat, $lon);
}

# source: https://developer.ibm.com/languages/java/articles/j-coordconvert/
runTest(  0.0000,    0.0000, "31 N 166021 0");
runTest(  0.1300,   -0.2324, "30 N 808084 14385");
runTest(-45.6456,   23.3545, "34 G 683473 4942631");
runTest(-12.7650,  -33.8765, "25 L 404859 8588690");
runTest(-80.5434, -170.6540, "02 C 506346 1057742");
runTest( 90.0000,  177.0000, "60 Z 500000 9997964");
runTest(-90.0000, -177.0000, "01 A 500000 2035");
runTest( 90.0000,    3.0000, "31 Z 500000 9997964");
runTest( 23.4578, -135.4545, "08 Q 453580 2594272");
runTest( 77.3450,  156.9876, "57 X 450793 8586116");
runTest(-89.3454,  -48.9306, "22 A 502639 75072");

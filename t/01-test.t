#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

use CoordinateConversion::IBM::LatLon2UTM qw(latLon2UTM);
use CoordinateConversion::IBM::UTM2LatLon qw(utm2LatLon);

sub latEqual {
    my ($a, $b) = @_;
    return abs($a - $b) <= 0.0002;
}

sub lonEqual {
    my ($a, $b) = @_;
    return abs($a - $b) <= 0.0002;
}

sub eastingEqual {
    my ($a, $b) = @_;
    return abs($a - $b) == 0;
}

sub northingEqual {
    my ($a, $b) = @_;
    return abs($a - $b) == 0;
}

sub runTest {
    my ($test) = @_;
    my $lat = $test->{lat};
    my $lon = $test->{lon};
    my $latLonString = "${lat} ${lon}";
    my $utmString = $test->{utm};
    my ($utmLongZone, $utmLatZone, $utmEasting, $utmNorthing) = split(' ', $utmString);

    my ($testLatA, $testLonA) = utm2LatLon($utmString);
    my ($testLatB, $testLonB) = utm2LatLon($utmLongZone, $utmLatZone, $utmEasting, $utmNorthing);

    my $testLatLonStringA = utm2LatLon($utmString);
    my $testLatLonStringB = utm2LatLon($utmLongZone, $utmLatZone, $utmEasting, $utmNorthing);

    my ($testUTMLongZoneA, $testUTMLatZoneA, $testUTMEastingA, $testUTMNorthingA) = latLon2UTM($latLonString);
    my ($testUTMLongZoneB, $testUTMLatZoneB, $testUTMEastingB, $testUTMNorthingB) = latLon2UTM($lat, $lon);

    my $testUTMStringA = latLon2UTM($latLonString);
    my $testUTMStringB = latLon2UTM($lat, $lon);

    if ($ENV{DEBUG}) {
        warn(sprintf("*   T   %-20s <=> %10g %10g   ;   %-22s <=> %-2s %-1s %8d %8d\n",
                     "'$latLonString'", $lat, $lon,
                     "'$utmString'", $utmLongZone, $utmLatZone, $utmEasting, $utmNorthing));
        warn(sprintf("    A   %-20s <=> %10g %10g   ;   %-22s <=> %-2s %-1s %8d %8d\n",
                     "'$testLatLonStringA'", $testLatA, $testLonA,
                     "'$testUTMStringA'", $testUTMLongZoneA, $testUTMLatZoneA, $testUTMEastingA, $testUTMNorthingA));
        warn(sprintf("    B   %-20s <=> %10g %10g   ;   %-22s <=> %-2s %-1s %8d %8d\n",
                     "'$testLatLonStringB'", $testLatB, $testLonB,
                     "'$testUTMStringB'", $testUTMLongZoneB, $testUTMLatZoneB, $testUTMEastingB, $testUTMNorthingB));
    }

    ok(latEqual($lat, $testLatA));
    ok(lonEqual($lon, $testLonA));
    if (!ok($latLonString eq $testLatLonStringA)) {
        warn(sprintf("'%s' ne '%s'\n", $latLonString, $testLatLonStringA));
    }
    ok($utmLongZone eq $testUTMLongZoneA);
    ok($utmLatZone eq $testUTMLatZoneA);
    ok(eastingEqual($utmEasting, $testUTMEastingA));
    ok(northingEqual($utmNorthing, $testUTMNorthingA));

    ok(latEqual($lat, $testLatB));
    ok(lonEqual($lon, $testLonB));
    if (!ok($latLonString eq $testLatLonStringB)) {
        warn(sprintf("'%s' ne '%s'\n", $latLonString, $testLatLonStringB));
    }
    ok($utmLongZone eq $testUTMLongZoneB);
    ok($utmLatZone eq $testUTMLatZoneB);
    ok(eastingEqual($utmEasting, $testUTMEastingB));
    ok(northingEqual($utmNorthing, $testUTMNorthingB));
}

$CoordinateConversion::IBM::UTM2LatLon::round = 4;
$CoordinateConversion::IBM::LatLon2UTM::trunc = 0;

# source: https://developer.ibm.com/languages/java/articles/j-coordconvert/
runTest({ lat =>   0.0000, lon =>    0.0000, utm => "31 N 166021 0"       });
runTest({ lat =>   0.1300, lon =>   -0.2324, utm => "30 N 808084 14385"   });
runTest({ lat => -45.6456, lon =>   23.3545, utm => "34 G 683473 4942631" });
runTest({ lat => -12.7650, lon =>  -33.8765, utm => "25 L 404859 8588690" });
runTest({ lat => -80.5434, lon => -170.6540, utm => "02 C 506346 1057742" });
runTest({ lat =>  90.0000, lon =>  177.0000, utm => "60 Z 500000 9997964" });
runTest({ lat => -90.0000, lon => -177.0000, utm => "01 A 500000 2035"    });
runTest({ lat =>  90.0000, lon =>    3.0000, utm => "31 Z 500000 9997964" });
runTest({ lat =>  23.4578, lon => -135.4545, utm => "08 Q 453580 2594272" });
runTest({ lat =>  77.3450, lon =>  156.9876, utm => "57 X 450793 8586116" });
runTest({ lat => -89.3454, lon =>  -48.9306, utm => "22 A 502639 75072"   });
done_testing();

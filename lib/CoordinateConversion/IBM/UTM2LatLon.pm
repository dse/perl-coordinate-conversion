package CoordinateConversion::IBM::UTM2LatLon;
use warnings;
use strict;

use base 'Exporter';

our @EXPORT = qw();
our @EXPORT_OK = qw(utm2LatLon);

our $easting;
our $northing;
our $zone;
our $southernHemisphere = "ACDEFGHJKLM";

use Math::Trig qw(pi);

our $arc;
our $mu;
our $ei;
our $ca;
our $cb;
our $cc;
our $cd;
our $n0;
our $r0;
our $_a1;
our $dd0;
our $t0;
our $Q0;
our $lof1;
our $lof2;
our $lof3;
our $_a2;
our $phi1;
our $fact1;
our $fact2;
our $fact3;
our $fact4;
our $zoneCM;
our $_a3;
our $b;
our $a;
our $e;
our $e1sq;
our $k0;

use CoordinateConversion::IBM qw(SQRT POW SIN COS TAN);

sub init {
    $b = 6356752.314;
    $a = 6378137;
    $e = 0.081819191;
    $e1sq = 0.006739497;
    $k0 = 0.9996;
}

sub getHemisphere {
    my ($latZone) = @_;
    my $hemisphere = "N";
    if (index($southernHemisphere, $latZone) > -1) {
        $hemisphere = "S";
    }
    return $hemisphere;
}

sub utm2LatLon {
    (my $zone, my $latZone, $easting, $northing) = @_;
    init();
    my $hemisphere = getHemisphere($latZone);
    my $latitude = 0.0;
    my $longitude = 0.0;
    if ($hemisphere eq "S") {
        $northing = 10000000 - $northing;
    }
    setVariables();
    $latitude = 180 * ($phi1 - $fact1 * ($fact2 + $fact3 + $fact4)) / pi;
    if ($zone > 0) {
        $zoneCM = 6 * $zone - 183.0;
    } else {
        $zoneCM = 3.0;
    }
    $longitude = $zoneCM - $_a3;
    if ($hemisphere eq "S") {
        $latitude = -$latitude;
    }
    return ($latitude, $longitude);
}

sub setVariables {
    $arc = $northing / $k0;
    $mu = $arc
      / ($a * (1 - POW($e, 2) / 4.0 - 3 * POW($e, 4) / 64.0 - 5 * POW($e, 6) / 256.0));
    $ei = (1 - POW((1 - $e * $e), (1 / 2.0)))
      / (1 + POW((1 - $e * $e), (1 / 2.0)));
    $ca = 3 * $ei / 2 - 27 * POW($ei, 3) / 32.0;
    $cb = 21 * POW($ei, 2) / 16 - 55 * POW($ei, 4) / 32;
    $cc = 151 * POW($ei, 3) / 96;
    $cd = 1097 * POW($ei, 4) / 512;
    $phi1 = $mu + $ca * SIN(2 * $mu) + $cb * SIN(4 * $mu) + $cc * SIN(6 * $mu) + $cd
      * SIN(8 * $mu);
    $n0 = $a / POW((1 - POW(($e * SIN($phi1)), 2)), (1 / 2.0));
    $r0 = $a * (1 - $e * $e) / POW((1 - POW(($e * SIN($phi1)), 2)), (3 / 2.0));
    $fact1 = $n0 * TAN($phi1) / $r0;
    $_a1 = 500000 - $easting;
    $dd0 = $_a1 / ($n0 * $k0);
    $fact2 = $dd0 * $dd0 / 2;
    $t0 = POW(TAN($phi1), 2);
    $Q0 = $e1sq * POW(COS($phi1), 2);
    $fact3 = (5 + 3 * $t0 + 10 * $Q0 - 4 * $Q0 * $Q0 - 9 * $e1sq) * POW($dd0, 4)
      / 24;
    $fact4 = (61 + 90 * $t0 + 298 * $Q0 + 45 * $t0 * $t0 - 252 * $e1sq - 3 * $Q0
             * $Q0)
      * POW($dd0, 6) / 720;
    $lof1 = $_a1 / ($n0 * $k0);
    $lof2 = (1 + 2 * $t0 + $Q0) * POW($dd0, 3) / 6.0;
    $lof3 = (5 - 2 * $Q0 + 28 * $t0 - 3 * POW($Q0, 2) + 8 * $e1sq + 24 * POW($t0, 2))
      * POW($dd0, 5) / 120;
    $_a2 = ($lof1 - $lof2 + $lof3) / COS($phi1);
    $_a3 = $_a2 * 180 / pi;
}

=head1 NAME

CoordinateConversion::IBM::UTM2LatLon - conversion from UTM coordinates to latitude/longitude

=cut

1;
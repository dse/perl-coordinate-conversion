package CoordinateConversion::IBM::LatLon2UTM;
use warnings;
use strict;

use base 'Exporter';

our @EXPORT = qw();
our @EXPORT_OK = qw(latLon2UTM);

our $equatorialRadius;
our $polarRadius;
our $flattening;
our $inverseFlattening;
our $rm;
our $k0;
our $e;
our $e1sq;
our $n;
our $rho;
our $nu;
our $S;
our $A0;
our $B0;
our $C0;
our $D0;
our $E0;
our $p;
our $sin1;
our $K1;
our $K2;
our $K3;
our $K4;
our $K5;
our $A6;

use Math::Trig qw(pi);

use CoordinateConversion::IBM qw(SQRT POW SIN COS TAN);
use CoordinateConversion::IBM::LatZones qw(getLatZone);

sub init {
    $equatorialRadius = 6378137;
    $polarRadius = 6356752.314;
    $flattening = 0.00335281066474748;
    $inverseFlattening = 298.257223563;
    $rm = POW($equatorialRadius * $polarRadius, 1 / 2.0);
    $k0 = 0.9996;
    $e = SQRT(1 - POW($polarRadius / $equatorialRadius, 2));
    $e1sq = $e * $e / (1 - $e * $e);
    $n = ($equatorialRadius - $polarRadius) / ($equatorialRadius + $polarRadius);
    $rho = 6368573.744;
    $nu = 6389236.914;
    $S = 5103266.421;
    $A0 = 6367449.146;
    $B0 = 16038.42955;
    $C0 = 16.83261333;
    $D0 = 0.021984404;
    $E0 = 0.000312705;
    $p = -0.483084;
    $sin1 = 4.84814E-06;
    $K1 = 5101225.115;
    $K2 = 3750.291596;
    $K3 = 1.397608151;
    $K4 = 214839.3105;
    $K5 = -2.995382942;
    $A6 = -1.00541E-07;
}

# accepts either a string, or a latitude and longitude
sub latLon2UTM {
    my ($latitude, $longitude);

    if (scalar @_ == 1) {
        my ($string) = @_;
        my ($latitude, $longitude) = split(' ', @_);
        $latitude += 0.0;       # cast to number
        $longitude += 0.0;      # cast to number
    } elsif (scalar @_ == 2) {
        ($latitude, $longitude) = @;
    } else {
        die("latLon2UTM: incorrect number of parameters");
    }

    init();
    validate($latitude, $longitude);
    setVariables($latitude, $longitude);
    my $longZone = getLongZone($longitude);
    my $latZone = getLatZone($latitude);
    my $_easting = getEasting();
    my $_northing = getNorthing($latitude);
    return ($longZone, $latZone, int($_easting), int($_northing));
}

sub setVariables {
    my ($latitude, $longitude) = @_;

    $latitude = degreeToRadian($latitude);
    $rho = $equatorialRadius * (1 - $e * $e)
      / POW(1 - POW($e * SIN($latitude), 2), 3 / 2.0);
    $nu = $equatorialRadius / POW(1 - POW($e * SIN($latitude), 2), (1 / 2.0));
    my $var1;
    if ($longitude < 0.0) {
        $var1 = (int((180 + $longitude) / 6.0)) + 1;
    } else {
        $var1 = (int($longitude / 6)) + 31;
    }
    my $var2 = (6 * $var1) - 183;
    my $var3 = $longitude - $var2;
    $p = $var3 * 3600 / 10000;
    $S = $A0 * $latitude - $B0 * SIN(2 * $latitude) + $C0 * SIN(4 * $latitude) - $D0
      * SIN(6 * $latitude) + $E0 * SIN(8 * $latitude);
    $K1 = $S * $k0;
    $K2 = $nu * SIN($latitude) * COS($latitude) * POW($sin1, 2) * $k0 * (100000000)
      / 2;
    $K3 = ((POW($sin1, 4) * $nu * SIN($latitude) * POW(COS($latitude), 3)) / 24)
      * (5 - POW(TAN($latitude), 2) + 9 * $e1sq * POW(COS($latitude), 2) + 4
         * POW($e1sq, 2) * POW(COS($latitude), 4))
      * $k0
      * (10000000000000000);
    $K4 = $nu * COS($latitude) * $sin1 * $k0 * 10000;
    $K5 = POW($sin1 * COS($latitude), 3) * ($nu / 6)
      * (1 - POW(TAN($latitude), 2) + $e1sq * POW(COS($latitude), 2)) * $k0
      * 1000000000000;
    $A6 = (POW($p * $sin1, 6) * $nu * SIN($latitude) * POW(COS($latitude), 5) / 720)
      * (61 - 58 * POW(TAN($latitude), 2) + POW(TAN($latitude), 4) + 270
         * $e1sq * POW(COS($latitude), 2) - 330 * $e1sq
         * POW(SIN($latitude), 2)) * $k0 * (1E+24);
}

sub getLongZone {
    my ($longitude) = @_;
    my $longZone = 0;
    if ($longitude < 0.0) {
        $longZone = ((180.0 + $longitude) / 6) + 1;
    } else {
        $longZone = ($longitude / 6) + 31;
    }
    my $val = int($longZone) . "";
    if (length($val) == 1) {
        $val = "0" . $val;
    }
    return $val;
}

sub getNorthing {
    my ($latitude) = @_;
    my $northing = $K1 + $K2 * $p * $p + $K3 * POW($p, 4);
    if ($latitude < 0.0) {
        $northing = 10000000 + $northing;
    }
    return $northing;
}

sub getEasting {
    return 500000 + ($K4 * $p + $K5 * POW($p, 3));
}

sub validate {
    my ($latitude, $longitude) = @_;
    if ($latitude < -90.0 || $latitude > 90.0 || $longitude < -180.0
        || $longitude >= 180.0) {
        die("Legal ranges: latitude [-90,90], longitude [-180,180).");
    }
}

sub degreeToRadian {
    my ($degree) = @_;
    return $degree * pi / 180;
}

sub radianToDegree {
    my ($radian) = @_;
    return $radian * 180 / pi;
}

=head1 NAME

CoordinateConversion::IBM::LatLon2UTM - conversion from latitude/longitude to UTM coordinates

=cut

1;

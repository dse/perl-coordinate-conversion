package CoordinateConversion::IBM::LatZones;
use warnings;
use strict;

use base 'Exporter';

our @EXPORT = qw();
our @EXPORT_OK = qw(getLatZoneDegree getLatZone);

our @letters = ('A', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Z');
our @degrees = (-90, -84, -72, -64, -56, -48, -40, -32, -24, -16, -8, 0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 84);
our @negLetters = ('A', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M');
our @negDegrees = (-90, -84, -72, -64, -56, -48, -40, -32, -24, -16, -8);
our @posLetters = ('N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Z');
our @posDegrees = (0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 84);
our $arrayLength = 22;

sub getLatZoneDegree {
    my ($letter) = @_;
    my $ltr = substr($letter, 0);
    for (my $i = 0; $i < $arrayLength; $i++) {
        if ($letters[$i] eq $ltr) {
            return $degrees[$i];
        }
    }
    return -100;
}

sub getLatZone {
    my ($latitude) = @_;
    my $latIndex = -2;
    my $lat = int($latitude);
    if ($lat >= 0) {
        my $len = scalar @posLetters;
        for (my $i = 0; $i < $len; $i++) {
            if ($lat == $posDegrees[$i]) {
                $latIndex = $i;
                last;
            }
            if ($lat > $posDegrees[$i]) {
                next;
            } else {
                $latIndex = $i - 1;
                last;
            }
        }
    } else {
        my $len = scalar @negLetters;
        for (my $i = 0; $i < $len; $i++) {
            if ($lat == $negDegrees[$i]) {
                $latIndex = $i;
                last;
            }
            if ($lat < $negDegrees[$i]) {
                $latIndex = $i - 1;
                last;
            } else {
                next;
            }
        }
    }
    if ($latIndex == -1) {
        $latIndex = 0;
    }
    if ($lat >= 0) {
        if ($latIndex == -2) {
            $latIndex = scalar(@posLetters) - 1;
        }
        return $posLetters[$latIndex];
    } else {
        if ($latIndex == -2) {
            $latIndex = scalar(@negLetters) - 1;
        }
        return $negLetters[$latIndex];
    }
}

=head1 NAME

CoordinateConversion::IBM::LatZones - conversion between latitude degrees and named latitude zones

=cut

1;

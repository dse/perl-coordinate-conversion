package CoordinateConversion::IBM;
use warnings;
use strict;

use base 'Exporter';

our @EXPORT = qw();
our @EXPORT_OK = qw(SQRT POW SIN COS TAN);

use POSIX qw(pow tan);

sub SQRT {
    my ($x) = @_;
    return sqrt($x);
}

sub POW {
    my ($x, $y) = @_;
    return pow($x, $y);
}

sub SIN {
    my ($x) = @_;
    return sin($x);
}

sub COS {
    my ($x) = @_;
    return cos($x);
}

sub TAN {
    my ($x) = @_;
    return tan($x);
}

=head1 NAME

CoordinateConversion::IBM - common functionality

=cut

1;

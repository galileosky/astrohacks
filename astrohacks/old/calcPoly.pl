#!/usr/bin/perl
#
# do a polynomial fit between the data points
# the independent variables are HA and DEC
# the dependent variable is mount ALT

use strict;
use PDL;
use PDL::Fit::Polynomial;

my $fname = $ARGV[0];
print STDERR "Attempting to process $fname\n";

if ( !-f $fname ) {
    die "Usage: $0 filename\n";
}

open( F, "<$fname" ) or die "Failed to open $fname\n";

# default to a cubic fit
my $order = $ARGV[1] || 4;

# format of file from getModelData.pl is
# HA, mountALT, mountAZ, mountRA, mountDEC, calcRA, calcDEC

# find number of rows in the file.. ugly ugly
my $wc = `/usr/bin/wc <$fname`;
$wc =~ s/^\s+|\s+$//g;
my ($nelem, undef, undef) = split (/\s+/, $wc);

print STDERR "$nelem lines in input file\n";

my $ha_data  = zeroes(double, $nelem);
my $dec_data = zeroes(double, $nelem);
my $alt_data  = zeroes(double, $nelem);

my $i = 0;
while ( chomp( my $line = <F> ) ) {
    my @v = split( /,/, $line );

    if ( $#v == 6 ) {
        my $ha       = $v[0];
	my $mountALT = $v[1];
        my $calcDEC  = $v[6];

	# we can solve directly for DEC
        $dec_data->set($i, $calcDEC);

	# but we can't solve directly for RA.. solve for HA then
        $ha_data->set($i, $ha);
        $alt_data->set($i, $mountALT);
        $i++;
    }
}
$nelem = $i;
close(F);

my ( $ha_fit,  $ha_coeffs )  = fitpoly1d $alt_data,  $ha_data, $order;
my ( $dec_fit, $dec_coeffs ) = fitpoly1d $alt_data, $dec_data, $order;

# calculate the RA and DEC error in arc-seconds
my $ha_error = ($ha_data - $ha_fit) * 3600;
my $dec_error = ($dec_data - $dec_fit) * 3600;

print STDERR "Curve Fit is of order $order\n";
print STDERR "HA Coefficients:  ", $ha_coeffs,  "\n";
print STDERR "DEC Coefficients: ", $dec_coeffs, "\n";

my (undef, undef, undef, undef, undef, undef, $haRms) = statsover($ha_error, 1);
my (undef, undef, undef, undef, undef, undef, $decRms) = statsover($dec_error, 1);

print STDERR "HA RMS Error:     ", $haRms, "\n";
print STDERR "DEC RMS Error:    ", $decRms, "\n";

# print out the data
for ( $i = 0 ; $i < $ha_data->nelem() ; $i++ ) {
    my $haErr = sprintf("%3.2f", $ha_error->at($i));
    my $decErr = sprintf("%3.2f", $dec_error->at($i));

    print STDERR $alt_data->at($i), ", ", $ha_data->at($i), ", ", $dec_data->at($i), 
      ", ", $ha_fit->at($i), ", ", $dec_fit->at($i), ", ",
      $haErr, ", ", $decErr, "\n";
}

# print out the coefficients data manually so that we can sprintf
open(F, ">polyCoeff.txt") or die;
print F "HA Coefficients:  ";
for ( $i = 0 ; $i < $ha_coeffs->nelem() ; $i++ ) {
	my $this = sprintf("%4.15f", $ha_coeffs->at($i));
	print F " $this";
}
print F "\n";
print F "DEC Coefficients: ";
for ( $i = 0 ; $i < $dec_coeffs->nelem() ; $i++ ) {
	my $this = sprintf("%4.15f", $dec_coeffs->at($i));
	print F " $this";
}
print F "\n";
close(F);

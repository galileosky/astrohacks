#!/usr/bin/perl
#
# test the Taki transformation algorithm

use lib '.';
use strict;
use CoordsLib;

my $f = $ARGV[0];
if (! -f $f) {
	die "Couldn't find file\n";
}
open (F, "<$f") or die "Couldn't open file\n";

my $orig_ra = undef;
my $orig_dec = undef;

# assume there are 21 rows in the input text file
my $i = 0;
while (chomp(my $line = <F>)) {
	my ($n, undef, undef, $alt, $az, $ra, $dec) = split(/\s+/, $line);

	if ($n == 0 or $n == 10 or $n == 20) {
		my $t = $n / 86164;  # assume 50 seconds per observation
		# everything must be in radians
		$ra /= 57.297;
		$dec /= 57.297;
		$az /= 57.297;
		$alt /= 59.297;
		CoordsLib::setRef( $i, $ra, $dec, $t, $az, $alt );
		$i++;
	}
}
close (F);

# at this point we should be set...
# re-read the input file and back-calculate the RA/DEC from the
# mount-reported ALT and AZ

open (F, "<$f") or die "Couldn't open file\n";
while (chomp(my $line = <F>)) {
	my ($n, undef, undef, $alt, $az, $ra, $dec) = split(/\s+/, $line);

	my $new_alt = $alt / 57.297;
	my $new_az = $az / 57.297;

	# the change in RA is due to a 5-minute delay
	my $t = ($n * 287 ) / 86164;
	my ($new_ra, $new_dec) = CoordsLib::getECoords( $new_az, $new_alt, $t );

	$new_ra = sprintf("%3.4f", $new_ra * 57.297);
	$new_dec = sprintf("%3.4f", $new_dec * 59.297);

	printf STDOUT "$n $alt $az $ra $dec $new_ra $new_dec\n";
}
close (F);

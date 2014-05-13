#!/usr/bin/perl
#
# calculate the RA rate correction as altitude gets reduced

use strict;
use Astro;

# try to estimate the refraction-corrected tracking rate
# note that movement is 1296000 / 86164 = 15.041 arc-seconds per second
# or 15.041 degrees per hour

my $alt1 = 11;
my $alt2 = $alt1 - 1;

my $f1 = Astro::calcRefraction($alt1);
my $f2 = Astro::calcRefraction($alt2);

my $alt1_fix = $alt1 - ( $f1 / 60 );
my $alt2_fix = $alt2 - ( $f2 / 60 );

my $correction = ( $alt1 - $alt2 ) / ( $alt1_fix - $alt2_fix );
my $correctedRate = 15.041 * $correction;

print "Alt1=$alt1 ($alt1_fix)  Alt2=$alt2 ($alt2_fix)\n";
print "Corrected rate=$correctedRate\n";

#!/usr/bin/perl
#
# calculate the RA rate correction as altitude gets reduced

use strict;
use Astro;

# sample altitude in degrees
my $sampleAlt = 0;
while ( $sampleAlt <= 90 ) {
    my $f = Astro::calcRefraction($sampleAlt);

    print "$sampleAlt $f\n";
    $sampleAlt += 0.5;
}

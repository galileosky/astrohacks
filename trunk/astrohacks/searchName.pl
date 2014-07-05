#!/usr/bin/perl -w

use lib '.';
use strict;
use Astro;

my $name = $ARGV[0] || undef;

my ( $ra, $dec, $objName, $ngc ) = Astro::getObjRADEC($name);

if ( defined($ra) ) {
    print STDERR "Parsed RA=$ra DEC=$dec Name=$objName NGC=$ngc\n";
}
else {
    print STDERR "Failed to find object\n";
}

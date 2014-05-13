#!/usr/bin/perl
use lib '.';
use strict;
use Astro;

my $tmpdir = "/tmp";
my $filename = $ARGV[0];

if (! -f $filename) {
    die "Usage: $0 filename\n";
}

my @solve = Astro::platesolve( $filename, $tmpdir );
my ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

if ( $#solve == 5 ) {
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;
    print STDERR "Solved RA/DEC $ra/$dec, pixel scale $pxscale\n";
}
else {
    print STDERR "Failed to solve\n";
    exit(1);
}

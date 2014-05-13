#!/usr/bin/perl
use lib '.';
use strict;
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
use Astro;

my $tmpdir = "/tmp";
my $filename = Astro::captureDSI( 30 );

# 3rd option for platesolve uses smaller plate scale for Meade
my @solve = Astro::platesolve( $filename, $tmpdir, 1 );
my ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

if ( $#solve == 5 ) {
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;
    print STDERR "Solved RA/DEC $ra $dec, pixel scale $pxscale\n";
}
else {
    print STDERR "Failed to solve\n";
    exit(1);
}
unlink($filename);

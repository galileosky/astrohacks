#!/usr/bin/perl
use lib '.';
use strict;
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
use Math::Trig;
use Astro;

my $dev = "/dev/ttyUSB0";    # change me!

my $port = new Device::SerialPort($dev);
$port->baudrate(9600);
$port->parity("none");
$port->databits(8);
$port->stopbits(1);
$port->handshake("none");
$port->write_settings;

$port->lookclear;

my $ver = Astro::getVer($port);

print STDERR "Found firmware revision: $ver\n";

my $orientation;

my $mount_az = Astro::getAZ( $port );
if ($mount_az >= 180 and $mount_az < 360) {
	$orientation = "WEST";
} else {
	$orientation = "EAST";
}
print STDERR "Telescope is pointing $orientation\n";

my $tmpdir = "/tmp";
my $filename = Astro::captureSBIG( 30, 1, "3x3" );

my @solve = Astro::platesolve( $filename, $tmpdir );
unlink($filename);
my ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

if ( $#solve == 5 ) {
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;
    print STDERR "Solved RA/DEC $ra $dec, pixel scale $pxscale\n";
}
else {
    print STDERR "Failed to solve\n";
    exit(1);
}

# get RA
my $mount_ra = Astro::getRA($port);

# get DEC
my $mount_dec = Astro::getDEC($port);

print STDERR "Mount RA/DEC: $mount_ra $mount_dec\n";

# sync mount to solved coordinates
Astro::sendRCAL( $port, $ra, $dec );

my $delta_ra  = POSIX::floor( 3600 * ( $mount_ra - $ra ) );
my $delta_dec = POSIX::floor( 3600 * ( $mount_dec - $dec ) );

print STDERR "Delta RA/DEC: $delta_ra $delta_dec\n";

# if the delta is within 10 degrees, re-slew
# otherwise, the mount got lost
if ( abs($delta_ra) < 36000 and abs($delta_dec) < 36000 ) {
    Astro::slew( $port, $mount_ra, $mount_dec );
}
else {
    die "Error too large";
}

# move the mount equivalent of 10 minutes in RA
Astro::slew( $port, $mount_ra - 2.50666, $mount_dec );
sleep(3);

# get the second image
$filename = Astro::captureSBIG( 30, 1, "3x3" );
my @newsolve = Astro::platesolve( $filename, $tmpdir );
unlink($filename);

my ( $newra, $newdec );

if ( $#newsolve == 5 ) {
    ( $newra, $newdec, $pxscale, $fld_x, $fld_y, $rot ) = @newsolve;
    print STDERR "Solved RA/DEC $newra $newdec, pixel scale $pxscale\n";
}
else {
    print STDERR "Failed to solve\n";
    exit(1);
}

# go back to original position
Astro::slew( $port, $mount_ra, $mount_dec );

my $deltaDec = ( $dec - $newdec ) * 3600;

# if the DEC delta is too huge, it's a spurious solve
if ($deltaDec > 100) {
	die "Failed solve\n";
}

# compute polar misalignment - from http://celestialwonders.com/tools/polarErrorCalc.html
# note we moved 2.50666 degrees above, equivalent to 10 minutes of time
my $rate = abs($deltaDec / 600)
my $azErr = 12 / pi * $rate / cos($mount_dec / 57.296)

my $azErr = POSIX::floor( ( $deltaDec / $corrFactor ) / 2 );
my $turns = $azErr / 3;
my $dir;

if ($orientation eq "WEST") {
	if ($azErr < 0) {
		$dir = "WEST";
	} else {
		$dir = "EAST";
	}
} else {
	if ($azErr > 0) {
		$dir = "WEST";
	} else {
		$dir = "EAST";
	}
}

print STDERR "DEC Delta: $deltaDec arcsec\nAzimuth error: $azErr\n";
print STDERR "Move $dir ", abs($turns), " ridges\n";

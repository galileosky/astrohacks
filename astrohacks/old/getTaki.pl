#!/usr/bin/perl
#
# capture 3 images along a track of constant DEC and decrementing RA
# build the Taki transform data, then poll the mount every 10 seconds
# and output the mount-reported RA/DEC, and computed RA/DEC

use lib '.';
use strict;
use Astro;
use CoordsLib;

# convert degrees to radians
my $C = 57.2957795131;

# convert seconds to radians (1 day = 2pi radians)
my $TC = 0.000072722052166435185185185185;

# output data here..
open( F, ">>Model.csv" ) or die;
$| = 1;

my $dev  = "/dev/ttyUSB0";                 # change me!
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

my $tmpdir = "/tmp";

print STDERR "Capturing initial image..\n";
my $filename = Astro::captureSBIG( 10, -1, "3x3" );
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

# get RA/DEC
my $mount_ra  = Astro::getRA($port);
my $mount_dec = Astro::getDEC($port);

# store original values
my $orig_ra  = $mount_ra;
my $orig_dec = $mount_dec;

print STDERR "Mount RA/DEC $mount_ra $mount_dec\n";

# sync mount to solved coordinates
Astro::sendRCAL( $port, $ra, $dec );

# fetch mount coordinates, just verify
$mount_ra  = Astro::getRA($port);
$mount_dec = Astro::getDEC($port);

print STDERR "Mount RA/DEC after sync: $mount_ra $mount_dec\n";

# move mount to original coordinates
Astro::slew( $port, $mount_ra, $mount_dec );
sleep(5);
unlink($filename);

# take the 3 shots
my $master_count = 0;
my $t0           = time();
while ( $master_count < 3 ) {
    print STDERR "Capturing $master_count\n";

    # get RA and DEC
    my $mount_ra  = Astro::getRA($port);
    my $mount_dec = Astro::getDEC($port);

    # get ALT and AZ
    # if ALT is less than 20 degrees, bail out
    my $alt = Astro::getALT($port);

    # the azimuth direction is opposite of RA
    my $az = 0.0 - Astro::getAZ($port);
    if ( $alt < 15 ) {
        die "Altitude too low, aborting..";
    }

    # remember to convert times to RADIANS later..
    my $timestamp = time() - $t0;
    $filename = Astro::captureSBIG( 10, -1, "3x3" );

    @solve = Astro::platesolve( $filename, $tmpdir );
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

    if ( $#solve == 5 ) {
        ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;

        # add it to the Taki model
        CoordsLib::setRef( $master_count, $ra / $C, $dec / $C, $timestamp * $TC,
            $az / $C, $alt / $C );

        print STDERR
          "$timestamp, $mount_ra, $mount_dec, $ra, $dec, $alt, $az\n";
        print F "$timestamp, $mount_ra, $mount_dec, $ra, $dec, $alt, $az\n";
        $master_count++;

    }
    else {
        print STDERR "Failed to solve\n";
    }

    # for the second point, move RA by +15 and DEC by +25
    if ( $master_count == 1 ) {
        Astro::slew( $port, $orig_ra - 15, $orig_dec + 25 );
        sleep(10);
    }
    elsif ( $master_count == 2 ) {
        Astro::slew( $port, $orig_ra - 30, $orig_dec );
        sleep(10);
    }
    unlink($filename);
}

# move mount back to original target
Astro::slew( $port, $orig_ra, $orig_dec );
sleep(20);

print STDERR "Now tracking..\n";
print F "\n---\n";

# now start polling the mount and back-computing RA and DEC from our model
while (1) {

    # get RA and DEC
    my $mount_ra  = Astro::getRA($port);
    my $mount_dec = Astro::getDEC($port);

    # get ALT and AZ
    # if ALT is less than 20 degrees, bail out
    my $alt = Astro::getALT($port);

    # the azimuth direction is opposite of RA
    my $az = 0.0 - Astro::getAZ($port);
    if ( $alt < 15 ) {
        die "Altitude too low, aborting..";
    }

    my $timestamp = time() - $t0;

    # back-calculate the RA and DEC from ALT and AZ
    my ( $ra, $dec ) =
      CoordsLib::getECoords( $az / $C, $alt / $C, $timestamp * $TC );

    $ra  = sprintf( "%3.4f", $ra * $C );
    $dec = sprintf( "%3.4f", $dec * $C );

    # calculate the errors in arc-seconds
    my $ra_error  = POSIX::floor( ( $ra - $orig_ra ) * 3600 );

    # Taki overstates the DEC error
    my $dec_error = POSIX::floor( ( $dec - $orig_dec ) * 36 );

    print STDERR
"$timestamp, $mount_ra, $mount_dec, $ra, $dec, $alt, $az ($ra_error $dec_error)\n";
    print F
"$timestamp, $mount_ra, $mount_dec, $ra, $dec, $alt, $az ($ra_error $dec_error)\n";

    # calculate the required guiding pulse
    # we don't use 100% aggressiveness ( * 1000 ) to avoid instability
    my $raPulse  = POSIX::floor( ( abs($ra_error) / 15.041 ) * 500 );
    my $decPulse = POSIX::floor( ( abs($dec_error) / 15.041 ) * 500 );

    # declination increases as we go north, if the error is positive
    # (actual declination > mount declination) then we need to move north
    if ( $decPulse > 50 ) {
        if ( $dec_error > 0 ) {
            print STDERR "N $decPulse ms ";
            Astro::pulseGuide( $port, "N", $decPulse );
        }
        else {
            print STDERR "S $decPulse ms ";
            Astro::pulseGuide( $port, "S", $decPulse );
        }
    }

    # if actual RA > mount RA, we need to move west
    if ( $raPulse > 50 ) {
        if ( $ra_error > 0 ) {
            print STDERR "W $raPulse ms ";
            Astro::pulseGuide( $port, "W", $raPulse );
        }
        else {
            print STDERR "E $raPulse ms ";
            Astro::pulseGuide( $port, "E", $raPulse );
        }
    }
    if ( $raPulse > 50 or $decPulse > 50 ) {
        print STDERR "\n";
    }

    sleep(10);
}

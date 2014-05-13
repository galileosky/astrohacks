#!/usr/bin/perl
#
# capture 10 images along a track of constant DEC and decrementing RA
# decrement RA by 1.25305 degrees (5 minutes @ sidereal) on each iteration

use lib '.';
use strict;
use Astro;

# output data here..
open( F, ">>Model.csv" ) or die;

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

my $tmpdir = "/tmp";

my $master_count = 1;
my $filename = Astro::captureSBIG( 20, -1, "3x3" );

# immediately save the LST, since this would change after a long platesolve
my $lst = Astro::getLst();

my @solve = Astro::platesolve( $filename, $tmpdir );
my ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

if ( $#solve == 5 ) {
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;
    print STDERR "Solved RA/DEC $ra $dec, pixel scale $pxscale\n";
}
else {
    print STDERR "Failed to solve\n";
    exit(1);
}

# get RA/DEC
my $mount_ra  = Astro::getRA($port);
my $mount_dec = Astro::getDEC($port);

my $mount_alt = Astro::getALT($port);
my $mount_az  = Astro::getAZ($port);

# store original values
my $orig_ra  = $mount_ra;
my $orig_dec = $mount_dec;

print STDERR "Mount RA/DEC $mount_ra $mount_dec\n";
my $raErr  = $ra - $mount_ra;
my $decErr = $dec - $mount_dec;

# if the error is too large, the solve got screwed up, do not proceed
if ( abs($raErr) > 36000 or abs($decErr) > 36000 ) {
    die "Error too large - solve failed\n";
}

# sync mount to solved coordinates
Astro::sendRCAL( $port, $ra, $dec );

# fetch mount coordinates, just verify
$mount_ra  = Astro::getRA($port);
$mount_dec = Astro::getDEC($port);

# note that this HA is "real" because it's based
# on the solved RA, not the mount-reported one
my $ha = Astro::getHa( $ra, $lst );

print STDERR "Mount RA/DEC after sync: $mount_ra $mount_dec\n";

# write solved and mount coordinates
print STDERR "$ha, $mount_alt, $mount_az, $mount_ra, $mount_dec, $ra, $dec\n";
print F "$ha, $mount_alt, $mount_az, $mount_ra, $mount_dec, $ra, $dec\n";

# move mount to original coordinates less one RA increment
Astro::slew( $port, $mount_ra - 2.506, $mount_dec );
sleep(2);
unlink($filename);

# now commence the ten shots
my $altTooLow = 0;
while ( $master_count <= 10 and !$altTooLow ) {

    # get RA and DEC
    my $mount_ra  = Astro::getRA($port);
    my $mount_dec = Astro::getDEC($port);

    my $mount_alt = Astro::getALT($port);
    my $mount_az  = Astro::getAZ($port);

    print STDERR "Capturing $master_count/10 at Alt/Az $mount_alt $mount_az\n";
    $filename = Astro::captureSBIG( 20, -5, "3x3" );

    @solve = Astro::platesolve( $filename, $tmpdir );
    ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

    if ( $#solve == 5 ) {
        ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot ) = @solve;

        $ha = Astro::getHa( $ra, $lst );

        # calculate the mount error; if it's too large, there
        # was an incorrect plate solve and we need to throw out
        # this reading
        my $raErr  = $ra - $mount_ra;
        my $decErr = $dec - $mount_dec;

        if ( ( abs($raErr) > 3600 ) or ( abs($decErr) > 3600 ) ) {
            print STDERR "Spurious solve.. skipping\n";
        }
        else {
            print STDERR
              "$ha, $mount_alt, $mount_az, $mount_ra, $mount_dec, $ra, $dec\n";
            print F
              "$ha, $mount_alt, $mount_az, $mount_ra, $mount_dec, $ra, $dec\n";
            $master_count++;
        }
    }
    else {
        print STDERR "Failed to solve\n";
    }

    # move mount in RA only
    # stay above 25 degrees so that refraction is less of a factor
    if ( $mount_alt > 25 ) {
        Astro::slew( $port, $mount_ra - 2.506, $mount_dec );
        sleep(2);
    }
    else {
        print STDERR "Altitude too low, ending sequence\n";
        $altTooLow = 1;
    }
    unlink($filename);
}

# move mount back to original target
Astro::slew( $port, $orig_ra, $orig_dec );
sleep(5);

#!/usr/bin/perl
use lib '.';
use strict;
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
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

# get RA
my $mount_ra = Astro::getRA($port);

# get DEC
my $mount_dec = Astro::getDEC($port);

print STDERR "Mount RA/DEC is $mount_ra $mount_dec\n";

my $tmpdir   = "/tmp";
my $filename = $ARGV[0];
if ( !-f $filename ) {
    $filename = Astro::captureSBIG( 30, 20, "2x2" );
}

if ( !-f $filename ) {
    die "Could not open filename $filename\n";
}

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

# get RA
$mount_ra = Astro::getRA($port);

# get DEC
$mount_dec = Astro::getDEC($port);

# sync mount to solved coordinates
Astro::sendRCAL( $port, $ra, $dec );

my $delta_ra  = POSIX::floor( 3600 * ( $mount_ra - $ra ) );
my $delta_dec = POSIX::floor( 3600 * ( $mount_dec - $dec ) );

print STDERR "Delta RA/DEC: $delta_ra $delta_dec\n";

# if the delta is within 10 degrees, re-slew
# otherwise, the mount got lost
if (    ( abs($delta_ra) < 36000 and abs($delta_dec) < 36000 )
    and ( abs($delta_ra) > 50 or abs($delta_dec) > 50 ) )
{
    print STDERR "Reslewing to $mount_ra, $mount_dec\n";
    Astro::slew( $port, $mount_ra, $mount_dec );
}

unlink($filename);

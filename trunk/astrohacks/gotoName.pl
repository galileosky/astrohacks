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

Astro::setGuideRate($port);

my $ra = Astro::getRA($port);
my $dec  = Astro::getDEC($port);
print STDERR "Mount RA/DEC: $ra/$dec\n";

my $name = $ARGV[0] || undef;

my ( $c_ra, $c_dec, $objName, $ngc ) = Astro::getObjRADEC($name);

if ( defined($ra) ) {
    print STDERR "Found $objName (NGC $ngc) RA=$c_ra DEC=$c_dec\n";
}
else {
    print STDERR "Failed to find object\n";
    exit;
}

Astro::slew( $port, $c_ra, $c_dec );
sleep(10);

$ra = Astro::getRA($port);
$dec  = Astro::getDEC($port);
print STDERR "Mount RA/DEC: $ra/$dec\n";


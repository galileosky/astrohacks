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

# get ALT and AZ
my $alt = Astro::getALT($port);
my $az  = Astro::getAZ($port);

print STDERR "Mount ALT/AZ: $alt/$az\n";

my $c_alt = sprintf("%3.5f", $ARGV[0] || 42.2475 );
my $c_az = sprintf("%3.5f", $ARGV[1] || 342.0881 );

print STDERR "Commanded ALT/AZ: $c_alt/$c_az\n";

Astro::slewALTAZ( $port, $c_alt, $c_az );
sleep(10);

$alt = Astro::getALT($port);
$az  = Astro::getAZ($port);
print STDERR "Mount ALT/AZ: $alt/$az\n";


#!/usr/bin/perl
#
# reset the custom speeds

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

Astro::setGuideRate($port);
Astro::setDecRate($port, 0);
Astro::setRaRate($port, 0);


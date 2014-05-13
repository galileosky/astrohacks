#!/usr/bin/perl
#
# get the average tracking rate and average DEC drift
# using the data from getModelData.pl

use lib '.';
use strict;
use POSIX;
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
use Astro;
use Statistics::Regression;

# try to connect to the port, fail if cannot
my $canConnect = 1;

my $dev  = "/dev/ttyUSB0";                 # change me!
my $port = new Device::SerialPort($dev);
eval {
    $port->baudrate(9600);
    $port->parity("none");
    $port->databits(8);
    $port->stopbits(1);
    $port->handshake("none");
    $port->write_settings;
    $port->lookclear;
};
if ($@) {
    $canConnect = undef;
    print STDERR "Serial port could not be opened\n";
}

# cancel any set custom rates
if ($canConnect) {
    Astro::setDecRate( $port, 0 );
    Astro::setRaRate( $port, 0 );
}

my $fname = $ARGV[0];
print STDERR "Attempting to process $fname\n";

if ( !-f $fname ) {
    die "Usage: $0 filename\n";
}

open( F, "<$fname" ) or die "Failed to open $fname\n";

# format of file from getModelData.pl is
# HA, mountALT, mountAZ, mountRA, mountDEC, calcRA, calcDEC

my @mountRA;
my @calcRA;
my @calcDEC;

# linear regression of RA/DEC error versus HA
my $regRA  = Statistics::Regression->new( "RA",  [ "Const", "HA" ] );
my $regDEC = Statistics::Regression->new( "DEC", [ "Const", "HA" ] );

while ( chomp( my $line = <F> ) ) {
    my @v = split( /,/, $line );

    if ( $#v == 6 ) {
        my $ha       = $v[0];
        my $mountRA  = $v[3];
        my $mountDEC = $v[4];
        my $calcRA   = $v[5];
        my $calcDEC  = $v[6];

        # errors
        my $raErr  = ( $calcRA - $mountRA );
        my $decErr = ( $calcDEC - $mountDEC );

        # we need to scale the DEC drift by the actual declination
        my $decScale = 1 / cos( $calcDEC / 57.296 );
        $decErr *= $decScale;

        $regRA->include( $raErr, [ 1.0, $ha ] );
        $regDEC->include( $decErr, [ 1.0, $ha ] );

    }
}
close(F);
$regRA->print;
$regDEC->print;

# because the index (HA) and errors (RA/DEC) are all in the same units
# the coefficients are in the correct units as well!
my @thetaRA  = $regRA->theta();
my @thetaDEC = $regDEC->theta();

my $corrRaRate  = sprintf( "%+2.4f", @thetaRA[1] );
my $corrDecRate = sprintf( "%+2.4f", @thetaDEC[1] );

# set the custom speeds
if ($canConnect) {
    print STDERR "\nWriting custom rates to mount..\n";
    Astro::setGuideRate($port);

    # only set the rates if the "adjrsq" > 0.95
    if ( $regRA->adjrsq() > 0.950 ) {
        Astro::setRaRate( $port, $corrRaRate );
    }
    else {
        Astro::setRaRate( $port, 0 );
    }

    if ( $regDEC->adjrsq() > 0.950 ) {
        Astro::setDecRate( $port, $corrDecRate );
    }
    else {
        Astro::setDecRate( $port, 0 );
    }
}

#!/usr/bin/perl
#
# captures 10 x 30 seconds, calculates the RA/DEC for each frame
# then uses linear regression to determine the RA and DEC drift
#
# only sets custom rate if the confidence level is high enough
#
# usage: calcCustomRates2.pl modelfile
#
# uses the data from getModelData2.pl
# note that since the independent variable is HA, we can increment HA
# instead of capturing at sidereal rate

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

# linear regression of RA/DEC versus HA
my $regRA  = Statistics::Regression->new( "RA",  [ "Const", "HA" ] );
my $regDEC = Statistics::Regression->new( "DEC", [ "Const", "HA" ] );

while ( chomp( my $line = <F> ) ) {
    my @v = split( /,/, $line );

    if ( $#v == 6 ) {

        # the hour angle is our independent variable
        # RA and DEC in arc-seconds
        my $ha      = $v[0]; # * 3600;
        my $calcRA  = $v[5]; # * 3600;
        my $calcDEC = $v[6]; # * 3600;

        $regRA->include( $calcRA, [ 1.0, $ha ] );
        $regDEC->include( $calcDEC, [ 1.0, $ha ] );
    }
}
close(F);

#$regRA->print;
#$regDEC->print;

# because the index (HA) and errors (RA/DEC) are all in the same units
# the coefficients are in the correct units as well!
my @thetaRA  = $regRA->theta();
my @thetaDEC = $regDEC->theta();

my $rsqRA  = $regRA->rsq();
my $rsqDEC = $regDEC->rsq();

my $rawRaRate  = $thetaRA[1];
my $rawDecRate = $thetaDEC[1];

# depending on which side of the pier we are on, the custom DEC rate
# must change sign, as +DEC is always clockwise
my $pierside = Astro::getPierSide($port);

if ( $pierside eq "East" ) {
    $rawDecRate *= -1;
    print STDERR "Telescope is on east side, reversing DEC correction\n";
}

my $lat = Astro::getLatitude($port);

if ($lat < 0) {
   $rawRaRate *= -1;
}

my $corrRaRate  = sprintf( "%+2.4f", $rawRaRate );
my $corrDecRate = sprintf( "%+2.4f", $rawDecRate );

print STDERR "\nRA Rate:  $corrRaRate (R^2 = $rsqRA)\n";
print STDERR "DEC Rate: $corrDecRate (R^2 = $rsqDEC)\n";

# set the custom speeds
if ($canConnect) {
    print STDERR "\nWriting custom rates to mount..\n";
    Astro::setGuideRate($port);

    # only set the custom rates if our confidence level is high enough
    if ( $rsqRA > 0.500 ) {
        Astro::setRaRate( $port, $corrRaRate );
    }
    if ( $rsqDEC > 0.500 ) {
        Astro::setDecRate( $port, $corrDecRate );
    }
}

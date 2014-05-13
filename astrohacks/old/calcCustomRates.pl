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

while ( chomp( my $line = <F> ) ) {
    my @v = split( /,/, $line );

    if ( $#v == 6 ) {

        # mount declination is constant, no need to record
        push @mountRA, $v[3];
        push @calcRA,  $v[5];
        push @calcDEC, $v[6];
    }
}
close(F);

# iterate over the entries
my $avgRaRate  = 0;
my $avgDecRate = 0;

for ( my $i = 1 ; $i <= $#mountRA ; $i++ ) {

    # RA is going down (behavior of getModelData.pl)
    my $deltaMountRA = $mountRA[ $i - 1 ] - $mountRA[$i];
    my $deltaCalcRA  = $calcRA[ $i - 1 ] - $calcRA[$i];
    my $deltaDEC     = $calcDEC[$i] - $calcDEC[ $i - 1 ];

    # we need to scale the DEC drift by the actual declination
    my $decScale = 1 / cos($calcDEC[$i] / 57.296);
    $deltaDEC *= $decScale;

    # convert to arc-seconds
    my $dmaArcsec = POSIX::floor( $deltaMountRA * 3600 );
    my $dcaArcsec = POSIX::floor( $deltaCalcRA * 3600 );
    my $ddArcsec  = POSIX::floor( $deltaDEC * 3600 );

    # elapsed time, equivalent to calcRA difference
    # divided by sidereal rate
    my $seconds = $dcaArcsec / 15.04108;

    # the "corrected" (from mount perspective) RA rate must be
    # mount delta / seconds
    my $raRate  = sprintf( "%1.4f", ( $dmaArcsec / $seconds ) );
    my $decRate = sprintf( "%1.4f", ( $ddArcsec / $seconds ) );

    print STDERR "$dmaArcsec $dcaArcsec $raRate $ddArcsec $decRate\n";

    $avgRaRate  += $raRate;
    $avgDecRate += $decRate;
}

$avgRaRate  /= $#mountRA;
$avgDecRate /= $#mountRA;

$avgRaRate  = sprintf( "%+2.4f", $avgRaRate );
$avgDecRate = sprintf( "%+2.4f", $avgDecRate );

my $corrRaRate = sprintf( "%+2.4f", ( $avgRaRate - 15.04108 ) / 15.04108 );
my $corrDecRate = sprintf( "%+2.4f", $avgDecRate / 15.04108 );
print STDERR "\nAverage RA Rate:  $avgRaRate ($corrRaRate)\n";
print STDERR "Average DEC Rate: $avgDecRate ($corrDecRate)\n";

# set the custom speeds
if ($canConnect) {
    print STDERR "\nWriting custom rates to mount..\n";
    Astro::setGuideRate($port);
    Astro::setRaRate( $port, $corrRaRate );
    Astro::setDecRate( $port, $corrDecRate );
}

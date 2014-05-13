#!/usr/bin/perl
#
# guide blindly using the cubic coefficients file

use lib '.';
use strict;
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
use Astro;

sub cubicEquation {
    my ( $x, $a, $b, $c, $d ) = @_;

    my $sum = 0;

    $sum += $a;                   # constant
    $sum += $b * $x;              # linear term
    $sum += $c * $x * $x;         # squared term
    $sum += $d * $x * $x * $x;    # cubed term

    return ($sum);
}

my $dev = "/dev/ttyUSB0";         # change me!

my $port = new Device::SerialPort($dev);
$port->baudrate(9600);
$port->parity("none");
$port->databits(8);
$port->stopbits(1);
$port->handshake("none");
$port->write_settings;

$port->lookclear;

my $fname = $ARGV[0] || "polyCoeff.txt";

open( F, "<$fname" ) or die "Can't open coefficients file $fname\n";
chomp( my $haline  = <F> );
chomp( my $decline = <F> );
close(F);

# clean up the RA and DEC input lines
$haline  =~ s/^.*Coefficients\:\s+//g;
$decline =~ s/^.*Coefficients\:\s+//g;

my @haCoeff  = split( /\s+/, $haline );
my @decCoeff = split( /\s+/, $decline );

print STDERR "HA Coefficients:  @haCoeff\n";
print STDERR "DEC Coefficients: @decCoeff\n";

my $ver = Astro::getVer($port);

print STDERR "Found firmware revision: $ver\n";

Astro::setGuideRate($port);

# only make guiding corrections every sleeptime seconds
my $sleeptime = 1;
my $init      = undef;

# error offset of HA and DEC
my $haOffset  = 0;
my $decOffset = 0;

while (1) {

    # get RA/DEC and ALT
    my $ra  = Astro::getRA($port);
    my $dec = Astro::getDEC($port);
    my $alt = Astro::getALT($port);

    # calculate the hour angle
    my $lst = Astro::getLst();
    my $ha = Astro::getHa( $ra, $lst );

    # calculate the HA and DEC from the coefficient table and the current ALT
    # standard cubic equation
    my $compHa  = cubicEquation( $alt, @haCoeff );
    my $compDec = cubicEquation( $alt, @decCoeff );

    # calculate error in arc-seconds
    my $ha_error  = POSIX::floor( ( $compHa - $ha ) * 3600 );
    my $dec_error = POSIX::floor( ( $compDec - $dec ) * 3600 );

    # remove the initial offset
    if ( !$init ) {
        $init      = 1;
        $haOffset  = $ha_error;
        $decOffset = $dec_error;
    }
    $ha_error  -= $haOffset;
    $dec_error -= $decOffset;

    print STDERR
"$lst ALT=$alt HA=$ha RA=$ra DEC=$dec compHA=$compHa compDEC=$compDec ($ha_error $dec_error)\n";

    # if either HA or DEC error exceeds minimum error we issue a correction
    my $haPulse  = 0;
    my $decPulse = 0;

    # calculate the required guiding pulse
    # we don't use 100% aggressiveness ( * 1000 ) to avoid instability
    my $haPulse  = POSIX::floor( ( abs($ha_error) / 15.041 ) * 900 );
    my $decPulse = POSIX::floor( ( abs($dec_error) / 15.041 ) * 900 );

    if ($haPulse > 1000) {
	$haPulse = 0;
    }
    if ($decPulse > 1000) {
$decPulse = 0;
}

    # declination increases as we go north, if the error is positive
    # (actual declination > mount declination) then we need to move north
    if ( $decPulse > 50 ) {
        if ( $dec_error < 0 ) {
            print STDERR "N $decPulse ms ";
            Astro::pulseGuide( $port, "N", $decPulse );
        }
        else {
            print STDERR "S $decPulse ms ";
            Astro::pulseGuide( $port, "S", $decPulse );
        }
    }

    # if actual RA > mount RA, we need to move west
    if ( $haPulse > 50 ) {
        if ( $ha_error < 0 ) {
            print STDERR "W $haPulse ms ";
            Astro::pulseGuide( $port, "W", $haPulse );
        }
        else {
            print STDERR "E $haPulse ms ";
            Astro::pulseGuide( $port, "E", $haPulse );
        }
    }
    if ( $haPulse > 50 or $decPulse > 50 ) {
        print STDERR "\n";
    }

    sleep($sleeptime);
}

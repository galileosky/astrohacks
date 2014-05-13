package Astro;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use Device::SerialPort qw ( :PARAM :STAT 0.07 );
use Time::HiRes;
use Astro::Time;

$VERSION = 0.01;
@ISA     = qw(Exporter);
@EXPORT  = ();
@EXPORT_OK =
  qw(sendCmd getVer getRA getDEC getALT getAZ setGuideRate move stop pulseGuide setLongitude getLst getHa DEBUG LONGITUDE PATH_TO_TESTAPP PATH_TO_DSICMD);

our $DEBUG   = 0;
our $VERSION = "G";

# hard-coded path to the SBIG capture program
our $PATH_TO_TESTAPP = "/home/orly/astrometry-data/testapp";
our $PATH_TO_DSICMD  = "/home/orly/astrometry-data/dsicmd";

# longitude is in degrees! (not turns)
# we have a hard-coded value..
our $LONGITUDE = +103.8;

sub setLongitude() {
    my ($long) = @_;

    $LONGITUDE = $long;
}

sub sendCmd {
    my ( $port, $cmd, $expectedLen ) = @_;

    my $answer   = undef;
    my $count_in = -1;
    my $b        = $port->write($cmd);
    Time::HiRes::usleep(100000);
    while ( $expectedLen > 0 ) {
        my ( $count_in, $c ) = $port->read(48);
        if ( $count_in < $expectedLen ) {
            Time::HiRes::usleep(300000);
        }
        $expectedLen -= $count_in;
        $answer .= $c;
    }

    # chop off the trailing pound
    $answer =~ s/#$//g;

    return ($answer);
}

# reset port and get GTO version
sub getVer {
    my ($port) = @_;

    # reset and set long format
    sendCmd( $port, "#",   0 );
    sendCmd( $port, ":U#", 0 );
    my $ver = sendCmd( $port, ":V#", 1 );

    # store the version in a global variable
    $VERSION = $ver;

    return ($ver);
}

# get RA
sub getRA {
    my ($port) = @_;

    my $ra = sendCmd( $port, ":GR#", 1 );
    my $ra_decimal = sprintf( "%3.4f", conv_RA_to_decimal($ra) );
    return ($ra_decimal);
}

# get DEC
sub getDEC {
    my ($port) = @_;

    my $dec = sendCmd( $port, ":GD#", 1 );
    my $dec_decimal = sprintf( "%3.4f", conv_DEC_to_decimal($dec) );
    return ($dec_decimal);
}

# get ALT
sub getALT {
    my ($port) = @_;

    my $alt = sendCmd( $port, ":GA#", 1 );
    my $alt_decimal = sprintf( "%3.4f", conv_DEC_to_decimal($alt) );
    return ($alt_decimal);
}

# get AZ
sub getAZ {
    my ($port) = @_;

    my $az = sendCmd( $port, ":GZ#", 1 );
    my $az_decimal = sprintf( "%3.4f", conv_DEC_to_decimal($az) );
    return ($az_decimal);
}

# get pier side
sub getPierSide {
    my ($port) = @_;

    my $pierside = sendCmd( $port, ":pS#", 5 );
    return ($pierside);
}

# get latitude
sub getLatitude {
    my ($port) = @_;

    my $lat = sendCmd( $port, ":Gt#", 1 );
    my $lat_decimal = sprintf( "%3.4f", conv_DEC_to_decimal($lat) );
    return ($lat_decimal);
}

# set mount RA and DEC and do nothing more..
# RA and DEC are assumed to be in SDSS format (floating point)
sub setRADEC {
    my ( $port, $ra, $dec ) = @_;

    my $ra_hms  = conv_RA_to_hms($ra);
    my $dec_dms = conv_DEC_to_dms($dec);

    #print STDERR "Setting RA/DEC to $ra_hms/$dec_dms\n";

    my $rsp = sendCmd( $port, ":Sr" . $ra_hms . "#", 1 );
    if ( $rsp ne "1" ) {
        print STDERR "Error setting RA: $rsp\n";
        return (-1);
    }

    $rsp = sendCmd( $port, ":Sd" . $dec_dms . "#", 1 );
    if ( $rsp ne "1" ) {
        print STDERR "Error setting DEC: $rsp\n";
        return (-1);
    }
    return (1);
}

# set mount ALT and AZ
# ALT and AZ are assumed to be in SDSS format (floating point)
sub setALTAZ {
    my ( $port, $alt, $az ) = @_;

    my $alt_dms = conv_DEC_to_dms($alt);
    my $az_dms  = conv_DEC_to_dms($az);

    my $rsp = sendCmd( $port, ":Sa" . $alt_dms . "#", 1 );
    if ( $rsp ne "1" ) {
        print STDERR "Error setting ALT: $rsp\n";
        return (-1);
    }

    $rsp = sendCmd( $port, ":Sz" . $az_dms . "#", 1 );
    if ( $rsp ne "1" ) {
        print STDERR "Error setting ALT: $rsp\n";
        return (-1);
    }
    return (1);
}

sub sendRCAL {
    my ( $port, $ra, $dec ) = @_;

    my $rsp = setRADEC( $port, $ra, $dec );

    if ( $rsp != -1 ) {
        $rsp = sendCmd( $port, ":CMR#", 33 );
        if ( $rsp !~ "^Coordinates" ) {
            print STDERR "Error syncing mount: $rsp\n";
            return (-1);
        }
        return (1);
    }
}

# set guide rate to 1.0X
sub setGuideRate {
    my ($port) = @_;

    my $rsp = sendCmd( $port, ":RG2#", 0 );
}

# set custom DEC tracking rate (requires CP3 box)
# :RD sxxx.xxxx#
sub setDecRate {
    my ( $port, $custom_rate ) = @_;

    if ( !defined($custom_rate) ) {
        $custom_rate = 0;
    }

    my $cust = sprintf( "%3.4f", $custom_rate );
    print STDERR "Set custom DEC rate to $cust\n";
    my $rsp = sendCmd( $port, ":RD $cust#", 1 );
}

# set custom RA tracking rate (requires CP3 box)
# :RR sxxx.xxxx#
sub setRaRate {
    my ( $port, $custom_rate ) = @_;

    if ( !defined($custom_rate) ) {
        $custom_rate = 0;
    }

    my $cust = sprintf( "%3.4f", $custom_rate );
    print STDERR "Set custom RA rate to $cust\n";
    my $rsp = sendCmd( $port, ":RR $cust#", 1 );
}

# move at the guiding rate
sub move {
    my ( $port, $dir ) = @_;

    $dir = lc($dir);
    if ( $dir =~ /n|s|e|w/ ) {
        my $rsp = sendCmd( $port, ":M$dir#" );
    }
}

# move at the guiding rate
sub moveDur {
    my ( $port, $dir, $millis ) = @_;

    $dir = lc($dir);
    my $num = sprintf( "%3d", $millis );
    if ( $dir =~ /n|s|e|w/ ) {
        my $rsp = sendCmd( $port, ":M$dir$num#" );
    }
}

# stop movement at the guiding rate
sub stop {
    my ( $port, $dir ) = @_;

    $dir = lc($dir);
    if ( $dir =~ /n|s|e|w/ ) {
        my $rsp = sendCmd( $port, ":Q$dir#" );
    }
}

# use the new-style PulseGuide if the firmware is new enough
sub pulseGuide {
    my ( $port, $dir, $ms ) = @_;

    if ( $VERSION eq "S" ) {
        Astro::moveDur( $port, $dir, $ms );
    }
    else {
        Astro::move( $port, $dir );
        Time::HiRes::usleep( $ms * 1000 );
        Astro::stop( $port, $dir );
    }
}

sub slew {
    my ( $port, $ra, $dec ) = @_;

    my $rsp = setRADEC( $port, $ra, $dec );

    if ( $rsp != -1 ) {
        $rsp = sendCmd( $port, ":MS#", 1 );
        if ( $rsp ne "0" ) {
            print STDERR "Error slewing mount: $rsp\n";
            return (-1);
        }
        return (1);
    }
}

sub slewALTAZ {
    my ( $port, $alt, $az ) = @_;

    my $rsp = setALTAZ( $port, $alt, $az );

    if ( $rsp != -1 ) {
        $rsp = sendCmd( $port, ":MS#", 1 );
        if ( $rsp ne "0" ) {
            print STDERR "Error slewing mount: $rsp\n";
            return (-1);
        }
        return (1);
    }
}

# calculate decimal RA and DEC
sub conv_RA_to_decimal {
    my ($ra) = @_;

    my ( $h, $m, $s );
    if ( $ra =~ /(\d+)\:(\d+)\:(\d.*)/ ) {
        $h = $1;
        $m = $2;
        $s = $3;

        my $dec = ( $h * 15 ) + ( $m / 4 ) + ( $s / 240 );
        return ($dec);
    }
    return (-1);
}

sub conv_RA_to_hms {
    my ($ra) = @_;

    # RA is in degrees, convert to hours
    my $h = POSIX::floor( $ra / 15 );

    # remainder is in degrees
    $ra -= ( $h * 15 );

    # convert from degrees to minutes
    my $m = POSIX::floor( $ra * 4 );
    $ra -= ( $m / 4 );
    my $s = $ra * 240;
    my $hms = sprintf( "%02d:%02d:%2.1f", $h, $m, $s );
    return ($hms);
}

sub conv_DEC_to_decimal {
    my ($dec) = @_;

    my ( $sgn, $d, $m, $s );
    if ( $dec =~ /([+-])(\d+)\*(\d+)\:(\d*)/ ) {
        $sgn = $1;
        $d   = $2;
        $m   = $3;
        $s   = $4;

        my $decimal = $d + ( $m / 60 ) + ( $s / 3600 );
        if ( $sgn eq "-" ) {
            $decimal *= -1;
        }

        return ($decimal);
    }
    return (-1);
}

sub conv_DEC_to_dms {
    my ($dec) = @_;

    my $sgn = 1;
    if ( $dec < 0 ) {
        $sgn = -1;
        $dec *= -1;
    }

    my $d = POSIX::floor($dec);
    $dec -= $d;
    my $m = POSIX::floor( $dec * 60 );
    $dec -= ( $m / 60 );
    my $s = POSIX::floor( $dec * 3600 + 0.5 );

    my $dms = sprintf( "%s%02d*%02d:%02d", $sgn > 0 ? "+" : "-", $d, $m, $s );
    return ($dms);
}

# capture one shot and return the path
sub captureSBIG {
    my ( $expTime, $Temp, $bin ) = @_;

    if ( $bin ne "1x1" and $bin ne "2x2" and $bin ne "3x3" and $bin ne "9x9" ) {
        $bin = "1x1";
    }
    my $cmdstr = qq{
$PATH_TO_TESTAPP /tmp/ FITS 1 LF $expTime $bin 0 0 0 0 0 0 $Temp
};

    my $tStart = time();

    #print STDERR "Capturing $expTime seconds at $Temp degrees Celsius..\n";

    my $outstr = `$cmdstr`;

    # SBIG sample program prints this..
    # File saved as         : ./LF_2013-12-20T020149.041.fits
    my $filename = undef;
    my $basename = undef;
    if ( $outstr =~ /File saved as\s+:\s+(.*fits)$/m ) {
        $filename = $1;
        $basename = $filename;
        $basename =~ s/\.(fit|fits)$//ug;
    }
    else {
        print STDERR "Error: capture failed\n";
        return (undef);
    }

    my $tElapsed = time() - $tStart;

    #print STDERR "Capture complete ($tElapsed seconds).\n";

    if ( !-f $filename ) {
        print STDERR "Error: invalid filename\n";
        return (undef);
    }
    return ($filename);
}

# capture one shot and return the path
# note that the Meade DSI dsicmd returns a PGM file
sub captureDSI {
    my ($expTime) = @_;

    # we don't have binning or temperature options for the lousy Meade DSI
    my $tmpfile = "/tmp/meadeDSI" . POSIX::getpid();

    my $cmdstr = qq{
$PATH_TO_DSICMD -e $expTime -c 1 -o $tmpfile
};

    my $tStart = time();
    my $outstr = `$cmdstr`;

    # the dsicmd returns a file of the form "XXXX.0000.pgm"
    my $outfile = $tmpfile . ".0000.pgm";
    if ( !-f $outfile ) {
        print STDERR "Error: capture failed - could not find $outfile\n";
        return (undef);
    }

    # we need to convert it to a PPM file for Astrometry.net
    # use ImageMagick as pgm2ppm (used internally by Astrometry.net) doesn't
    # work on the PGM files generated by DSICMD
    my $ppmfile = $tmpfile . ".ppm";
    `/usr/bin/convert -auto-level -despeckle $outfile $ppmfile`;
    unlink($outfile);
    return ($ppmfile);
}

# plate-solve given a filename and tmpdir
sub platesolve {
    my ( $filename, $tmpdir, $hintRA, $hintDEC ) = @_;

    if ( !-d $tmpdir ) {
        $tmpdir = "/tmp";
    }

    print STDERR "Plate-solving $filename (working dir $tmpdir)\n";

    my $cmdstr;
    my $hintstr = undef;
    if ( defined($hintRA) and defined($hintDEC) ) {
        $hintstr = " --ra $hintRA --dec $hintDEC ";
    }

    $cmdstr = qq{
/usr/local/astrometry/bin/solve-field --continue --radius 30 \\
	--sigma 5 --no-plots -N none -r --objs 100 --cpulimit 5 \\
	-L 0.5 -H 10.0 -u degwidth -z 2 $hintstr -D $tmpdir $filename
};

    print STDERR "DEBUG:\n$cmdstr\n---\n\n" if $DEBUG == 1;

    my $outstr = `$cmdstr`;

    print STDERR "DEBUG:\n$outstr\n---\n\n" if $DEBUG == 1;

    my $basename = $filename;
    $basename =~ s/\.(fit|fits)$//ug;

    if ( !-f "$basename.solved" ) {
        unlink($filename);
        my @f = `/bin/ls "$basename.*"`;
        print STDERR "Deleting: ", join( @f, " " ), "\n";
        foreach (@f) { `/bin/rm "$_"`; }
        return (undef);
    }

    `/bin/rm -f $tmpdir/$basename*`;

    # if solved, let's parse the other parts
    my ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );

    # RA,Dec = (83.7127,22.0169), pixel scale 1.81366 arcsec/pix.
    if ( $outstr =~
        /RA,Dec = \((\d.*),(-?\d.*)\)\, pixel scale (\d.*) arcsec/mg )
    {
        $ra      = $1;
        $dec     = $2;
        $pxscale = $3;

    }

    # Field size: 1.68559 x 1.27473 degrees
    if ( $outstr =~ /Field size\: (\d.+) x (\d.+) degrees/m ) {
        $fld_x = $1;
        $fld_y = $2;
    }

    # Field rotation angle: up is -178.796 degrees E of N
    if ( $outstr =~ /Field rotation angle\: up is (.*)$/m ) {
        $rot = $1;
    }

    return ( $ra, $dec, $pxscale, $fld_x, $fld_y, $rot );
}

# get the local sidereal time in floating-point degrees
# this just wraps stuff from Astro::Time
sub getLst {

    # get the current Modified Julian Day
    my $mjd = now2mjd();

    # convert the longitude to turns (for Astro::Time)
    my $long = deg2turn($LONGITUDE);

    # lst is in turns
    my $lst = mjd2lst( $mjd, $long );
    return ( turn2deg($lst) );
}

# calculate the hour angle for a given RA (in decimal degrees)
sub getHa {
    my ( $ra, $lst ) = @_;
    my $ha;

    if ( defined($lst) ) {
        $ha = ( $lst - $ra );
    }
    else {
        $ha = ( getLst() - $ra );
    }
    return ( sprintf( "%3.5f", $ha ) );
}

# calculate the refraction offset due to altitude
# from Mel Bartels

sub calcRefraction {
    my ($altitude) = @_;

    # refraction correction table
    # altitude vs arc-minutes correction
    my %refTable = (
        "90" => "0",
        "60" => "0.55",
        "30" => "1.7",
        "20" => "2.6",
        "15" => "3.5",
        "10" => "5.2",
        "08" => "6.4",
        "06" => "8.3",
        "04" => "11.5",
        "02" => "18",
        "00" => "34.5",
        "-1" => "42.75"
    );

    # perl hash keys aren't sorted and we need to sort them
    my @alts = sort { $b cmp $a } keys %refTable;

    my $idx1;
    my $idx2;
    foreach (@alts) {
        $idx1 = $_;
        if ( $altitude > $idx1 * 1.00 ) {
            last;
        }
        $idx2 = $idx1;
    }

    my $corr1 = $refTable{"$idx1"};
    my $corr2 = $refTable{"$idx2"};

    # interpolate
    my $cslope = ( $corr1 - $corr2 ) / ( $idx2 - $idx1 );
    my $newcorr = $corr1 - ( $cslope * ( $altitude - $idx1 ) );

    # return in arc-minutes
    my $arcmin = sprintf( "%2.2f", $newcorr );
    return ($arcmin);
}

1;

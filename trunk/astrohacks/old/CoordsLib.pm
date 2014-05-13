package CoordsLib;

use strict;
use Math::Trig;

# some private variables

# Constant.. Relationship between the solar time (M) and the sidereal time
# (S): (S = M * 1.002737908);
my $_k = 1.002737908;

# Initial timestamp for the observations
my $_t0 = 0;

# Indicators for definition of the three reference objects
my $_isSetR1 = undef;
my $_isSetR2 = undef;
my $_isSetR3 = undef;

# Auxiliary matrices
my @_lmn1;
my @_LMN1;
my @_lmn2;
my @_LMN2;
my @_lmn3;
my @_LMN3;

# Transformation matrix. Transform vectors from equatorial to
# horizontal system
my @_T;

# Inverse transformation matrix. Transform vectors from horizontal to
# equatorial system.
my @_iT;

# Calculates the inverse of the m[3x3] matrix and returns it
# expect an array reference to be sent
sub _inv {
    my ($ref) = @_;
    my @m = @$ref;
    my $idet;
    my @res;

    # Inverse of the determinant
    $idet =
      1 /
      ( ( $m[0][0] * $m[1][1] * $m[2][2] ) +
          ( $m[0][1] * $m[1][2] * $m[2][0] ) +
          ( $m[0][2] * $m[1][0] * $m[2][1] ) -
          ( $m[0][2] * $m[1][1] * $m[2][0] ) -
          ( $m[0][1] * $m[1][0] * $m[2][2] ) -
          ( $m[0][0] * $m[1][2] * $m[2][1] ) );

    $res[0][0] = ( ( $m[1][1] * $m[2][2] ) - ( $m[2][1] * $m[1][2] ) ) * $idet;
    $res[0][1] = ( ( $m[2][1] * $m[0][2] ) - ( $m[0][1] * $m[2][2] ) ) * $idet;
    $res[0][2] = ( ( $m[0][1] * $m[1][2] ) - ( $m[1][1] * $m[0][2] ) ) * $idet;

    $res[1][0] = ( ( $m[1][2] * $m[2][0] ) - ( $m[2][2] * $m[1][0] ) ) * $idet;
    $res[1][1] = ( ( $m[2][2] * $m[0][0] ) - ( $m[0][2] * $m[2][0] ) ) * $idet;
    $res[1][2] = ( ( $m[0][2] * $m[1][0] ) - ( $m[1][2] * $m[0][0] ) ) * $idet;

    $res[2][0] = ( ( $m[1][0] * $m[2][1] ) - ( $m[2][0] * $m[1][1] ) ) * $idet;
    $res[2][1] = ( ( $m[2][0] * $m[0][1] ) - ( $m[0][0] * $m[2][1] ) ) * $idet;
    $res[2][2] = ( ( $m[0][0] * $m[1][1] ) - ( $m[1][0] * $m[0][1] ) ) * $idet;

    return (@res);
}

# Multiplies two matrices, m1[3x3] and m2[3x3]
sub _m_prod {
    my ( $ref1, $ref2 ) = @_;
    my @m1 = @$ref1;
    my @m2 = @$ref2;
    my @res;
    my $i = 0;

    while ( $i < 3 ) {
        my $j = 0;
        while ( $j < 3 ) {
            $res[$i][$j] = 0.0;
            my $k = 0;
            while ( $k < 3 ) {
                $res[$i][$j] += $m1[$i][$k] * $m2[$k][$j];
                $k++;
            }
            $j++;
        }
        $i++;
    }
    return (@res);
}

# Calculates the Vector cosines (EVC) from the equatorial coordinates
# (ar, dec, t) and return EVC
sub _setEVC {
    my ( $ar, $dec, $t ) = @_;
    my @EVC;

    $EVC[0] = cos($dec) * cos( $ar - $_k * ( $t - $_t0 ) );
    $EVC[1] = cos($dec) * sin( $ar - $_k * ( $t - $_t0 ) );
    $EVC[2] = sin($dec);

    return (@EVC);
}

# Calculates the Vector cosines (HVC) from the horizontal coordinates
# (ac, alt) and return HVC
sub _setHVC {
    my ( $ac, $alt ) = @_;
    my @HVC;
    $HVC[0] = cos($alt) * cos($ac);
    $HVC[1] = cos($alt) * sin($ac);
    $HVC[2] = sin($alt);

    return (@HVC);
}

# Sets the reference objects
# first parameter is the reference #
sub setRef {
    my ( $num, $ar, $dec, $t, $ac, $alt ) = @_;

    if ( $num == 0 ) {
        @_LMN1 = _setEVC( $ar, $dec, $t );
        @_lmn1 = _setHVC( $ac, $alt );
        $_isSetR1 = 1;
	$_t0 = $t;
    }
    elsif ( $num == 1 ) {
        @_LMN2 = _setEVC( $ar, $dec, $t );
        @_lmn2 = _setHVC( $ac, $alt );
        $_isSetR2 = 1;
    }
    elsif ( $num == 2 ) {
        @_LMN3 = _setEVC( $ar, $dec, $t );
        @_lmn3 = _setHVC( $ac, $alt );
        $_isSetR3 = 1;
    }

    if ( defined($_isSetR1) and defined($_isSetR2) and defined($_isSetR3) ) {
        _setT();
    }
}

# Sets the transformation matrix and its inverse (T and iT, respectively)
sub _setT {
    my @subT1;
    my @subT2;
    my @aux;

    $subT1[0][0] = $_lmn1[0];
    $subT1[0][1] = $_lmn2[0];
    $subT1[0][2] = $_lmn3[0];
    $subT1[1][0] = $_lmn1[1];
    $subT1[1][1] = $_lmn2[1];
    $subT1[1][2] = $_lmn3[1];
    $subT1[2][0] = $_lmn1[2];
    $subT1[2][1] = $_lmn2[2];
    $subT1[2][2] = $_lmn3[2];

    $subT2[0][0] = $_LMN1[0];
    $subT2[0][1] = $_LMN2[0];
    $subT2[0][2] = $_LMN3[0];
    $subT2[1][0] = $_LMN1[1];
    $subT2[1][1] = $_LMN2[1];
    $subT2[1][2] = $_LMN3[1];
    $subT2[2][0] = $_LMN1[2];
    $subT2[2][1] = $_LMN2[2];
    $subT2[2][2] = $_LMN3[2];

    @aux = _inv( \@subT2 );
    @_T  = _m_prod( \@subT1, \@aux );
    @_iT = _inv( \@_T );
}

# Horizontal coordinates (ac, alt) obtained from equatorial ones
# and time (ar, dec, t)
sub getHCoords {
    my ( $ar, $dec, $t ) = @_;
    my $ac;
    my $alt;
    my @HVC = ( 0, 0, 0 );
    my @EVC;
    @EVC = _setEVC( $ar, $dec, $t );
    my $i;
    my $j;

    for ( $i = 0 ; $i < 3 ; $i++ ) {
        for ( $j = 0 ; $j < 3 ; $j++ ) {
            $HVC[$i] += $_T[$i][$j] * $EVC[$j];
        }
    }

    $ac = atan2( $HVC[1], $HVC[0] );
    $alt = Math::Trig::asin( $HVC[2] );
    return ( $ac, $alt );
}

# Equatorial coordinates (ar, dec) obtained from horizontal ones
# and time (ac, alt, t)
sub getECoords {
    my ( $ac, $alt, $t ) = @_;
    my $ar;
    my $dec;

    my @HVC;
    my @EVC = ( 0, 0, 0 );
    @HVC = _setHVC( $ac, $alt );

    my $i;
    my $j;
    for ( $i = 0 ; $i < 3 ; $i++ ) {
        for ( $j = 0 ; $j < 3 ; $j++ ) {
            $EVC[$i] += $_iT[$i][$j] * $HVC[$j];
        }
    }

    $ar = atan2( $EVC[1], $EVC[0] ) + ( $_k * ( $t - $_t0 ) );
    $dec = Math::Trig::asin( $EVC[2] );
    return ( $ar, $dec );
}

1;

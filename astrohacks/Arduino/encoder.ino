// encoder-related routines
// this version reads the ADC and uses an interquartile mean to discard jitter

#include <math.h>
#include "EllipseFit.h"


// start computing from here
long _tstart = -1;
long _origin_encoder_angle = -1;
long _current_encoder_angle = -1;
long _theoretical_encoder_angle = -1;

bool _cal = false;


int calc_radius(int x, int y) {
  return (sqrt ((long) x*x + (long) y*y));
}


void swapsort(int *sorted, int num) {
  boolean done = false;    // flag to know when we're done sorting              
  int j = 0;
  int temp = 0;

  while(!done) {           // simple swap sort, sorts numbers from lowest to highest
    done = true;
    for (j = 0; j < (num - 1); j++) {
      if (sorted[j] > sorted[j + 1]){     // numbers are out of order - swap
        temp = sorted[j + 1];
        sorted [j+1] =  sorted[j] ;
        sorted [j] = temp;
        done = false;
      }
    }
  }
}


// read the encoder, implementing an interquartile mean
// thanks to STMicro Application Note 3964 "How to design a simple temperature measurement application using the STM32L-DISCOVERY"

void read_encoder(long &A, long &B, long &tcnv) {
  int readingA[OVERSAMPLING];
  int readingB[OVERSAMPLING];
  int i = 0, rad = 0;
  long t0, t1;
  long encoderA, encoderB;

  t0 = micros();
  A = B = 0;

  // this should finish in 5ms or less @ 32ksps
  // do our sanity-checking in here!
  while (i < OVERSAMPLING) {
    encoderA = read_adc(1);
    encoderB = read_adc(2);

    readingA[i] = encoderA;
    readingB[i] = encoderB;
    i++;
  }

  t1 = micros();

  // tcnv should be in milliseconds
  tcnv = (t0 / 2000UL) + (t1 / 2000UL);

  // sort both sets of readings
  swapsort(readingA, OVERSAMPLING);
  swapsort(readingB, OVERSAMPLING);

  // drop the lowest 25% and highest 25% of the readings
  for (i = OVERSAMPLING / 4; i < (OVERSAMPLING * 3 / 4); i++) {
    A += readingA[i];
    B += readingB[i];
  }
  A /= (OVERSAMPLING / 2);
  B /= (OVERSAMPLING / 2);
}


// ******************** interpolation routine ********************
// calculate the angle in deci-arcseconds (maximum 2592) between two adjacent slots
// 259.2" = angle between two slots of a 5000-ppr encoder
// note that Heidenhain ERN180/480 5000-ppr sin/cos encoders only have 1/20 grating period (12.96") accuracy
//
// return -1 on error or if we got bad data
//
// the encoder+interpolator has its own built-in periodic error which we try to remove via ellipse-fitting

int calc_angle ( long A, long B ) {

  // add to ellipse-fitting array and try to solve
  add_point(A, B);

  // try to curve-fit every "now and then"
  // we can't curve-fit on every loop because a curve-fit takes 0.5+ seconds on Arduino Mega
  if ((get_iter() % (SDE_BUCKETS / 2)) == 0) {
    calculate_sde();

    if (have_estimate()) {
      print_p();
    }
  }

  // do some correction if we have an estimate
  if (have_estimate()) {
    // center the ellipse on the origin..
    A -= (long) get_p(2);
    B -= (long) get_p(3);
    
    // parametric equation for a rotated ellipse about the origin
    // x = a cos t cos phi - b sin t sin phi
    // y = a cos t sin phi - b sin t cos phi
    //
    // a = semi-major, b = semi-minor
    // t = angle
    // phi = polar angle
    
    // precalculate the rotation matrix
    // P(4) is the position angle, phi
    float cosphi = cos(get_p(4) * F0);
    float sinphi = sin(get_p(4) * F0);
    
    // semi-major and semi-minor axis
    // P(1) is the inclination angle
    float Ea = get_p(0);
    float Eb = Ea * cos(get_p(1) * F0);
  }


  long newA = A;
  long newB = B;

  int i;

  // standard calculation - arctan
  double theta = atan2( (double) newA, (double) newB );
  i = (int) ((theta * 412.529612494) + 0.5);
  if (i < 0) i += 2592;

  if (i < 0) i = 0;

  // sometimes it overflows and gives us a nasty surprise
  i = i % 2592;

  return (i);
}


void set_origin ( long new_index, long tcnv ) {
  _cal = true;
  _origin_encoder_angle = (new_index % 648);
  _tstart = tcnv;
}


// calculate the full encoder angle (in DECI-arcseconds!)
// use the hardware quadrature
// also calculate the expected angle

long _old_encoder_angle = -1;

long calc_full_angle (long theta, long tcnv) {
  _current_encoder_angle = (get_quadrature() * 648) + (theta % 648);

  if (_cal) {
    _current_encoder_angle -= _origin_encoder_angle;
    if ( _old_encoder_angle == -1 ) _old_encoder_angle = _current_encoder_angle;

    // don't use seconds directly as angles here are in DECI-arcseconds
    long tElapsed = tcnv - _tstart;
    _theoretical_encoder_angle = (long) (_trackingRateInt * tElapsed) / 10000UL;

    // the quadrature transitions before our interpolation, causing a jump every zero crossing
    // if this jump happens, "guess" the current value by extrapolation from the previous value
    if ( (_current_encoder_angle - _old_encoder_angle) >= 648 ) {
      Serial.println("Encoder Angle lagging!");
      //increment_quadrature();
      //_current_encoder_angle += 648;
    } 
    else if ( (_current_encoder_angle - _old_encoder_angle) <= -648 ) {
      Serial.println("Encoder Angle leading!");
      //decrement_quadrature();
      //_current_encoder_angle -= 648;
    }
  } 
  else {
    _theoretical_encoder_angle = _current_encoder_angle;
  }

  _old_encoder_angle = _current_encoder_angle;

  return ( _current_encoder_angle );
}


// return what the current angle should be from extrapolation
long get_theoretical_angle () {
  return ( _theoretical_encoder_angle );
}


long get_encoder_angle () {
  return ( _current_encoder_angle );
}


// need to check for jumps in the error due to the quadrature getting ahead of the fine angle
long calc_error () {
  long err = get_theoretical_angle() - get_encoder_angle();

  // if the error is too large, set it to zero
  if (abs(err) > 324) err = 0;

  return (err);
}


long get_tstart () {
  return (_tstart);
}

bool is_cal() {
  return (_cal);
}



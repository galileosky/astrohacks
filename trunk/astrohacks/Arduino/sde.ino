// routines for ellipse-fitting and calculating the SDE

#include "EllipseFit.h"

int _sde_k;
int _sde_n = SDE_BUCKETS;
int _sde_m[PARS];

int _sde_iter;
bool _sde_estimate;

float _sde_p[PARS];
float _sde_e[PARS];

float _sde_X[SDE_BUCKETS];
float _sde_Y[SDE_BUCKETS];

// initialize system and set values to zero
void init_sde() {
  for (_sde_k = 0; _sde_k < PARS; _sde_k++) {
    _sde_p[_sde_k] = 0.0;
    _sde_e[_sde_k] = 0.0;
    _sde_m[_sde_k] = 1;
  }

  for (_sde_k = 0; _sde_k < SDE_BUCKETS; _sde_k++) {
    _sde_X[_sde_k] = 0;
    _sde_Y[_sde_k] = 0;
  }

  _sde_iter = 0;
  _sde_estimate = false;
}

// calculate the rough estimate, and new estimate (computationally expensive!!)
// every time we call this, our ellipse parameters get refined
void calculate_sde() {
  if (_sde_iter < (SDE_BUCKETS / 2)) return;

  if (!_sde_estimate) {
    _sde_k = ellipse1_c(&_sde_n, _sde_X, _sde_Y, _sde_p);

    // if the estimate was successful, set estimate to true
    if (_sde_k == 0) _sde_estimate = true;
  }

  if (_sde_estimate) {
    // we have an estimate, calculate the computationally expensive version
    // returns number of iterations (>0) on success
    _sde_k = ellipse2_c(&_sde_n, _sde_X, _sde_Y, _sde_p, _sde_e, _sde_m);

    if (_sde_k <= 0) _sde_estimate = false;
  }
}

// add new X, Y to the SDE array
void add_point(long x, long y) {
  int idx = (_sde_iter % SDE_BUCKETS);

  _sde_X[idx] = x;
  _sde_Y[idx] = y;

  _sde_iter++;
}

// returns true if we have an estimate
bool have_estimate() {
  return (_sde_estimate);
}

long get_iter() {
  return (_sde_iter);
}

// print out the ellipse parameters
void print_p() {
  Serial.print("Major axis     = ");
  Serial.println(_sde_p[0]);

  Serial.print("Inclination    = ");
  Serial.println(_sde_p[1]);

  Serial.print("X position     = ");
  Serial.println(_sde_p[2]);

  Serial.print("Y position     = ");
  Serial.println(_sde_p[3]);

  Serial.print("Position Angle = ");
  Serial.println(_sde_p[4]);
}

// get the ellipse parameters
float get_p(int i) {
  return (_sde_p[i]);
}


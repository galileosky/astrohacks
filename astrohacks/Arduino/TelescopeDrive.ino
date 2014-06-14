// Telescope Drive for Vixen Polaris, Vexta PK243 18:1 stepper, and official Arduino Motor Shield
// Stepper has 200ppr and 18:1 spur gearbox, hence 3600 steps per revolution, full-stepped
//
// Vixen Polaris has 144 teeth on worm drive; there are 1296000 arc-seconds/revolution
// of period 86188 seconds (average King rate)
//
// note AccelStepper speed is in steps per second; average King rate is 1296000 / 86188 = 15.037 arc-seconds per second
// Vixen Polaris moves (1296000 / 144) = 9000 arc-seconds per worm rotation
// since there are 3600 steps per revolution, this is (9000 / 3600) = 2.5 arc-seconds per step
//
// Sidereal rate is thus (15.037 / 2.5) = 6.0148 steps per second

#include <AccelStepper.h>

AccelStepper stepper(2, 12, 13);

const int pwmA = 3;
const int pwmB = 11;
const int brakeA = 8;
const int brakeB = 9;

// sidereal rate is 15.036"/second and average King rate is 15.037"/second
//
// steps per second (default, but we re-calculate this in case constants were changed)
// the correct value is 6.0148 pulses per second, but AccelStepper only has single-precision
// so it becomes 6.01 which is insufficient (gives 15.025"/second)
// but 6.02 gives 15.05"/second which is too much
// our solution is to change the speed every now and then...

float siderealRateLow = 6.01;
float siderealRateHigh = 6.02;

// guide rates for future reference
// guiding east = stop drive
// guiding west = double drive speed
float guideRateLow = 0;
float guideRateHigh = 12.02;


void setup()
{  
  // set up the Arduino motor shield appropriately
  pinMode(pwmA, OUTPUT);
  pinMode(pwmB, OUTPUT);
  pinMode(brakeA, OUTPUT);
  pinMode(brakeB, OUTPUT);

  digitalWrite(pwmA, HIGH);
  digitalWrite(pwmB, HIGH);
  digitalWrite(brakeA, LOW);
  digitalWrite(brakeB, LOW);

  stepper.setMaxSpeed(siderealRateLow * 16);
  stepper.setSpeed(siderealRateLow);
  
  Serial.begin(115200); 
//  Serial.print(siderealRate);  

  stepper.setAcceleration(10);
  stepper.moveTo(1000000);
}

void loop(){  
  // vary the speed appropriately, for now just alternative low and high sidereal rate to get a good average
  long ms = millis();
  
  // change speed every hundred seconds (which should be tiny drift); we don't want to change speed often as that causes floating-point
  // calculations which are computationally expensive
  long phase = (ms / 1000) % 100;
  if (phase == 0) {
    stepper.setSpeed(siderealRateLow);
  } else if (phase == 50) {
    stepper.setSpeed(siderealRateHigh);
  }
  
  if (stepper.distanceToGo() == 0) {
    stepper.runSpeed();
  }
  stepper.runSpeed();
}



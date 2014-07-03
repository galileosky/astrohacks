/*
  Arduino based Digital Setting Circle
 
 Orlando Andico 2011-12-24 / 2014-07-03
 
 <orly.andico at gmail.com>
 
 Changes in v1.0.3:
 - put some bounds checking on the encoder value 
 
 Changes in v1.0.1:
 - updated to compile on Arduino 1.0
 - full quadrature (4X) encoding via 4 virtual interrupts and PinChangeInt library - http://www.arduino.cc/playground/Main/PinChangeInt
 - more efficient reading of ports via digitalWriteFast library - http://code.google.com/p/digitalwritefast/
 - fast quadrature decode based on code from Dr Rainer Hessmer - http://www.hessmer.org/blog/2011/01/30/quadrature-encoder-too-fast-for-arduino/
 - only tested on Uno R3
 - note: all the above libraries needed minor edits to compile properly on Arduino 1.0
 
 
 Michael Fulbright 2010-06-06
 
 <mike.fulbright at pobox.com>
 
 Feel free to modify and share - please let me know if you make any changes so I can keep my version up to date
 
 2010-06-06:  Initial relase - supports 2X encoding
 
 */


// library to allow >2 user interrupts
#include <PinChangeInt.h>
#include <PinChangeIntConfig.h>

// fast port read/write
#include <digitalWriteFast.h>

// constants won't change. They're used here to 
// set pin numbers:

// RA
const int AZ_enc_A = 2;
const int AZ_enc_B = 3;

// DEC
const int ALT_enc_A = 12;
const int ALT_enc_B = 13;

// if either counts are updated..
volatile bool isUpdated = LOW;


// encoder resolution - some cheap encoders have lower tics on the DEC (like my JMI's!)
const int altRES = 10000;    // resolution of encoders
const int azRES = 10000;    // resolution of encoders

char beenAligned = 0;  

volatile bool _AzEncoderASet;
volatile bool _AzEncoderBSet;
volatile long AZ_pos = azRES / 2;

volatile bool _AltEncoderASet;
volatile bool _AltEncoderBSet;
volatile long ALT_pos = altRES / 2;


void setup() {

  // initialize the encoder inputs
  pinMode(ALT_enc_A, INPUT);
  pinMode(ALT_enc_B, INPUT);
  pinMode(AZ_enc_A, INPUT);
  pinMode(AZ_enc_B, INPUT);

  // turn on pullup resistors.. the quadrature algorithm is extremely sensitive
  digitalWrite(ALT_enc_A, LOW);
  digitalWrite(ALT_enc_B, LOW);
  digitalWrite(AZ_enc_A, LOW);
  digitalWrite(AZ_enc_B, LOW);

  // hook interrupts off the ALT and AZ pins
  PCintPort::attachInterrupt(ALT_enc_A, altFuncA, CHANGE);
  PCintPort::attachInterrupt(ALT_enc_B, altFuncB, CHANGE);

  PCintPort::attachInterrupt(AZ_enc_A, azFuncA, CHANGE);
  PCintPort::attachInterrupt(AZ_enc_B, azFuncB, CHANGE);

  Serial.begin(9600);
}

// ################### ALTITUDE DECODING FUNCTION ###################

void altFuncA() {
  _AltEncoderASet = digitalReadFast(ALT_enc_A) == HIGH;   // read the input pin
  _AltEncoderBSet = digitalReadFast(ALT_enc_B);   // read the input pin

  ALT_pos += (_AltEncoderASet != _AltEncoderBSet) ? +1 : -1;
  isUpdated = HIGH;
} 


void altFuncB() {
  _AltEncoderASet = digitalReadFast(ALT_enc_A);   // read the input pin
  _AltEncoderBSet = digitalReadFast(ALT_enc_B) == HIGH;   // read the input pin

  ALT_pos += (_AltEncoderASet == _AltEncoderBSet) ? +1 : -1;
  isUpdated = HIGH;
} 


// ################### AZIMUTH DECODING FUNCTION ###################

void azFuncA() {
  _AzEncoderASet = digitalReadFast(AZ_enc_A) == HIGH;   // read the input pin
  _AzEncoderBSet = digitalReadFast(AZ_enc_B);   // read the input pin

  AZ_pos += (_AzEncoderASet != _AzEncoderBSet) ? +1 : -1;
  isUpdated = HIGH;
} 


void azFuncB() {
  _AzEncoderASet = digitalReadFast(AZ_enc_A);   // read the input pin
  _AzEncoderBSet = digitalReadFast(AZ_enc_B) == HIGH;   // read the input pin

  AZ_pos += (_AzEncoderASet == _AzEncoderBSet) ? +1 : -1;
  isUpdated = HIGH;
} 


void loop() { 

  char inchar;

  if (!Serial.available())
  {
    delay(10);
  }
  inchar = Serial.read();

  // throw away rest of command - we don't need it
  Serial.flush();

  if (inchar == 'Q')
  {
    // do some bounds checking on the encoder positions
    if (ALT_pos > (altRES / 2)) {
      ALT_pos -= altRES;
    }

    if (ALT_pos < (altRES / -2)) {
      ALT_pos += altRES;
    }

    if (AZ_pos > (azRES / 2)) {
      AZ_pos -= azRES;
    }

    if (AZ_pos < (azRES / -2)) {
      AZ_pos += azRES;
    }

    printEncoderValue(AZ_pos, HIGH);
    Serial.print("\t");
    printEncoderValue(ALT_pos, HIGH);
    Serial.print("\r");
  }
  else if (inchar == 'R' || inchar == 'Z' || inchar == 'I' || inchar == 'z')
  {
    // ignore command - just return proper code
    if (inchar == 'R' || inchar == 'I')  
      Serial.print("R");
    else if (inchar == 'Z')
      Serial.print("*"); 
    else if (inchar == 'z')
      Serial.print("r");
  }
  else if (inchar == 'r') 
  {
    // print out resolution - in future this may be configurable
    printEncoderValue(azRES, LOW);
    Serial.print("\t");
    printEncoderValue(altRES, LOW);
    Serial.print("\r");

  }
  else if (inchar == 'V')
  {
    //version
    Serial.print("V1.0.3\r");
  }
  else if (inchar == 'T')
  {
    // test mode - output resolutions and error count
    printEncoderValue(azRES, LOW);
    Serial.print(",");
    printEncoderValue(altRES, LOW);
    Serial.print(",00000\r");
  }
  else if (inchar == 'q')
  {
    // error count
    Serial.print("00000\r");
  }
  else if (inchar == 'P')
  {
    // Celestron Astromaster "ideal" return
    Serial.print("001");
  }
  else if (inchar == 'p')
  {
    // 
    // dave eks error command
    Serial.print("00");
  } 
  else if (inchar == 'h')
  {
    // report resolution in Dave Eks format
    Serial.write(0xA0);
    Serial.write(0x0F);
    Serial.write(0xA0);
    Serial.write(0x0F);
  }
  else if (inchar == 'y')
  {
    // report encoders in Dave Eks format
    printHexEncoderValue(ALT_pos);
    printHexEncoderValue(AZ_pos);
  }  
  else if (inchar == 'a')
  {
    if (beenAligned)
      Serial.print("Y");
    else
      Serial.print("N");
  }
  else if (inchar == 'A')
  {
    beenAligned = 1;
  }
}


// print encoder value with leading zeros
void printEncoderValue(long val, bool lead)
{
  unsigned long aval; 

  if (lead) {
    if (val < 0)
      Serial.print("-");
    else
      Serial.print("+");
  }

  aval = abs(val);

  if (aval < 10) 
    Serial.print("0000");
  else if (aval < 100)
    Serial.print("000");
  else if (aval < 1000)
    Serial.print("00");
  else if (aval < 10000) 
    Serial.print("0");

  Serial.print(aval);  
}

void printHexEncoderValue(long val)
{
  char low, high;

  high = val / 256;

  low = val - high*256;

  Serial.print(low, HEX);
  Serial.print(high, HEX);

  return;
}


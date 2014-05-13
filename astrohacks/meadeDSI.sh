#!/bin/bash

#ROOT_UID=0

#if [ "$UID" -ne "$ROOT_UID" ]
#then
#  echo "You need to be root to run this program."
#  exit 0
#fi

fw="/lib/firmware/meade.hex"

bdir="/dev/bus/usb"

if [ ! -d "$bdir" ]
then
  bdir="/proc/bus/usb"
fi

# see if there is a Meade unconfigured device to be found
bd=$( lsusb | grep 156c:0100 | cut -d ' ' -f 2,4 | sed -e 's/ /\//' -e 's/://' )
dev="$bdir/$bd"

# if we have found a camera, lets reprogram it.
if [ "$dev" != "$bdir/" ] 
then
  echo "Loading firmware for $dev (3 sec delay)" 
  echo "Resetting $dev..."
  /sbin/fxload -t fx2 -I $fw -D $dev
  sleep 3
  echo "Reset finished"
else
   bd=$( lsusb | grep 156c:0101 | cut -d ' ' -f 2,4 | sed -e 's/ /\//' -e 's/://' )
   dev="$bdir/$bd"
   if [ "$dev" != "$bdir/" ] 
   then
     echo "Resetting $dev..."
     /sbin/fxload -t fx2 -I $fw -D $dev
     sleep 3
     echo "Reset finished"
   fi
fi

bd=$( lsusb | grep 156c:0101 )

if [ -z "$bd" ] 
then
  echo "No Meade device found"
  exit -1
fi

exit 0

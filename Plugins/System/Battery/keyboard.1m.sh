#!/bin/sh

PERCENTAGE=`ioreg -c AppleBluetoothHIDKeyboard | grep BatteryPercent | fgrep -v { | sed 's/[^[:digit:]]//g'`

if [ "$PERCENTAGE" ]; then
        echo "Keyboard: $PERCENTAGE%"
#else
#        echo "without bluetooth keyboard?"
fi


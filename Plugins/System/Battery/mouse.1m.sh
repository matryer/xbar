#!/bin/sh

PERCENTAGE=`ioreg -n BNBMouseDevice | fgrep BatteryPercent |fgrep -v { | sed 's/[^[:digit:]]//g'`

if [ "$PERCENTAGE" ]; then
        echo "Mouse: $PERCENTAGE%"
#else
#        echo "without bluetooth mouse?"
fi


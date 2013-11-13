#!/bin/bash

IDLE=`top -F -R -l3 | grep "CPU usage" | tail -1 | egrep -o '[0-9]{0,3}\.[0-9]{0,2}% idle' | sed 's/% idle//'`

USED=`echo 100 - $IDLE | bc`

echo -n "CPU: "
echo $USED%

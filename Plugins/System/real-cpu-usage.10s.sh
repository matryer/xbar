#!/bin/bash

# Real CPU Usage
# BitBar plugin
#
# by Mat Ryer and Tyler Bunnell
#
# Calcualtes and displays real CPU usage stats.

IDLE=`top -F -R -l3 | grep "CPU usage" | tail -1 | egrep -o '[0-9]{0,3}\.[0-9]{0,2}% idle' | sed 's/% idle//'`

USED=`echo 100 - $IDLE | bc`

echo -n "CPU: "
echo $USED%

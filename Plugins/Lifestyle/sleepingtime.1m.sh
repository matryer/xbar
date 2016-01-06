#!/bin/bash

# Time in minutes to fall asleep. The mean is 15 minutes
falling_asleep=15

# Format with local time format (12 or 24 hours)
format='%X'

# Add 1 hour and 30 minutes between all cycles
date1=`date -v+1H -v+30M -v+"$falling_asleep"M +"$format"`
date2=`date -v+3H -v+"$falling_asleep"M +"$format"`
date3=`date -v+4H -v+30M -v+"$falling_asleep"M +"$format"`
date4=`date -v+6H -v+"$falling_asleep"M +"$format"`
date5=`date -v+7H -v+30M -v+"$falling_asleep"M +"$format"`
date6=`date -v+9H -v+"$falling_asleep"M +"$format"`

# Display everything in local time format
echo "Sleeptime"
echo '---'
echo "1 cycle: ${date1%:*}"
echo "2 cycles: ${date2%:*}|color=#ad0028"
echo "3 cycles: ${date3%:*}|color=#fe5000"
echo "4 cycles: ${date4%:*}|color=#609a94"
echo "5 cycles: ${date5%:*}|color=#00ab84"
echo "6 cycles: ${date6%:*}|color=#00a478"

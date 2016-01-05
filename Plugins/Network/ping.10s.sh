#!/bin/bash

# This is a plugin of Bitbar
# https://github.com/matryer/bitbar
# It shows current ping to some servers at the top Menubar
# This helps me to know my current connection speed
#
# Author: trungdq88@gmail.com

MAX_PING=10000
ping_google=$(ping -c 2 google.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_facebook=$(ping -c 2 facebook.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_github=$(ping -c 2 github.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_stackoverflow=$(ping -c 2 stackoverflow.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_dota2=$(ping -c 2 sgp-1.valve.net | awk -F '/' 'END {printf "%d\n", $5}')

# If ping == 0, that means the ping request has problem
if (( $ping_google == 0 )) ; then
    ping_google=$MAX_PING
fi

if (( $ping_facebook == 0 )) ; then
    ping_facebook=$MAX_PING
fi

if (( $ping_github == 0 )) ; then
    ping_github=$MAX_PING
fi

if (( $ping_stackoverflow == 0 )) ; then
    ping_stackoverflow=$MAX_PING
fi

if (( $ping_dota2 == 0 )) ; then
    ping_dota2=$MAX_PING
fi

# Calculate the average ping
avg=$(( ($ping_google + $ping_facebook + $ping_github + $ping_stackoverflow + $ping_dota2)/5 ))
# Standard deviation
d1=$(( ($ping_google - avg)**2 ))
d2=$(( ($ping_facebook - avg)**2 ))
d3=$(( ($ping_github - avg)**2 ))
d4=$(( ($ping_stackoverflow - avg)**2 ))
d5=$(( ($ping_dota2 - avg)**2 ))
sum=$(( ($d1 + $d2 + $d3 + $d4 + $d5)/5 ))
sd=$(echo "sqrt ( $sum )" | bc -l | awk '{printf "%d\n", $1}')

# Define color
color="#cc3b3b"
msg="$avg±$sd ⚡︎"

if (( $avg < 1000 )) ; then
    color="#cc673b"
fi

if (( $avg < 600 )) ; then
    color="#ce8458"
fi

if (( $avg < 300 )) ; then
    color="#6bbb15"
fi

if (( $avg < 100 )) ; then
    color="#0ed812"
fi

if (( $avg < 50 )) ; then
    color="#e506ff"
fi

if (( $avg == $MAX_PING )) ; then
    color="#acacac"
    msg="☠️"
fi

echo "$msg | font=UbuntuMono-Bold color=$color size=10"
echo "---"
echo "Google: $ping_google ms"
echo "Facebook: $ping_facebook ms"
echo "GitHub: $ping_github ms"
echo "Stack Overflow: $ping_stackoverflow ms"
echo "DotA 2: $ping_dota2 ms"

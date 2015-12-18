#!/bin/bash

# This is a plugin of Bitbar
# https://github.com/matryer/bitbar
# It shows current ping to some servers at the top Menubar
# This helps me to know my current connection speed
#
# Author: trungdq88@gmail.com

ping_google=$(ping -c 1 google.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_facebook=$(ping -c 1 facebook.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_github=$(ping -c 1 github.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_stackoverflow=$(ping -c 1 stackoverflow.com | awk -F '/' 'END {printf "%d\n", $5}')
ping_dota2=$(ping -c 1 sgp-1.valve.net | awk -F '/' 'END {printf "%d\n", $5}')

avg=$(( ($ping_google + $ping_facebook + $ping_github + $ping_stackoverflow + $ping_dota2)/5 ))

color="#cc3b3b"

if (( $avg < 1000 )) ; then
    color="#cc673b"
fi

if (( $avg < 600 )) ; then
    color="#ce8458"
fi

if (( $avg < 300 )) ; then
    color="#bbbc55"
fi

if (( $avg < 100 )) ; then
    color="#59b86d"
fi

if (( $avg < 50 )) ; then
    color="#e506ff"
fi

if (( $avg == 0 )) ; then
    color="#acacac"
fi

echo "$avg ms | color=$color size=12"
echo "---"
echo "Google: $ping_google ms"
echo "Facebook: $ping_facebook ms"
echo "Github: $ping_github ms"
echo "Stack Overflow: $ping_stackoverflow ms"
echo "Dota 2: $ping_dota2 ms"

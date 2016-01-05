#!/bin/bash

# This is a plugin of Bitbar
# https://github.com/matryer/bitbar
# It shows current ping to some servers at the top Menubar
# This helps me to know my current connection speed
#
# Authors: (Trung Đinh Quang) trungdq88@gmail.com and (Grant Sherrick) https://github.com/thealmightygrant 

MAX_PING=10000
SITES=(google.com youtube.com wikipedia.org github.com imgur.com)

#grab ping times for all sites
SITE_INDEX=0
PING_TIMES=

while [ $SITE_INDEX -lt ${#SITES[@]} ]; do
    NEXT_SITE="${SITES[$SITE_INDEX]}"
    NEXT_PING_TIME=$(ping -c 2 -n -q "$NEXT_SITE" 2>/dev/null | awk -F '/' 'END {printf "%d\n", $5}')
    if [ "$NEXT_PING_TIME" -eq 0 ]; then
        NEXT_PING_TIME=$MAX_PING
    fi
    if [ -z "$PING_TIMES" ]; then
        PING_TIMES=($NEXT_PING_TIME)
    else
        PING_TIMES=(${PING_TIMES[@]} $NEXT_PING_TIME)
    fi
    SITE_INDEX=$(( $SITE_INDEX + 1 ))
done

# Calculate the average ping
SITE_INDEX=0
AVG=0
while [ $SITE_INDEX -lt ${#SITES[@]} ]; do
    AVG=$(( ($AVG + ${PING_TIMES[$SITE_INDEX]}) ))
    SITE_INDEX=$(( $SITE_INDEX + 1 ))
done
AVG=$(( $AVG / ${#SITES[@]} ))

# Calculate STD dev
SITE_INDEX=0
AVG_DEVS=0
while [ $SITE_INDEX -lt ${#SITES[@]} ]; do
    AVG_DEVS=$(( $AVG_DEVS + (${PING_TIMES[$SITE_INDEX]} - $AVG)**2 ))
    SITE_INDEX=$(( $SITE_INDEX + 1 ))
done
AVG_DEVS=$(( $AVG_DEVS / ${#SITES[@]} ))
SD=$(echo "sqrt ( $AVG_DEVS )" | bc -l | awk '{printf "%d\n", $1}')

# Define color
COLOR="#cc3b3b"
MSG="$AVG"'±'"$SD"'⚡'

if [ $AVG -ge 1000 ]; then
    COLOR="#acacac"
    MSG=" ☠ "
elif [ $AVG -ge 600 ] && [ $AVG -lt 1000 ]; then
    COLOR="#cc673b"
elif [ $AVG -ge 300 ] && [ $AVG -lt 600 ]; then
    COLOR="#ce8458"
elif [ $AVG -ge 100 ] && [ $AVG -lt 300 ]; then
    COLOR="#6bbb15"
elif [ $AVG -ge 50 ] && [ $AVG -lt 100 ]; then
    COLOR="#0ed812"
else
    COLOR="#e506ff"
fi

echo "$MSG | font=UbuntuMono-Bold color=$COLOR size=10"
echo "---"
SITE_INDEX=0
while [ $SITE_INDEX -lt ${#SITES[@]} ]; do
    echo "${SITES[$SITE_INDEX]}: ${PING_TIMES[$SITE_INDEX]} ms"
    SITE_INDEX=$(( $SITE_INDEX + 1 ))
done

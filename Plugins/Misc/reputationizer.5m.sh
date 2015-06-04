#!/bin/bash

# Stackoverflow reputation score
# BitBar plugin
#
# by Bruce Steedman
#
# Shows current reputation and thumbs up/down on change
# 5 minute refresh is just under the 300 calls a day no-key api limit

# id for user from url - e.g. https://stackoverflow.com/users/4114896/matzfan
SO_ID=1144035 # change this value to your own (or someone else's!)

URI="https://api.stackexchange.com/2.2/users/"$SO_ID"?site=stackoverflow" # api

# file used to persist old score. set score to 0 if file doesn't exist
if [ ! -f "/tmp/reputationizer.dat" ] ; then
  OLDREP=0
else
  OLDREP=$(cat /tmp/reputationizer.dat) # read value from file
fi
# get reputation from api
NEWREP=$(curl -s --compressed $URI | egrep -o '"reputation":*([0-9])+' | sed 's/"reputation"://')

if [ "$NEWREP" -gt "$OLDREP" ] ; then
  echo 👍
elif [ "$OLDREP" -gt "$NEWREP" ] ; then
  echo 👎
else
  echo $NEWREP # output score
fi

echo $NEWREP > /tmp/reputationizer.dat # write new score to file

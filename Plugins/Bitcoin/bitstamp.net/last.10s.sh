#!/bin/bash

# Bitstamp rate
# BitBar plugin
#
# by Damien Lajarretie
# Based on Coinbase bitbar plugin by Mat Ryer
#
# Shows last BTC price (in USD) on Bitstamp exchange.
#

echo -n "Bitstamp: $"; curl -s "https://www.bitstamp.net/api/ticker/" | egrep -o '"last": "[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/"last": //' | sed 's/\"//g'
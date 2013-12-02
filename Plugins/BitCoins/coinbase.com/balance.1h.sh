#!/bin/bash

# Coinbase.com Your Balance
# BitBar plugin
#
# by Mat Ryer
#
# Shows your balance in BTC.  Be sure you add you API key.
#
echo -n "BTC: "; curl -s "https://coinbase.com/api/v1/account/balance?api_key=YOUR_API_KEY" | egrep -o ',"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/,"amount"://'  | sed 's:^.\(.*\).$:\1:'

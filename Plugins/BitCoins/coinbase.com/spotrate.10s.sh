#!/bin/bash

# Coinbase.com Spot rate
# BitBar plugin
#
# by Mat Ryer
#
# Shows latest spot rate values (in USD) for Bitcoins in the
# Coinbase exchange.

echo -n "BTC: "; curl -s "https://coinbase.com/api/v1/prices/spot_rate?currency=USD" | egrep -o '"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/"amount"://'  | sed 's:^.\(.*\).$:\1:'

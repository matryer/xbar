#!/bin/bash

# Coinbase.com Buy and Sell
# BitBar plugin
#
# by Mat Ryer
#
# Shows latest sell values (in USD) for Bitcoins in the
# Coinbase exchange.

echo -n "Sell: $"; curl -s "https://coinbase.com/api/v1/prices/sell?currency=USD" | egrep -o ',"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/,"amount"://'  | sed 's:^.\(.*\).$:\1:'
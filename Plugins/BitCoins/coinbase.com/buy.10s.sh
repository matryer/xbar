#!/bin/bash

# Coinbase.com Buy and Sell
# BitBar plugin
#
# by Mat Ryer
#
# Shows latest buy values (in USD) for Bitcoins in the
# Coinbase exchange.

echo -n "Buy: "; curl -s "https://coinbase.com/api/v1/prices/buy?currency=USD" | egrep -o ',"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/,"amount"://'  | sed 's:^.\(.*\).$:\1:'

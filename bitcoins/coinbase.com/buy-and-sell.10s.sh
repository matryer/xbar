#!/bin/bash
echo -n "Buy: "; curl -s "https://coinbase.com/api/v1/prices/buy?currency=USD" | egrep -o ',"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/,"amount"://'  | sed 's:^.\(.*\).$:\1:'
echo -n "Sell: "; curl -s "https://coinbase.com/api/v1/prices/sell?currency=USD" | egrep -o ',"amount":"[0-9]+(\.)?([0-9]{0,2}")?' | sed 's/,"amount"://'  | sed 's:^.\(.*\).$:\1:'
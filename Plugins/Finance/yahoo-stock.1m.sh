#!/bin/bash
#
# yahoo stock info plugin
# much simpler than stock plugin, no API key required
# by http://srinivas.gs


stock[1]="GOOG"
stock[2]="AAPL"
stock[3]="AMZN"

s='http://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'
for (( c=1; c<=${#stock[@]}; c++ ))
do
	echo -n ${stock[$c]}; echo -n ":"; curl -s echo ${s/stock_symbol/${stock[$c]}}
done

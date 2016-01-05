#!/bin/bash
#
# yahoo stock info plugin
# much simpler than stock plugin, no API key required
# by http://srinivas.gs

# specify which stocks you want to monitor here
stock[0]="GOOG"
stock[1]="AAPL"
stock[2]="AMZN"

shuffle() {
   local i tmp size max rand

   # $RANDOM % (i+1) is biased because of the limited range of $RANDOM
   # Compensate by using a range which is a multiple of the array size.
   size=${#stock[*]}
   max=$(( 32768 / size * size ))

   for ((i=size-1; i>0; i--)); do
      while (( (rand=$RANDOM) >= max )); do :; done
      rand=$(( rand % (i+1) ))
      tmp=${stock[i]} stock[i]=${stock[rand]} stock[rand]=$tmp
   done
}
shuffle


s='http://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'

n=${#stock[@]}
n=$((n-1))

for (( c=0; c<=$n; c++ ))
do
	echo -n ${stock[$c]}; echo -n ":"; curl -s echo ${s/stock_symbol/${stock[$c]}}
done

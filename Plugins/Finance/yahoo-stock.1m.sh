 #
  # yahoo stock info plugin
  # much simpler than stock plugin, no API key required
 +# randomises the order of stocks so it keeps changing in the menu bar
  # by http://srinivas.gs
  
  
 -echo -n "GOOG:"; curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=goog&f=l1'
 -echo -n "AAPL:"; curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=aapl&f=l1'
 +stock[0]="GOOG"
 +stock[1]="AAPL"
 +stock[2]="AMZN"
  
 +shuffle() {
 +   local i tmp size max rand
 +   size=${#stock[*]}
 +   max=$(( 32768 / size * size ))
 +
 +   for ((i=size-1; i>0; i--)); do
 +      while (( (rand=$RANDOM) >= max )); do :; done
 +      rand=$(( rand % (i+1) ))
 +      tmp=${stock[i]} stock[i]=${stock[rand]} stock[rand]=$tmp
 +   done
 +}
 +shuffle
 +
 +
 +s='http://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'
 +
 +n=${#stock[@]}
 +n=$((n-1))
 +
 +for (( c=0; c<=$n; c++ ))
 +do
 +	echo -n ${stock[$c]}; echo -n ":"; curl -s echo ${s/stock_symbol/${stock[$c]}}
 +done

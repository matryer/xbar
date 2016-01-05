#!/bin/bash
#
# yahoo stock info plugin
# much simpler than stock plugin, no API key required
# by http://srinivas.gs


echo -n "GOOG:"; curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=goog&f=l1'
echo -n "AAPL:"; curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=aapl&f=l1'


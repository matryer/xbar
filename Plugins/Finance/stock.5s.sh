#!/bin/bash

# stock info plugin
#
# by clark
# email:5200374@qq.com
# use baidu stock api to monitor stock price
# the price only show up in market time.
if [ $(date +%H) -lt 9 ]; then
  echo "not trade time|color=red"
  exit
fi
if [ $(date +%H) -gt 15 ]; then
  echo "not trade time|color=red"
  exit
fi
if [ $(date +%w) -gt 5 ]; then
  echo "not trade time|color=red"
  exit
fi
if [ $(date +%w) -eq 0 ]; then
  echo "not trade time|color=red"
  exit
fi

# change folloing code to select your stock
stocknum="sz000410"
# apply for your own api key at http://apistore.baidu.com/apiworks/servicedetail/115.html
apikey="apikey:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

curl  --get --include  "http://apis.baidu.com/apistore/stockservice/stock?stockid=$stocknum&list=1"  -H "$apikey" -s|grep "{"|awk -F "," '{print $4,$9,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36}'|awk -F ":| " '{printf"%s,%.2f,%.2f％|color=red\ns5:%.2f,%.0f|color=green\ns4:%.2f,%.0f|color=green\ns3:%.2f,%.0f|color=green\ns2:%.2f,%.0f|color=green\ns1:%.2f,%.0f|color=green\nb1:%.2f,%.0f|color=red\nb2:%.2f,%.0f|color=red\nb3:%.2f,%.0f|color=red\nb4:%.2f,%.0f|color=red\nb5:%.2f,%.0f|color=red\n",$2,$4,$6,$46,$44,$42,$40,$38,$36,$34,$32,$30,$28,$10,$8,$14,$12,$18,$16,$22,$20,$26,$24}'

#!/bin/bash

# Active WIFI Name
# BitBar plugin
#
# by Jiri
#
# Displays currently connected WIFI Name

WIFINAME=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'`

echo -n "WIFI: "
echo $WIFINAME

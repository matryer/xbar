#!/bin/bash

# Vpn checker
# BitBar plugin
#
# by pldubouilh
#
# Simply checks the existence of tun0

# From my infamous one-liner
# ((ifconfig | grep tun0) || (killall Firefox))

if [[ `ifconfig | grep tun0` ]]; then
	echo "VPN Up | color=green"
else
	#killall Firefox
	echo "VPN Down | color=red"
fi



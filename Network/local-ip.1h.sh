#!/bin/bash

# local-ip
# BitBar plugin
#
# by Mat Ryer
#
# Gets the current local IP address, and shows more information in
# the details.

ipconfig getifaddr en0
echo "---"
ifconfig en0

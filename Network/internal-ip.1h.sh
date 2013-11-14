#!/bin/bash

# internal-ip
# BitBar plugin
#
# by Mat Ryer
#
# Gets the current internal IP address, and shows more information in
# the details.

ipconfig getifaddr en0; 
echo "---"
echo "(Internal IP address)"
echo "---"
ifconfig en0

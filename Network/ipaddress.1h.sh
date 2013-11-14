#!/bin/bash

# ipaddress
# by Mat Ryer
#
# Gets the current IP address, and shows more information in
# the details.

ipconfig getifaddr en0
echo "---"
ifconfig en0

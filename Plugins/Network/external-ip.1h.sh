#!/bin/bash

# external-ip
# BitBar plugin
#
# by Mat Ryer
#
# Gets the current external IP address.

curl -s ipecho.net/plain; echo
echo "---"
echo "(External IP address)"

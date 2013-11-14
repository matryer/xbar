#!/bin/bash

# open-ports
# BitBar plugin
#
# by Mat Ryer
#
# Gets the current TCP and UDP ports that are open.

echo -n "Ports:"
lsof -i | wc -l
echo
echo "---"
lsof -i
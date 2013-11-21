#!/bin/bash

# Is BitBar?
# BitBar plugin
#
# by Mat Ryer and Tyler Bunnell
#
# Example script showing how to let your scripts determine
# whether they are expected to deliver BitBar output or not.
#
# Put this script in your BitBar plugins folder and notice
# it says "In BitBar", but run it directly in Terminal, and it
# says "In Terminal".

if [ $BitBar ]; then
  # this script is being called from within
  # BitBar.
  echo "In BitBar"
else
  # this script is being called from within
  # Terminal.
  echo "In Terminal"
fi

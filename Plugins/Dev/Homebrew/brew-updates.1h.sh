#!/bin/bash

####
# List available updates from Homebrew (OS X)
###

exit_with_error() {
  echo "err | color=red";
  exit 1;
}

/usr/local/bin/brew update > /dev/null || exit_with_error;

UPDATES=`/usr/local/bin/brew outdated --verbose`;

UPDATE_COUNT=`echo "$UPDATES" | wc -l | sed -e 's/^[[:space:]]*//'`;

echo "↑$UPDATE_COUNT"
echo "---";
echo "$UPDATES";

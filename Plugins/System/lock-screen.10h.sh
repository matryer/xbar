#!/bin/bash

# Chris Tomkins-Tinch
# github.com/tomkinsc

if [ "$1" = 'lock' ]; then
  # To perform a sleep action
  # Requires "password after sleep or screen saver begins" to be set in Security preferences
  #osascript -e 'tell application "Finder" to sleep'

  # To perform a lock (login screen) action
  # Requires "Fast User Switching" to be enabled in system Login preferences
  /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
  exit
fi

echo "🔒"
echo '---'
echo "Lock Now | bash=$0 param1=lock terminal=false"

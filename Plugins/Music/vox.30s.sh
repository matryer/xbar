#!/bin/bash

# Get current Vox status with play/pause button
#
# by Daniel Kay (daniel@enthusiasm.cc)
# inspired by Jason Tokoph (jason@tokoph.net)
#
# Shows current track information from vox 

if [ "$1" = 'launch' ]; then
  osascript -e 'tell application "Vox" to activate'
  exit
fi

if [ $(osascript -e 'application "Vox" is running') = "false" ]; then
  echo "♫"
  echo "---"
  echo "Vox is not running"
  echo "Launch Vox| bash=$0 param1=launch terminal=false"
  exit
fi

if [ "$1" = 'playpause' ]; then
  osascript -e 'tell application "Vox" to playpause'
  exit
fi

state=`osascript -e 'tell application "Vox" to set state to player state'`;

if [ $state = "1" ]; then
  state_icon="🎵"
else
  state_icon="⚫"
fi

track=`osascript -e 'tell application "Vox" to set trackname to track'`;
track=${track//|/-} 
artist=`osascript -e 'tell application "Vox" to set artistname to artist'`;
album=`osascript -e 'tell application "Vox" to set albumname to album'`;
trackURL=`osascript -e 'tell application "Vox" to set state to trackURL'`;

if [[ $trackURL =~ "soundcloud" ]]
then
    echo $state_icon $track
else
    echo $state_icon $artist - $track [$album]
fi

echo "---"

case "$0" in
  *\ * )
   echo "Your script path | color=#ff0000"
   echo "($0) | color=#ff0000"
   echo "has a space in it, which BitBar does not support. | color=#ff0000"
   echo "Play/Pause/Next/Previous buttons will not work. | color=#ff0000"
  ;;
esac

if [ $state = "1" ]; then
  echo "❚❚ Pause | bash=$0 param1=playpause terminal=false"
else
  echo "▶ Play | bash=$0 param1=playpause terminal=false"
fi

#!/bin/bash

# Mounted Disk Capacity
# BitBar plugin
#
# by Carlson Orozco
#
# Show mounted disks capacity
# Refresh every 5 seconds

if [ $(find /Volumes -maxdepth 1 -type d | wc -l) = "1" ]; then
    echo "⏏ | color=gray"
    exit
fi

echo "⏏ | color=black"
echo '---'

ls -p /Volumes | grep / |
while IFS= read -r line; do
    drive=${line%?}
    free_space=$(diskutil info /Volumes/$drive | grep "Volume Free Space:" | cut -d '(' -f 1)
    total_size=$(diskutil info /Volumes/$drive | grep "Total Size:" | cut -d '(' -f 1)
    echo "$drive | color=black"
    echo "├─ $free_space"
    echo "└─ $total_size"
done

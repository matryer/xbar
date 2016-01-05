#!/usr/bin/env bash

# bandwidth
# BitBar plugin
#
# by Ant Cosentino <ant@io.co.za>
# Gets up/down (kilobytes per second) across available network interfaces.
# Depends on ifstat (brew install-able)

export PATH="/usr/local/bin:${PATH}"
INTERFACES=$(node -e 'process.stdout.write(Object.keys(require("os").networkInterfaces()).join(" "));')

echo "▲ $(ifstat -n -w -i en0 0.1 1 | tail -n 1 | awk '{print $1, " - ", $2;}') ▼"
echo "---"
for INTERFACE in ${INTERFACES}; do
  if [[ ${INTERFACE} != "en0" ]]; then
    echo "${INTERFACE}: ▲ $(ifstat -n -w -i ${INTERFACE} 0.1 1 | tail -n 1 | awk '{print $1, " - ", $2;}') ▼"
  fi
done

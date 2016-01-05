#!/bin/bash

# OpenUI5 Latest Version Display
# BitBar plugin
#
# by DJ Adams

URI="https://openui5.hana.ondemand.com/resources/sap-ui-version.json"

VER=$(curl -s --compressed $URI | grep '"version"' | head -1 | sed -E 's/^.+([0-9]+\.[0-9]+\.[0-9]+).+$/\1/')

echo $VER

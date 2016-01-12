#!/bin/sh

./../Vendor/create-dmg/create-dmg \
--volname "BitBar installer" \
--volicon bitbar-2048.icns \
--background background.jpg \
--window-pos 200 120 \
--window-size 800 400 \
--icon-size 100 \
--icon BitBar.app 200 190 \
--hide-extension BitBar.app \
--app-drop-link 600 185 \
BitBar-installer.dmg \
../Build/Release/

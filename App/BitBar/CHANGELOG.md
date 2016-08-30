# BitBar Changes

## v2

* Added [streaming through stdout](Docs/LongRunningPlugins.md#streaming-through-stdout)

## v1.9.2

* Added Sparkle updater

## v1.9.1

* Bug fixes and performance enhancements

## v1.9

* Restored distributable BitBar
* BitBar now requires OS X 10.7 to fix a crash on refresh and wake from sleep
* Added support for single click action from the status bar (`href`, `bash` and `refresh`)
* Added support for separators in sub menus
* Added update check (Preferences menu will show you when there's a newer version available)
* Various other bug fixes

## v1.8

* Added `emojize` parameter
* Added sub menus
* Added ANSI color code support and `ansi=false` option to turn it off
* Significant bug fixes and performance enhancements

## v1.7

* Added `image` and `templateImage` parameters (Base64 encoded images)
* Memory leak fixes and bug fixes

## v1.6

* Added [distributable BitBar](https://github.com/matryer/bitbar/blob/master/Docs/DistributingBitBar.md) to allow you to bundle a BitBar app with plugins, and distribute a tamper free version.
* Added ability to refresh plugins remotely via the [URL scheme](https://github.com/matryer/bitbar/blob/master/Docs/URLScheme.md) - #149 and #216
* Integration with Slack - please join us: [![Slack Status](https://getbitbar.herokuapp.com/badge.svg)](https://getbitbar.herokuapp.com/)
* Added ability to [hide Preferences menu](https://github.com/matryer/bitbar/blob/master/Docs/DistributingBitBar.md#settings).
* Small UI improvements based on feedback from lovely users just like you
* Updated dependencies to fix crash and memory leak

* See a [complete list of all changes in this release](https://github.com/matryer/bitbar/compare/v1.5.1...master)

## v1.5

Features:

* Added `trim=false` option to give plugin authors control of whitespace - #182
* Added `alternate=true` option to allow option key menu items - #218
* Tasks now run in background (preventing menu bar items from locking) - #181
* Plugins will reset on wake from sleep - #184
* Added URL scheme for opening and downloading plugins - #224

Other:

* Work to address duplicate items - #21
* Updated "Browse plugins..." link to getbitbar.com
* Improved docs
* "Open at login" was getting reset every time - now it's remembered - #169
* Warnings and static analyzer errors are resolved

## v1.4

Features:

* Made `$BitBarDarkMode` environment variable available to plugins - #155
* Ability to hide items from the dropdown - #102
* Selecting a Plugin folder (rather than having to navigate inside it) is enough - better UI - #120
* `Reset` renamed to `Refresh` to make it clearer - #82
* `refresh` parameter indicates that an item should issue the refresh of a plugin - #48
* Added support for `length` parameter - #131

Other:

* Started tracking changes
* Fixed vertical alignment - #153
* Numbers are now monospace - #148
* Removed unnecessary separators from BitBar menu - #143
* General bug fixes and improvements
* Support spaces in paths
* Fonts will be checked, and a default will be used if they're not available
* Plugins now live in their own repo - #78

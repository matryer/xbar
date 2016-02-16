# BitBar Changes

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
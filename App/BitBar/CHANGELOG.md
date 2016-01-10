# BitBar Changes

## v1.4

Features:

  * Made `$BitBarDarkMode` environment variable available to plugins - https://github.com/matryer/bitbar/pull/155
  * Ability to hide items from the dropdown - https://github.com/matryer/bitbar/issues/102
  * Selecting a Plugin folder (rather than having to navigate inside it) is enough - better UI - https://github.com/matryer/bitbar/issues/120
  * `Reset` renamed to `Refresh` to make it clearer - https://github.com/matryer/bitbar/issues/82
  * `refresh` parameter indicates that an item should issue the refresh of a plugin - https://github.com/matryer/bitbar/pull/48
  * Added support for `length` parameter - https://github.com/matryer/bitbar/pull/131

Other:

  * Started tracking changes
  * Fixed vertical alignment - https://github.com/matryer/bitbar/pull/153
  * Numbers are now monospace - https://github.com/matryer/bitbar/pull/148
  * 
  * Removed unnecessary separators from BitBar menu - https://github.com/matryer/bitbar/issues/143
  * General bug fixes and improvements
  * Support spaces in paths
  * Fonts will be checked, and a default will be used if they're not available
  * Plugins now live in their own repo - https://github.com/matryer/bitbar/issues/78
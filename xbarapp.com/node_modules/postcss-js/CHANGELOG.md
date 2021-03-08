# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

## 3.0.3
* Reverted `package.exports` Node.js 15 fix.

## 3.0.2
* Fixed Node.js 15 warning.

## 3.0.1
* Added funding links.

## 3.0
* Removed support for Node.js 6.x, 8.x, 11.x, and 13.x versions.
* Moved to PostCSS 8.0.
* Added ES modules support.
* Avoid stringification of unitless values (by Rishabh Rathod).

## 2.0.3
* Fix `from` option warning.

## 2.0.2
* Fix `!important` support (by Adam Wathan).

## 2.0.1
* Improve objectifier performance.
* Do not change source `Root` in objectifier.

## 2.0.0
* Remove Node.js 9 and Node.js 4 support.
* Use PostCSS 7.0.

## 1.0.1
* Ignore nodes with `undefined` value.

## 1.0
* Use PostCSS 6.0.

## 0.3
* Add support for at-rules with same name (like `@font-face`).

## 0.2
* Add `!important` support (by Dan Lynch).

## 0.1.3
* Fix rules merge with at-rules.

## 0.1.2
* Add `cssFloat` alias support.

## 0.1.1
* Fix losing rules in parser on same selector (by Bogdan Chadkin).

## 0.1
* Initial release.

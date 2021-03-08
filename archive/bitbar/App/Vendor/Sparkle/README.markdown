# Sparkle [![Build Status](https://travis-ci.org/sparkle-project/Sparkle.svg?branch=master)](https://travis-ci.org/sparkle-project/Sparkle) [![Coverage Status](https://coveralls.io/repos/sparkle-project/Sparkle/badge.svg?branch=master&service=github)](https://coveralls.io/github/sparkle-project/Sparkle?branch=master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/cocoapods/v/Sparkle.svg?maxAge=2592000)]() <a href="https://www.maxcdn.com/?utm_source=sparkle-github&amp;utm_medium=badge&amp;utm_campaign=readme"><img src="https://img.shields.io/badge/sponsored%20by-MaxCDN-orange.svg" alt="sponsored by: MaxCDN"></a>

An easy-to-use software update framework for Cocoa developers.

<img src="Resources/Screenshot.png" width="732" alt="Sparkle shows familiar update window with release notes">

## Changes since 1.5b

* Up-to-date with 10.11 SDK and Xcode 7. Supports macOS 10.7+.
* Cleaned up and modernized code, using ARC and Autolayout.
* Merged bugfixes, security fixes and some features from multiple Sparkle forks.
* Truly automatic background updates (no UI at all) when user agreed to "Automatically download and install updates in the future."
* Ability to mark updates as critical.
* Progress and status notifications for the host app.
* Name of finish_installation.app can be configured to match your app's name.
* Upgraded and more reliable binary delta and code signing verification.

## Features

* True self-updating—the user can choose to automatically download and install all updates.
* Displays a detailed progress window to the user.
* Supports authentication for installing in secure locations.
* Supports Apple Code Signing and DSA signatures for ultra-secure updates.
* Easy to install. Sparkle requires no code in your app, so it's trivial to upgrade or remove the framework.
* Uses appcasts for release information. Appcasts are supported by 3rd party update-tracking programs and websites.
* Displays release notes to the user via WebKit.
* Sparkle doesn't bug the user until second launch for better first impressions.
* Seamless integration—there's no mention of Sparkle; your icons and app name are used.
* Deep delegate support to make Sparkle work exactly as you need.
* Optionally sends system information to the server when checking for updates.
* Supports bundles, preference panes, plugins, and other non-.app software. Can install .pkg files for more complicated products.
* Supports branches due to minimum OS version requirements.

## Requirements

* Runtime: macOS 10.7 or greater
* Build: Xcode 5 and 10.8 SDK or greater
* HTTPS server for serving updates (see [App Transport Security](http://sparkle-project.org/documentation/app-transport-security/))

## API

Sparkle is built with `-fvisibility=hidden -fvisibility-inlines-hidden` which means no symbols are exported by default.
If you are adding a symbol to the public API you must decorate the declaration with the `SU_EXPORT` macro (grep the source code for examples).

## Building the distribution package

`cd` to the root of the Sparkle source tree and run `make release`. Sparkle-*VERSION*.tar.bz2 will be created in a temporary directory and revealed in Finder after the build has completed.

Alternatively, build the Distribution scheme in the Xcode UI.

## Project Sponsor

[MaxCDN](https://www.maxcdn.com/?utm_source=sparkle-github&utm_medium=link&utm_campaign=readme-footer)

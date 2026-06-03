[![](xbarapp.com/public/img/xbar-menu-preview.png)](https://xbarapp.com/)

# xbar (Apple Silicon fork)

> **This is a maintained fork of [matryer/xbar](https://github.com/matryer/xbar) with native Apple Silicon support.**
>
> The original project is unmaintained. Its releases are x86-only binaries that require Rosetta 2 — and [Apple is removing Rosetta 2 support](https://support.apple.com/en-us/102527) in a future macOS release. This fork builds a **universal binary** (arm64 + amd64) that runs natively on both Apple Silicon and Intel Macs, with no Rosetta 2 required.

---

xbar (the BitBar reboot) lets you put the output from any script/program in your macOS menu bar.

## Download

**[⬇ Download latest release (Universal – Apple Silicon + Intel)](https://github.com/xgitqa/xbar/releases/latest)**

Unzip and drag **xbar.app** to `/Applications`.

> **Note on Gatekeeper:** This build is unsigned. On first launch, right-click → Open to bypass Gatekeeper, or run:
> ```
> xattr -dr com.apple.quarantine /Applications/xbar.app
> ```

## Why this fork?

| | Original (`matryer/xbar`) | This fork (`xgitqa/xbar`) |
|---|---|---|
| Apple Silicon (arm64) | Rosetta 2 only | Native ✓ |
| Intel (amd64) | Native ✓ | Native ✓ |
| Universal binary | No | Yes ✓ |
| Maintained | No (last release 2021) | Yes ✓ |
| Rosetta 2 required | Yes (removed by Apple) | No ✓ |

## Features

  * **Runs natively on Apple Silicon** – no Rosetta 2, no translation layer
  * **Universal binary** – same download works on M1/M2/M3 and Intel Macs
  * Put the output from any script/program in your macOS menu bar
  * Complete rewrite from the ground up in Go using [Wails](https://wails.app)
  * [Browse the plugin repository](https://xbarapp.com/)

## Get started

### Install

1. [Download the latest release](https://github.com/xgitqa/xbar/releases/latest)
2. Unzip and drag **xbar.app** to `/Applications`
3. Launch xbar — plugins live in `~/Library/Application Support/xbar/plugins/`

### Installing plugins

From an xbar menu, choose **Preferences > Plugins...** to discover and manage plugins, or [browse all plugins online](https://xbarapp.com/).

### The Plugin Directory

Plugins live in `~/Library/Application Support/xbar/plugins`.

* If you're transitioning from BitBar, move your plugins into this folder

## Contributing

For plugins, head over to https://github.com/matryer/xbar-plugins.

For issues with this fork (build, Apple Silicon compatibility, etc.), open an issue in this repo.

## Thanks

  * Original xbar by [@matryer](https://github.com/matryer) and [@leaanthony](https://github.com/leaanthony)
  * Thanks to [Chris Ryer](http://www.chrisryer.co.uk/) for the app logo
  * Thanks to all [plugin contributors](https://xbarapp.com/)

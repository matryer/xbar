# Distribution

You can currently choose between two versions of the BitBar app: **BitBar** and **BitBarDistro**. **Both** can be [bundled with plugins](#bundling-plugins). **BitBarDistro** disables user configuration by default. We provide builds of each version with the [latest release](https://github.com/matryer/bitbar/releases/latest).

## Bundling plugins

We recommend using our [bundler script](https://github.com/matryer/bitbar/blob/master/Scripts/bitbar-bundler) for convenience. It takes a version of the BitBar app and the plugins to bundle, copies the plugins into the app bundle and ensures they are executable.

Usage:

```
bitbar-bundler /path/to/BitBar.app /path/to/first-plugin /path/to/second-plugin ...
```

If user configuration is enabled, symbolic links to the bundled plugins are created in the plugin folder selected by the user.

## Settings

You can use `defaults` to set the plugins directory and whether user configuration should be enabled programmatically.

Examples:

```
defaults write com.matryer.BitBar pluginsDirectory "path/to/plugins"
defaults write com.matryer.BitBar userConfigDisabled -bool true
```

For global setting use `/Library/Preferences/com.matryer.BitBar` as domain.

# URL Scheme

The BitBar app registers the custom URL scheme `bitbar://`. The following paths are currently implemented:

- [`openPlugin`](#openplugin) to download and install plugins
- [`refreshPlugin`](#refreshplugin) to refresh plugins
- [`screenshot`](#screenshot) to save plugin screenshots

## openPlugin

Query parameters:

- `src` Source URL

Examples: see [test page](App/BitBar/incoming-url-tests.html)

## refreshPlugin

Query parameters:

- `name` Filename, allowing wildcards. `?` matches one character and `*` matches zero or more characters

This allows for refreshing from the command line using `open`, passing the URL.
For example by chaining it with a semicolon after a command when `terminal=false` can't be used ([full example](https://github.com/matryer/bitbar-plugins/blob/master/System/downloads.1h.sh)).

Example:

```
bitbar://refreshPlugin?name=brew-updates.*?.sh
```

Here `*?` was used to omit the time.

## screenshot

- `pluginPath` Plugin path
- `dst` Destination path, `png` extension
- `margin` Optional spacing in pixels

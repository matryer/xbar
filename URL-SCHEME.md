# URL Scheme

The BitBar app registers the custom URL scheme `bitbar://`. The following paths are currently implemented:

- [`openPlugin`](#openPlugin) to download and install plugins
- [`refreshPlugin`](#refreshPlugin) to refresh plugins

## openPlugin

Query parameters:

- `src` source URL

Examples: see [test page](App/BitBar/incoming-url-tests.html)

## refreshPlugin

Query parameters:

- `name` filename, allowing wildcards. `?` matches one character and `*` matches zero or more characters

This allows for refreshing from the command line using `open`, passing the URL.
For example by chaining it with a semicolon after a command when `terminal=false` can't be used.

Example:

```
bitbar://refreshPlugin?name=brew-updates.*?.sh
```

Here `*?` was used to omit the time.

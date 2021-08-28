[![](xbarapp.com/public/img/xbar-menu-preview.png)](https://xbarapp.com/)

# Welcome to xbar

xbar (the BitBar reboot) lets you put the output from any script/program in your macOS menu bar.

  * **Complete rewrite from the ground up** - in Go by @matryer and @leaanthony - using [Wails.app (build cross-platform desktop apps using Go & HTML/CSS/JS)](https://wails.app)
  * Completely open source
  * [Download latest xbar release](https://github.com/matryer/xbar/releases/latest) - requires macOS Catalina or newer (>= 10.15)
  * [Visit the app homepage at https://xbarapp.com](https://xbarapp.com)
  * [Get started](#get-started) and [installing plugins](#installing-plugins)

Digging deeper:

  * [Browse plugin repository](https://xbarapp.com/)
  * [Guide to writing your own plugins](#writing-plugins)

And finally...

  * [Read the story about how xbar unexpectedly got going](https://medium.com/@matryer/what-happens-when-your-old-open-source-project-unexpectedly-gets-to-the-top-of-hacker-news-31114c6c6efb#.fznvtgskb)
  * [Contributing](#contributing) and [special thanks](#thanks)

## Get started

### Install

* [Download the latest release of xbar](https://github.com/matryer/xbar/releases).

## Installing plugins

From an xbar menu, choose **Preferences > Plugins...** to use the xbar app to discover and manage plugins.

You can [browse all the plugins](https://xbarapp.com/) online, or [write your own](#writing-plugins).

### The Plugin Directory

The plugin directory is folder on your Mac where the plugins live, located at `~/Library/Application Support/xbar/plugins`.

* If you're transitioning from Bitbar, move your plugins into this new folder to install them

## Contributing

If you'd like to contribute a plugin, head over to https://github.com/matryer/xbar-plugins to get started.

Please do not send pull requests to this repo. Open an issue and start a conversation first. PRs will likely not be accepted.

# Writing plugins

To write a plugin, you need to be able to produce some kind of executable (usually a script) that prints out lines of text.

The text is converted into menus by xbar.

### Share your plugin

If you want to add your plugin to the app, please send us a pull request to https://github.com/matryer/xbar-plugins.

  * Ensure the plugin is executable
  * Be sure to include [appropriate Metadata](#metadata) to enhance the plugin's entry on xbarapp.com

### Configure the refresh time

The refresh time is in the filename of the plugin, following this format:

    {name}.{time}.{ext}

  * `name` - The name of the file
  * `time` - The refresh rate (see below)
  * `ext` - The file extension

For example:

  * `date.1m.sh` would refresh every minute.

Most plugins will come with a default, but you can change it to anything you like using the app:

  * 10s - ten seconds
  * 1m - one  minute
  * 2h - two hours
  * 1d - a day

### Ensure the plugin is executable

Ensure the plugin is executable by running `chmod +x plugin.sh`.

## Plugin API

To write a plugin, just write some form of executable script that outputs to the standard output.

* Multiple lines will be cycled through over and over.
* If your output contains a line consisting only of `---`, the lines below it will appear in the dropdown for that plugin, but won't appear inthe menu bar itself.
* Lines beginning with `--` will appear in submenus.
* * Use `----` etc. for nested submenus. Two dashes per level of nesting.
* Your lines might contain `|` to separate the title from other parameters

### Parameters

Use the pipe `|` character to specify extra parameters onto the menu item.

For example:

```
Open website | href=https://xbarapp.com | color=red | key=CmdOrCtrl+o
Open home folder | shell=open | param1="~/"
App version: v1.0 | disabled=true | size=10
```

The supported parameters are:

* `key=shift+k` to add a key shortcut 
* * Use `+` to create combinations
* * Example options: `CmdOrCtrl`, `OptionOrAlt`, `shift`, `ctrl`, `super`, `tab`, `plus`, `return`, `escape`, `f12`, `up`, `down`, `space`
* `href=..` to make the item clickable
* `color=..` to change the text color. eg. `color=red` or `color=#ff0000`
* `font=..` to change the text font. eg. `font=UbuntuMono-Bold`
* `size=..` to change the text size. eg. `size=12`
* `shell=..` to make the item run a given script terminal with your script e.g. `shell=/Users/user/xbar_Plugins/scripts/nginx.restart.sh` if there are spaces in the file path you will need quotes e.g. `shell="/Users/user/xbar Plugins/scripts/nginx.restart.sh"` (`bash` is also supported but is deprecated)
* `param1=` to specify arguments to the script. Additional params like this `param2=foo param3=bar`
* * For example `shell="/Users/user/xbar_Plugins/scripts/nginx.restart.sh" param1=--verbose` assuming that nginx.restart.sh is executable or `shell=/usr/bin/ruby param1=/Users/user/rubyscript.rb param2=arg1 param3=arg2` if script is not executable
* `terminal=..` start bash script without opening Terminal. `true` or `false`
* `refresh=..` to make the item refresh the plugin it belongs to. If the item runs a script, refresh is performed after the script finishes. eg. `refresh=true`
* `dropdown=..` May be set to `true` or `false`. If `false`, the line will only appear and cycle in the status bar but not in the dropdown
* `length=..` to truncate the line to the specified number of characters. A `…` will be added to any truncated strings, as well as a tooltip displaying the full string. eg. `length=10`
* `trim=..` whether to trim leading/trailing whitespace from the title.  `true` or `false` (defaults to `true`)
* `alternate=true` to mark a line as an alternate to the previous one for when the Option key is pressed in the dropdown
* `templateImage=..` set an image for this item. The image data must be passed as base64 encoded string and should consist of only black and clear pixels. The alpha channel in the image can be used to adjust the opacity of black content, however. This is the recommended way to set an image for the statusbar. Use a 144 DPI resolution to support Retina displays. The imageformat can be any of the formats supported by Mac OS X
* `image=..` set an image for this item. The image data must be passed as base64 encoded string. Use a 144 DPI resolution to support Retina displays. The imageformat can be any of the formats supported by Mac OS X
* `emojize=false` will disable parsing of github style `:mushroom:` into :mushroom:
* `ansi=false` turns off parsing of ANSI codes.

### Metadata

You must add the following metadata to your source code (usually in comments somewhere):

```
# Metadata allows your plugin to show up in the app, and website.
#
#  <xbar.title>Title goes here</xbar.title>
#  <xbar.version>v1.0</xbar.version>
#  <xbar.author>Your Name, Another author name</xbar.author>
#  <xbar.author.github>your-github-username,another-github-username</xbar.author.github>
#  <xbar.desc>Short description of what your plugin does.</xbar.desc>
#  <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>
#  <xbar.dependencies>python,ruby,node</xbar.dependencies>
#  <xbar.abouturl>http://url-to-about.com/</xbar.abouturl>

# Variables become preferences in the app:
#
#  <xbar.var>string(VAR_NAME="Mat Ryer"): Your name.</xbar.var>
#  <xbar.var>number(VAR_COUNTER=1): A counter.</xbar.var>
#  <xbar.var>boolean(VAR_VERBOSE=true): Whether to be verbose or not.</xbar.var>
#  <xbar.var>select(VAR_STYLE="normal"): Which style to use. [small, normal, big]</xbar.var>
```

* The comment characters can be anything - use what is suitable for your language
* `xbar.title` - The title of the plugin
* `xbar.version` - The version of the plugin (start with `v1.0`)
* `xbar.author` - Comma separated list of authors (primary author first)
* `xbar.author.github` - Comma separated list of github usernames (without `@`)
* `xbar.desc` - A short description of what your plugin does
* `xbar.image` - A hosted image showing a preview of your plugin (ideally open)
* `xbar.dependencies` - Comma separated list of dependencies
* `xbar.abouturl` - Absolute URL to about information
* `xbar.var` - A user-input parameter which will be available as an environment variable with the same name (learn more about [Variables in xbar](https://xbarapp.com/docs/2021/03/14/variables-in-xbar.html))

For a real example, see the [Cycle text and detail plugin source code](https://github.com/matryer/xbar-plugins/blob/master/Dev/Tutorial/cycle_text_and_detail.sh).

### Useful tips

  * If you're writing scripts, ensure it has a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at the top.
  * You can add to `PATH` by including something like `export PATH='/usr/local/bin:/usr/bin:$PATH'` in your plugin script.
  * You can use emoji in the output (find an example in the Music/vox Plugin).
  * If your bash script generates text in another language, set the `LANG` variable with: `export LANG="es_ES.UTF-8"` (for Spanish) to show the text in correct format.
  * If you want to call the plugin script for action, you can use `bash=$0`
  * If your plugin should support Retina displays, export your icon at 36x36 with a resolution of 144 DPI (see [this issue](https://github.com/matryer/xbar/issues/314) for a more thorough explanation).

### Examples

#### One line plugin

    #!/bin/bash
    date

#### Multi-line plugin

    #!/bin/bash

    # the current date and time
    date

    # the current username
    echo $USER

    # the current user id
    id -u

#### Multi-line plugin with extra data

    #!/bin/bash
    echo "One"
    echo "Two"
    echo "Three"
    echo "---"
    echo "Four"
    echo "Five"
    echo "Six"

  * Only One, Two and Three will appear in the top bar
  * Clicking the plugin menu item will show the remaining items in the dropdown

#### Multi-line plugin with links and colors

    #!/bin/bash
    curl -m 1 http://example.com -I >/dev/null 2>&1
    [ $? -gt 0 ] && echo "FAIL | color=red" || echo "OK | color=green"
    echo "---"
    echo "Show Graphs | color=#123def href=http://example.com/graph?foo=bar"
    echo "Show KPI Report | color=purple href=http://example.com/report"

#### Multi-line plugin with fonts and colors

![xbar Example showing colored fonts](https://raw.github.com/xbar/master/Docs/xbar-Example-Menu-Colors-Fonts.png)

    #!/bin/zsh
    FONT=( 'size=14' 'font=UbuntuMono' )
    if ((0)); then echo "DO | $FONT color=orange"
    else           echo "DO | $FONT color=cadetblue"
    echo "---"
    ...

#### Plugin with variables

Specifying variables in the metadata will cause end-users to be prompted
for values when they install the plugin.

From there, the values will be available as environment variables.

```bash
#!/bin/zsh

# ... other metadata ...
#
# <xbar.var>string(VAR_API_KEY=""): API key to get access to remote data.</xbar.var>

# VAR_API_KEY will be available as an environment variable
load_data -apikey=$VAR_API_KEY
```

#### Detecting dark mode

When the system appearance changes, xbar will update the following environment variable:

```
XBARDarkMode=true|false
```

* Use `XBARDarkMode` in your plugins to render different things in light/dark modes

### Supported languages

Anything that can write to standard out is supported, but here is a list that have been explicitly tested, along with some helpful tips.

1. Ruby
   - Status: Working
   - Output: `puts "your string here"`
1. Python2
   - Status: Working
   - Output: `print "your string here"`
1. Python3
   - Status: Working
   - Output: `print("your string here")`
   - Caveats: To output unicode shebang has to be in the format `#!/usr/bin/env PYTHONIOENCODING=UTF-8 /path/to/the/python3`
1. JavaScript (`node`)
   - Status: Working
   - Caveats: Shebang has to be in the format `#!/usr/bin/env /path/to/the/node/executable`
   - Output: `console.log("your string here")`
   - Notes:
      - `process.stdout.write` doesn't output desired text.
      - There may be a better way to run JavaScript files.
   - Tips:
      - Use the Node.js [`bitbar` module](https://github.com/sindresorhus/bitbar) to simplify plugin creation.
1. CoffeeScript (`coffee`)
   - Status: Working
   - Caveats:
      - Shebang has to be in the format `#!/usr/bin/env /path/to/the/coffee/executable`
      - `coffee` shebang also had to be modified.
         - `#!/usr/bin/env /path/to/the/node/executable`
   - Output: `console.log "your string here"`
   - Notes:
      - `process.stdout.write` doesn't output desired text.
      - There may be a better way to run CoffeeScript files.
1. Swift (Interpreted)
   - Status: Working
   - Output: `print("your string here")`
1. Swift (Compiled)
   - Status: Working
   - Caveats: You still need a file extension (`file.1s.cswift`)
   - Output: `print("your string here")`
   - Notes:
      - To compile a swift file, use: `xcrun -sdk macosx swiftc -o file.1s.cswift file.1s.swift`
1. Go (Interpreted)
   - Status: Working
   - Caveats:
      - Your script's shebang must be: `//usr/bin/env go run $0 $@; exit`
      - `go` must be in your `PATH`
   - Output: `Println("your string here")`
1. Go (Compiled)
   - Status: Working
   - Caveats: You still need a file extension (`file.1s.cgo`)
   - Output: `Println("your string here")`
   - Notes
      - To compile a Go file, use: `go build file.1s.go`
1. Lisp
   - Status: Working
   - Caveats: `lisp`/`clisp` must be in your `PATH`
   - Output: `(format t "your string here")`
1. Perl5
   - Status: Working
   - Output: `print "your string here"`
   - Notes
      - Add `-l` to shebang to automatic add newline to print function: `#!/usr/bin/perl -l`
1. PHP
   - Status: Working
   - Output: `echo 'your string here'`
   - Notes
      - Add shebang `#!/usr/bin/php` 
   - Utilities:
      - xbar PHP Formatter - <https://github.com/SteveEdson/bitbar-php>  

## Advanced APIs

### xbar:// control API

It is possible to control xbar using special `xbar://` URLs:

* `xbar://app.xbarapp.com/openPlugin?path=path/to/plugin` - `openPlugin` opens a plugin in the app
* `xbar://app.xbarapp.com/refreshPlugin?path=path/to/plugin` - `refreshPlugin` refreshes a specific plugin
* `xbar://app.xbarapp.com/refreshAllPlugins` - `refreshAllPlugins` refreshes all plugins

### Plugin variable JSON files

Variables are stored in JSON files alongside your plugin. The key is the name of the Variable and the name of the environment variable. The values are the user's preferences.

You can programmatically modify the JSON files to adjust the values. Use the refresh control API above to refresh plugins after changing variables.

For example, the variables file for the `tail.5s.sh` plugin looks like this:

```json
{
	"VAR_FILE": "./001-tail.5s.sh",
	"VAR_LINES": 15
}
```

### Xbar config

You can control xbar behaviour by modifying the `/Library/Application Support/xbar/xbar.config.json` file:

* This file doesn't exist by default, you may need to create it.

```json
{
	"autoupdate": true,
	"terminal": {
		"appleScriptTemplate2": ""
	}
}
```

* Changes take effect next time xbar starts
* `autoupdate` - (boolean) whether to keep xbar automatically updated or not
* `terminal.appleScriptTemplate2` - (string) the AppleScript to use when **Run in terminal** option is used (use `"false"` to turn this feature off)

You can delete this file and restart xbar to reset to defaults.

## Thanks

  * Special thanks to [@leaanthony at https://wails.app](https://wails.app) and [@ianfoo](https://github.com/ianfoo), [@gingerbeardman](https://github.com/gingerbeardman), [@iosdeveloper](https://github.com/iosdeveloper), [@muhqu](https://github.com/muhqu), [@m-cat](https://github.com/m-cat), [@mpicard](https://github.com/mpicard), [@tylerb](https://github.com/tylerb) for their help
  * Thanks to [Chris Ryer](http://www.chrisryer.co.uk/) for the app logo - and to [@mazondo](https://twitter.com/mazondo) for the original
  * Thanks for all our [plugin contributors](https://xbarapp.com/) who have come up with some pretty genius things

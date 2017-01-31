# ![BitBar](https://github.com/matryer/bitbar/raw/master/Docs/bitbar-32.png) BitBar [![Build Status](https://travis-ci.org/matryer/bitbar.svg?branch=master)](https://travis-ci.org/matryer/bitbar) [![Slack Status](https://getbitbar.herokuapp.com/badge.svg)](https://getbitbar.herokuapp.com/)

BitBar (by [Mat Ryer - @matryer](https://twitter.com/matryer)) lets you put the output from any script/program in your Mac OS X Menu Bar.

- [Download latest BitBar release](https://github.com/matryer/bitbar/releases/latest) - requires Mac OS X Lion or newer (>= 10.7)
- [Visit the app homepage at https://getbitbar.com](https://getbitbar.com) to install plugins
- [Get started](#get-started) and [installing plugins](#installing-plugins)

Digging deeper:

- [Browse plugin repository](https://github.com/matryer/bitbar-plugins)
- [Guide to writing your own plugins](#writing-plugins)
- [Distributing pre-configured BitBar](https://github.com/matryer/bitbar/blob/master/Docs/DistributingBitBar.md)
- [Learn about integrating with bitbar via the bitbar:// URL scheme](https://github.com/matryer/bitbar/blob/master/Docs/URLScheme.md)

And finally...

- [Read the story about how BitBar unexpectedly got going](https://medium.com/@matryer/what-happens-when-your-old-open-source-project-unexpectedly-gets-to-the-top-of-hacker-news-31114c6c6efb#.fznvtgskb)
- [Contributing](#contributing) and [special thanks](#thanks)

## Examples

Example showing the latest Buy and Sell figures for BitCoins:

![BitBar Example showing BitCoins plugin](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Bitcoins.png)

Click to see the full output, and more options:

![BitBar Example showing menu open](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Menu.png)

Example showing your internal and external IP addresses:

![BitBar Example showing IP Addresses](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-IPs.png)

## Get started

[Get the latest version of BitBar](https://github.com/matryer/bitbar/releases). Copy it to your Applications folder and run it - it will ask you to (create and) select a plugins folder, do so.

[Browse our plugins](https://github.com/matryer/bitbar-plugins) to find useful scripts, or [write your own](https://github.com/matryer/bitbar#writing-plugins).

### It's free, so please donate

If you love this, any BitCoin donations are most welcome, to `1DGoNEYAnjE5DqK7y5zMPR4PLU5HLKpLNR` or [send something useful (Amazon Wishlist)](http://amzn.to/1Pd9yOt).

## Installing plugins

Just download the plugin of your choice into your BitBar plugins directory and choose `Refresh` from one of the BitBar menus.

### Configure the refresh time

The refresh time is in the filename of the plugin, following this format:

```
{name}.{time}.{ext}
```

- `name` - The name of the file
- `time` - The refresh rate (see below)
- `ext` - The file extension

For example:

- `date.1m.sh` would refresh every minute.

Most plugins will come with a default, but you can change it to anything you like:

- 10s - ten seconds
- 1m - one minute
- 2h - two hours
- 1d - a day

### Ensure you have execution rights

Ensure the plugin is executable by running `chmod +x plugin.sh`.

### Using symlinks

Because Git will ignore everything in `Plugins/Enabled`, you can use it to maintain your own plugins directory while still benefitting from tracking (upstream) changes.

#### Example

```
cd Plugins/Enabled

# Enable spotify plugin
ln -s ../Music/spotify.10s.sh

# Enable uptime plugin and change update interval to 30 seconds
ln -s ../System/uptime.1m.sh uptime.30s.sh
```

Then select the `Enabled` folder in your BitBar preferences.

#### Resetting Plugin Directory

In case you made the mistake of choosing a directory with thousands of files as the plugin directory and BitBar getting stuck forever, do this from terminal to reset it:

`defaults delete com.matryer.BitBar`

## Contributing

- Help us [solve bugs](https://github.com/matryer/bitbar/issues?q=is%3Aopen+is%3Aissue+label%3Abug) or [build new features](https://github.com/matryer/bitbar/issues?q=is%3Aopen+is%3Aissue+label%3A%22♡+todo%22).
- If you want to contribute a plugin, please head over to the [Plugin repository](https://github.com/matryer/bitbar-plugins) and submit a pull request. Be sure to read our [guide to writing plugins](https://github.com/matryer/bitbar#writing-plugins) below.

### Development

1. Clone the project `git clone https://github.com/matryer/bitbar.git`
2. Ensure you've `pod` installed on your system using `sudo gem install pod`
3. Install dependencies `make init` within the root of the project
4. Open in XCode `open App/BitBar.xcworkspace`

#### Tests

Make sure you've all dependencies installed on your system by running `make setup`.

- Run the test suit once: `make test`
- Run the suit every time a file changes: `make watch`
- Run a specific test: `make test class=PropertyTest` or `make watch class=PropertyTest`

#### Linting

- `make lint` will display all linting errors
- `make fix` will fix linting errors

#### Release

- Release: `make release`

## Thanks

- Special thanks to [@muhqu](https://github.com/muhqu) and [@tylerb](https://github.com/tylerb) for all their help (see commit history for details)
- Thanks to [Chris Ryer](http://www.chrisryer.co.uk/) for the app logo - and to [@mazondo](https://twitter.com/mazondo) for the original
- Thanks for all our [plugin contributors](https://github.com/matryer/bitbar-plugins) who have come up with some pretty genius things

# Writing plugins

We're always looking for new plugins, so please send us pull requests if you write anything cool or useful.

[Join the conversation with plugin authors and BitBar maintainers on Slack](https://getbitbar.herokuapp.com/).

## Got ideas?

If you've got ideas, or want to report a bug, nip over to our [issues page](=https://github.com/matryer/bitbar-plugins/issues) and let us know.

If you want to contribute, please send us a pull request and we'll add it to our repos.

- Ensure the plugin is executable
- Be sure to include [appropriate Metadata](#metadata) to enhance the plugin's entry on getbitbar.com

## Plugin API

- To write a plugin, just write some form of executable script that outputs to the standard output.
- Multiple lines will be cycled through over and over.
- If your output contains a line consisting only of `---`, the lines below it will appear in the dropdown for that plugin, but won't appear in the menu bar itself.
- Lines beginning with `--` will appear in submenus.
- Output `~~~` from long running scripts to render everything above it and since the last `~~~` ([example](Docs/LongRunningPlugins.md#streaming-through-stdout)).
- Your lines might contain `|` to separate the title from other parameters, such as...

  - `href=..` to make the item clickable
  - `color=..` to change their text color. eg. `color=red` or `color=#ff0000`
  - `font=..` to change their text font. eg. `font=UbuntuMono-Bold`
  - `size=..` to change their text size. eg. `size=12`
  - `bash=..` to make the item run a given script terminal with your script e.g. `bash=/Users/user/BitBar_Plugins/scripts/nginx.restart.sh` if there are spaces in the file path you will need quotes e.g. `bash="/Users/user/BitBar Plugins/scripts/nginx.restart.sh"`
  - `param1=` to specify arguments to the script. additional params like this `param2=foo param3=bar` full example `bash="/Users/user/BitBar_Plugins/scripts/nginx.restart.sh" param1=--verbose` assuming that nginx.restart.sh is executable or `bash=/usr/bin/ruby param1=/Users/user/rubyscript.rb param2=arg1 param3=arg2` if script is not executable
  - `terminal=..` start bash script without opening Terminal. `true` or `false`
  - `refresh=..` to make the item refresh the plugin it belongs to
  - `dropdown=..` May be set to `true` or `false`. If `false`, the line will only appear and cycle in the status bar but not in the dropdown
  - `length=..` to truncate the line to the specified number of characters. A `…` will be added to any truncated strings, as well as a tooltip displaying the full string. eg. `length=10`
  - `trim=..` whether to trim leading/trailing whitespace from the title. `true` or `false` (defaults to `true`)
  - `alternate=true` to mark a line as an alternate to the previous one for when the Option key is pressed in the dropdown
  - `templateImage=..` set an image for this item. The image data must be passed as base64 encoded string or URL and should consist of only black and clear pixels. The alpha channel in the image can be used to adjust the opacity of black content, however. This is the recommended way to set an image for the statusbar. Use a 144 DPI resolution to support Retina displays. The imageformat can be any of the formats supported by Mac OS X
  - `image=..` set an image for this item. The image data must be passed as base64 encoded string or URL. Use a 144 DPI resolution to support Retina displays. The imageformat can be any of the formats supported by Mac OS X
  - `emojize=false` will disable parsing of github style `:mushroom:` into :mushroom:
  - `ansi=false` turns off parsing of ANSI codes.
  - `checked=true` for a checkmark

### Metadata

To enhance your entry on [getbitbar.com](https://getbitbar.com/), add the following metadata to your source code (usually in comments somewhere):

```
# <bitbar.title>Title goes here</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Your Name</bitbar.author>
# <bitbar.author.github>your-github-username</bitbar.author.github>
# <bitbar.desc>Short description of what your plugin does.</bitbar.desc>
# <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>
# <bitbar.dependencies>python,ruby,node</bitbar.dependencies>
# <bitbar.abouturl>http://url-to-about.com/</bitbar.abouturl>
# <bitbar.droptypes>filenames,public.url</bitbar.droptypes>
# <bitbar.demo>--demo</bitbar.demo>
```

- The comment characters can be anything - use what is suitable for your language
- `bitbar.title` - The title of the plugin
- `bitbar.version` - The version of the plugin (start with `v1.0`)
- `bitbar.author` - Your name
- `bitbar.author.github` - Your github username (without `@`)
- `bitbar.desc` - A short description of what your plugin does
- `bitbar.image` - A hosted image showing a preview of your plugin (ideally open)
- `bitbar.dependencies` - Comma separated list of dependencies
- `bitbar.abouturl` - Absolute URL to about information
- `bitbar.droptypes` - [Uniform type identifiers](https://developer.apple.com/library/mac/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html) or `filenames`, comma separated. Plugin is executed with arguments `-type` and the dropped item(s) ([example](Docs/DropToPlugin.md#example))
- `bitbar.demo` - Whitespace separated arguments to execute plugin with in demo mode (i.e. when [saving a screenshot](Docs/URLScheme.md#screenshot))

For a real example, see the [Cycle text and detail plugin source code](https://github.com/matryer/bitbar-plugins/blob/master/Tutorial/cycle_text_and_detail.sh).

### Useful tips

- If you're writing scripts, ensure it has a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at the top.
- You can add to `PATH` by including something like `export PATH='/usr/local/bin:/usr/bin:$PATH'` in your plugin script.
- You can use emoji in the output (find an example in the Music/vox Plugin).
- If your bash script generates text in another language, set the `LANG` variable with: `export LANG="es_ES.UTF-8"` (for Spanish) to show the text in correct format.
- If you want to call the plugin script for action, you can use `bash=$0`
- If your plugin should support Retina displays, export your icon at 36x36 with a resolution of 144 DPI (see [this issue](https://github.com/matryer/bitbar/issues/314) for a more thorough explanation).

### Examples

#### One line plugin

```
#!/bin/bash
date
```

#### Multi-line plugin

```
#!/bin/bash

# the current date and time
date

# the current username
echo $USER

# the current user id
id -u
```

#### Multi-line plugin with extra data

```
#!/bin/bash
echo "One"
echo "Two"
echo "Three"
echo "---"
echo "Four"
echo "Five"
echo "Six"
```

- Only One, Two and Three will appear in the top bar
- Clicking the plugin menu item will show all lines

#### Multi-line plugin with links and colors

```
#!/bin/bash
curl -m 1 http://example.com -I >/dev/null 2>&1
[ $? -gt 0 ] && echo "FAIL | color=red" || echo "OK | color=green"
echo "---"
echo "Show Graphs | color=#123def href=http://example.com/graph?foo=bar"
echo "Show KPI Report | color=purple href=http://example.com/report"
```

#### Multi-line plugin with fonts and colors

![BitBar Example showing colored fonts](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Menu-Colors-Fonts.png)

```
#!/bin/zsh
FONT=( 'size=14' 'font=UbuntuMono' )
if ((0)); then echo "DO | $FONT color=orange"
else           echo "DO | $FONT color=cadetblue"
echo "---"
...
```

### Tested languages

Anything that can write to standard out is supported, but here is a list that have been explicitly tested.

1. Ruby

  1. Status: Working
  2. Output: `puts "your string here"`

2. Python2

  1. Status: Working
  2. Output: `print "your string here"`

3. Python3

  1. Status: Working
  2. Output: `print("your string here")`

4. JavaScript (`node`)

  1. Status: Working
  2. Caveats: Shebang has to be in the format `#!/usr/bin/env /path/to/the/node/executable`
  3. Output: `console.log("your string here")`
  4. Notes:

    1. `process.stdout.write` doesn't output desired text.
    2. There may be a better way to run JavaScript files.

  5. Tips:

    1. Use the Node.js [`bitbar` module](https://github.com/sindresorhus/bitbar) to simplify plugin creation.

5. CoffeeScript (`coffee`)

  1. Status: Working
  2. Caveats:

    1. Shebang has to be in the format `#!/usr/bin/env /path/to/the/coffee/executable`
    2. `coffee` shebang also had to be modified.
    3. `#!/usr/bin/env /path/to/the/node/executable`

  3. Output: `console.log "your string here"`

  4. Notes:

    1. `process.stdout.write` doesn't output desired text.
    2. There may be a better way to run CoffeeScript files.

6. Swift (Interpreted)

  1. Status: Working
  2. Output: `print("your string here")`

7. Swift (Compiled)

  1. Status: Working
  2. Caveats: You still need a file extension (`file.1s.cswift`)
  3. Output: `print("your string here")`
  4. Notes:

    1. To compile a swift file, use: `xcrun -sdk macosx swiftc -o file.1s.cswift file.1s.swift`

8. Go (Interpreted)

  1. Status: Working
  2. Caveats:

    1. Your script's shebang must be: `//usr/env/bin go run $0 $@; exit`
    2. `go` must be in your `PATH`

  3. Output: `Println("your string here")`

9. Go (Compiled)

  1. Status: Working
  2. Caveats: You still need a file extension (`file.1s.cgo`)
  3. Output: `Println("your string here")`
  4. Notes

    1. To compile a Go file, use: `go build file.1s.go`

10. Lisp

  1. Status: Working
  2. Caveats: `lisp`/`clisp` must be in your `PATH`
  3. Output: `(format t "your string here")`

11. Perl5

  1. Status: Working
  2. Output: `print "your string here"`
  3. Notes

  4. Add `-l` to shebang to automatic add newline to print function: `#!/usr/bin/perl -l`

12. PHP

  1. Status: Working
  2. Output: `echo 'your string here'`
  3. Notes

  4. Add shebang `#!/usr/bin/php`

  5. Utilities:

  6. BitBar PHP Formatter - <https://github.com/SteveEdson/bitbar-php>

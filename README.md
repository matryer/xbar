# ![BitBar](https://github.com/matryer/bitbar/raw/master/Docs/bitbar-32.png) BitBar

BitBar (by [Mat Ryer - @matryer](https://twitter.com/matryer)) lets you put the output from any script/program in your Mac OS X Menu Bar.

  * [Download](https://github.com/matryer/bitbar/releases) and [View plugin repository](https://github.com/matryer/bitbar-plugins)
  * [Get started](#get-started)
  * [Installing plugins](#installing-plugins)
  * [Contributing](#contributing)
  * [Thanks](#thanks)
  * [Guide to writing plugins](https://github.com/matryer/bitbar#writing-plugins)

Example showing the latest Buy and Sell figures for BitCoins:

![BitBar Example showing BitCoins plugin](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Bitcoins.png)

Click to see the full output, and more options:

![BitBar Example showing menu open](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Menu.png)

Example showing your internal and external IP addresses:

![BitBar Example showing IP Addresses](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-IPs.png)

## Get started

[Get the latest version of BitBar](https://github.com/matryer/bitbar/releases). Copy it to your Applications folder and run it - it will ask you to (create and) elect a plugins folder, do so.

Homebrew Cask users can, alternatively, install BitBar by running `brew cask install bitbar`.

[Browse our plugins](https://github.com/matryer/bitbar-plugins) to find useful scripts, or [write your own](https://github.com/matryer/bitbar#writing-plugins).

### It's free, so please donate

If you love this, any BitCoin donations are most welcome, to `1DGoNEYAnjE5DqK7y5zMPR4PLU5HLKpLNR` or [send something useful (Amazon Wishlist)](http://amzn.to/1Pd9yOt).

## Installing plugins

Just download the plugin of your choice into your BitBar plugins directory and choose 'Reset' from one of the BitBar menus. 

### Configure the refresh time

The refresh time is in the filename of the plugin, following this format:

    {name}.{time}.{ext}

  * `name` - The name of the file
  * `time` - The refresh rate (see below)
  * `ext` - The file extension

For example:

  * `date.1m.sh` would refresh every minute.

Most plugins will come with a default, but you can change it to anything you like:

  * 10s - ten seconds
  * 1m - one minute
  * 2h - two hours
  * 1d - a day

### Ensure you have execution rights

Ensure the plugin is executable by running `chmod +x plugin.sh`.

### Using symlinks

Because Git will ignore everything in `Plugins/Enabled`, you can use it to maintain your own plugins directory while still benefitting from tracking (upstream) changes.

#### Example

	cd Plugins/Enabled
	
	# Enable spotify plugin
	ln -s ../Music/spotify.10s.sh
	
	# Enable uptime plugin and change update interval to 30 seconds
	ln -s ../System/uptime.1m.sh uptime.30s.sh
	
Then select the `Enabled` folder in your BitBar preferences.

#### Resetting Plugin Directory

In case you made the mistake of choosing a directory with thousands of files as the plugin directory and BitBar getting stuck forever, do this from terminal to reset it:

`defaults delete com.matryer.BitBar`

## Contributing

  * If you want to contribute a plugin, please head over to the [Plugin repository](https://github.com/matryer/bitbar-plugins) and submit a pull request. Be sure to read our [guide to writing plugins](https://github.com/matryer/bitbar#writing-plugins) below.

### BitBar app

To work on the BitBar app, fork, then clone this repo.

In terminal, navigate to the project directory and run:

```
git submodule init && git submodule update
```

## Thanks

  * Special thanks to [@muhqu](https://github.com/muhqu) and [@tylerb](https://github.com/tylerb) for all their help (see commit history for details)
  * Thanks to [Chris Ryer](http://www.chrisryer.co.uk/) for the app logo - and to [@mazondo](https://twitter.com/mazondo) for the original
  * Thanks for all our [plugin contributors](https://github.com/matryer/bitbar-plugins) who have come up with some pretty genius things

# Writing plugins

We're always looking for new plugins, so please send us pull requests if you write anything cool or useful.

### Got ideas?

If you've got ideas, or want to report a bug, nip over to our [issues page](=https://github.com/matryer/bitbar-plugins/issues) and let us know.

If you want to contribute, please send us a pull request and we'll add it to our repos.

  * Ensure the plugin is executable
  * Include an update to the list of plugins
  * Please add your name and a link to the Contributors list

## Plugin API

  * To write a plugin, just write some form of executable script that outputs to the standard output.
  * Multiple lines will be cycled through over and over.
  * If your output contians a line consisting only of `---`, the lines below it will appear in the dropdown for that plugin, but won't appear in the menu bar itself.
  * Your lines might contain `|` to separate the title from other parameters, such as...
    * `href=..` to make the dropdown items clickable
    * `color=..` to change their text color. eg. `color=red` or `color=#ff0000`
    * `font=..` to change their text font. eg. `font=UbuntuMono-Bold`
    * `size=..` to change their text size. eg. `size=12`
    * `bash=..` to make the dropdown run a given script terminal with your script e.g. `bash="/Users/user/BitBar_Plugins/scripts/nginx.restart.sh --verbose"`
    * `terminal=..` if need to start bash script without open Terminal may be true or false
    * `refresh=..` to make the dropdown items refresh the plugin it belongs to
    * `dropdown=..` May be set to `true` or `false`. If `false`, the line will only appear and cycle in the status bar but not in the dropdown
  * If you're writing scripts, ensure it has a shebang at the top.
  * You can add to `PATH` by including something like `export PATH='/usr/local/bin:/usr/bin:$PATH'` in your plugin script.
  * You can use emoji in the output (find an example in the Music/vox Plugin).

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
  * Clicking the plugin menu item will show all lines


#### Multi-line plugin with links and colors

    #!/bin/bash
    curl -m 1 http://example.com -I >/dev/null 2>&1
    [ $? -gt 0 ] && echo "FAIL | color=red" || echo "OK | color=green"
    echo "---"
    echo "Show Graphs | color=#123def href=http://example.com/graph?foo=bar"
    echo "Show KPI Report | color=purple href=http://example.com/report"

#### Multi-line plugin with fonts and colors

![BitBar Example showing colored fonts](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Menu-Colors-Fonts.png)

    #!/bin/zsh
    FONT=( 'size=14' 'font=UbuntuMono' )
    if ((0)); then echo "DO | $FONT color=orange"
    else           echo "DO | $FONT color=cadetblue"
    echo "---"
    ...


### Tested languages

Anything that can write to standard out is supported, but here is a list that have been explicitally tested.

1. Ruby
  1. Status: Working
  1. Output: `puts "your string here"`
1. Python2
  1. Status: Working
  1. Output: `print "your string here"`
1. Python3
  1. Status: Working
  1. Output: `print("your string here")`
1. JavaScript (`node`)
  1. Status: Working
  1. Caveats: Shebang has to be in the format `#!/usr/bin/env /path/to/the/node/executable`
  1. Output: `console.log("your string here")`
  1. Notes:
    1. `process.stdout.write` doesn't output desired text.
    1. There may be a better way to run JavaScript files.
1. CoffeeScript (`coffee`)
  1. Status: Working
  1. Caveats:
    1. Shebang has to be in the format `#!/usr/bin/env /path/to/the/coffee/executable`
    1. `coffee` shebang also had to be modified.
      1. `#!/usr/bin/env /path/to/the/node/executable`
  1. Output: `console.log "your string here"`
  1. Notes:
    1. `process.stdout.write` doesn't output desired text.
    1. There may be a better way to run CoffeeScript files.
1. Swift (Interpreted)
  1. Status: Working
  1. Output: `print("your string here")`
1. Swift (Compiled)
  1. Status: Working
  1. Caveats: You still need a file extension (`file.cswift`)
  1. Output: `print("your string here")`
  1. Notes:
    1. To compile a swift file, use: `xcrun -sdk macosx swiftc -o file.1s.cswift file.1s.swift`

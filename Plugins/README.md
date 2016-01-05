# BitBar Plugins

This repo contains scripts, programs and command-line tools that add functionality to [BitBar](https://github.com/stretchr/bitbar#get-started).

* [Available Plugins](#available-plugins)
* [Contributing plugins](#write-your-own)

### How to use them

  * Just drop the plugin into your BitBar plugins folder
  * Make sure it's executable (in Terminal, do `chmod +x plugin.sh`)
  * Then choose `Reset` from the BitBar menus

###Available Plugins

####Bitcoin
- Bitstamp last BTC Price
- Coinbase.com BTC Index

####Developer
- Homebrew available updates

####Finance
- Stock tracker

####Music
- iTunes (shows current track information from iTunes)
- Spotify (Shows current track information from Spotify)

####Network
- Bandwidth Usage
- External IP
- Internal IP
- Ping

####System
- Clipboard History
- Real CPU Usage
- Unix time
- Uptime
- USB Device Info

#####Battery
- Battery percentage for bluetooth Mouse
- Battery percentage for bluetooth Keyboard

####Web
- SAP version
- StackOverflow

##Contributors

Special thanks to everyone who has contributed:

- Bhagya Silva - [http://about.me/bhagyas](http://about.me/bhagyas)
- Jason Tokoph - [http://jasontokoph.com](http://jasontokoph.com)
- Trung Đinh Quang - [https://github.com/trungdq88](https://github.com/trungdq88)
- Alexandre Espinosa Menor - [https://github.com/alexandregz](https://github.com/alexandregz)
- Dan Turkel - [https://danturkel.com/](https://danturkel.com/)
- Raemond Bergstrom-Wood - [https://github.com/RaemondBW](https://github.com/RaemondBW)

## Write your own

We're always looking for new plugins, so please send us pull requests if you write anything cool or useful.

### Got ideas?

If you've got ideas, or want to report a bug, nip over to our [issues page](https://github.com/stretchr/bitbar/issues) and let us know.

If you want to contribute, please send us a pull request and we'll add it to our repos.

  * Ensure the plugin is executable
  * Include an update to the list of plugins on https://github.com/matryer/bitbar/blob/master/Plugins/README.md
  * Please add your name and a link to the Contributors list on https://github.com/matryer/bitbar/blob/master/Plugins/README.md

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
  * If you're writing scripts, ensure it has a shebang at the top.
  * You can add to `PATH` by including something like `export PATH='/usr/local/bin:/usr/bin:$PATH'` in your plugin script.

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

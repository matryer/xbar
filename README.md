# BitBar

![BitBar](https://github.com/stretchr/bitbar/raw/master/Docs/BitBar-small.png)

BitBar lets you put the output from any script/program in your Mac OS X Menu Bar.

Example showing the latest Buy and Sell figures for BitCoins:

![BitBar Example showing BitCoins plugin](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Bitcoins.png)

Click to see the full output, and more options:

![BitBar Example showing menu open](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-Menu.png)

Example showing your internal and external IP addresses:

![BitBar Example showing IP Addresses](https://raw.github.com/matryer/bitbar/master/Docs/BitBar-Example-IPs.png)

## Get started

[Get the latest version of BitBar](https://github.com/matryer/bitbar/releases) for FREE, or pick a [different release](https://github.com/matryer/bitbar/releases). Copy it to your Applications folder and run it - it will ask you to (create and) elect a plugins folder, do so.

Homebrew Cask users can, alternatively, install BitBar by running `brew cask install bitbar`.

[Browse our plugins](https://github.com/matryer/bitbar/tree/master/Plugins) to find useful scripts, or [write your own](#writing-a-plugin)

## It's free, so please donate

If you use this, please donate BitCoin to `1DGoNEYAnjE5DqK7y5zMPR4PLU5HLKpLNR`.

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

#### Resetting Plugin Directory

In case you made the mistake of choosing a directory with thousands of files as the plugin directory and BitBar getting stuck forever, do this from terminal to reset it:

`defaults delete com.matryer.BitBar`

## Writing a plugin

  * To write a plugin, just write some form of executable script that outputs to the standard output.
  * Multiple lines will be cycled through over and over.
  * If your output contians a line consisting only of `---`, the lines below it will appear in the dropdown for that plugin, but won't appear in the menu bar itself.
  * Your lines might contain `|` to separate the title from other parameters, such as...
    * `href=..` to make the dropdown items clickable
    * `color=..` to change their text color. eg. `color=red` or `color=#ff0000`
    * `font=..` to change their text font. eg. `font=UbuntuMono-Bold`
    * `size=..` to change their text size. eg. `size=12`
    * `bash=..` to make the dropdown items open terminal with your script e.g. `bash=/Users/user/BitBar_Plugins/scripts/nginx.restart.sh`
    * `param1=..` if sh script need params
    * `param2=..` if sh script need params
    * `param3=..` if sh script need params
    * `terminal=..` if need to start bash script without open Terminal may be true or false
  * If you're writing scripts, ensure it has a shebang at the top.

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

### Written something good?

Please send us a pull request and we'll add it to our repos.

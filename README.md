# BitBar

BitBar lets you put the output from any script/program in your Mac OS X Menu Bar.

Example showing the latest Buy and Sell figures for BitCoins:

![BitBar Example showing BitCoins plugin](https://raw.github.com/matryer/bitbar/master/BitBar-Example-Bitcoins.png)

Example showing your internal and external IP addresses:

![BitBar Example showing BitCoins plugin](https://raw.github.com/matryer/bitbar/master/BitBar-Example-IPs.png)

## Get started

  * Get BitBar
  * Run it - it will ask you to (create and) elect a plugins folder, do so
  * Put any scripts, programs or apps in there
  * Ensure they can be executed
  * Enjoy

## Donate

If you use this, please donate a fraction of a BitCoin to `1DGoNEYAnjE5DqK7y5zMPR4PLU5HLKpLNR`.

## Installing plugins

Just download the plugin of your choice into your BitBar plugins directory and choose 'Reset' from one of the BitBar menus.

### Configure the refresh time

The refresh time is in the filename of the plugin.  Most plugins will come with a default, but you can change it to anything you like:

  * 10s - ten seconds
  * 1m - one minute
  * 2h - two hours
  * 1d - a day

### Ensure you have execution rights

Ensure the plugin is executable by running `chmod +x plugin.sh`.

## Writing a plugin

  * To write a plugin, just write some form of executable script that outputs to the standard output.
  * Multiple lines will be cycled through over and over.
  * If your output contians a line consisting only of `---`, the lines below it will appear in the dropdown for that plugin, but won't appear in the menu bar itself.
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

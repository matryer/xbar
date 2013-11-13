# BitBar Plugins

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

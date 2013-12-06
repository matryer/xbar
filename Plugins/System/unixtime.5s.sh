#!/bin/bash

# unixtime
# BitBar plugin
#
# by Mat Ryer
#
# Shows the current unix time.

date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"
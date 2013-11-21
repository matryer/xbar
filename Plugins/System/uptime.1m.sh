#!/bin/bash

# uptime
# BitBar plugin
#
# by Mat Ryer
#
# Shows details about the current uptime of the system.

uptime | sed -n 1'p' | tr ',' '\n'
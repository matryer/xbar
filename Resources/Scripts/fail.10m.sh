#!/bin/bash

cat <<heredoc
Not
---
Show notification | bash="/usr/bin/osascript" param0="-e" param1="display notification \"A Title\" with title \"A Message\""
heredoc

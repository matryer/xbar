#!/bin/bash

cat <<heredoc
test
---
entry 1 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
entry 2 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
Other Entries
--More Entries
----entry 3 | terminal=true bash=/Users/bhartvigsen/script.sh param1=param refresh=true
----entry 4 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
--Smore Entries
----entry 5 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
----entry 6 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
--Last Subentry
----entry 7 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
-
entry 8 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
entry 9 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
-
entry 10 | terminal=false bash=/Users/bhartvigsen/script.sh param1=param refresh=true
heredoc

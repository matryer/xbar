#!/bin/bash

if [ "$ACTION" = "" ] ; then
    if which -s doxygen ; then
        doxygen Documentation/Doxyfile
    else
        echo "warning: Doxygen not found in PATH"
    fi
elif [ "$ACTION" = "clean" ] ; then
    rm -rf "$SRCROOT/Documentation/html"
fi

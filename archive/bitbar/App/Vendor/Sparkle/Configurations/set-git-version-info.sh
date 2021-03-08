#!/bin/sh
set -e

if ! which -s git ; then
    exit 0
fi

if [ -z "$SRCROOT" ] || \
   [ -z "$BUILT_PRODUCTS_DIR" ] || \
   [ -z "$INFOPLIST_PATH" ] || \
   [ -z "$CURRENT_PROJECT_VERSION" ]; then
	echo "$0: Must be run from Xcode!" 1>&2
    exit 1
fi

# Get the current Git master hash
version=$(cd "$SRCROOT" ; git show-ref --abbrev heads/master | awk '{print $1}')
if [ -z "$version" ] ; then
	echo "$0: Can't find a Git hash!" 1>&2
    exit 0
fi

version="$CURRENT_PROJECT_VERSION git-$version"

# and use it to set the CFBundleShortVersionString value
export PATH="$PATH:/usr/libexec"
PlistBuddy -c "Set :CFBundleShortVersionString '$version'" \
    "$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"

#!/bin/bash
set -e

VERSION=`git describe --tags`

echo ""
echo "  xbar ${VERSION}..."
echo ""
echo -n $VERSION > .version

wails build -o xbar

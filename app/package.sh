#!/bin/bash

VERSION=`git describe --tags`

# usage:
#   git tag -a v0.1.0 -m "release tag."
#   git push origin v0.1.0
#   ./build.sh

echo ""
echo ""
echo "\txbar ${VERSION}..."
echo ""
echo ""

sed "s/0.0.0/${VERSION}/" ./assets/mac/info.plist.src > ./assets/mac/info.plist
wails build -package -production -ldflags "-X main.version=${VERSION}"
cd ./build/darwin/desktop
create-dmg ./xbar.app --overwrite --dmg-title "Install xbar"
tar -czvf xbar.${VERSION}.tar.gz ./xbar.app
#rm -rf ./xbar.app

open .

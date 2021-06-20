#!/bin/bash

set -e

VERSION=`git describe --tags`

# usage:
#   git tag -a v0.1.0 -m "release tag."
#   git push origin v0.1.0
#   ./build.sh

echo ""
echo "  xbar ${VERSION}..."
echo ""
echo -n $VERSION > .version

# run all tests
./test.sh

rm -rf ./build/bin

sed "s/0.0.0/${VERSION}/" ./build/darwin/Info.plist.src > ./build/darwin/Info.plist
CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/amd64 -o xbar
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/arm64 -o xbar
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/universal -o xbar
#cd ./build/bin/
#create-dmg ./xbar.app --overwrite --dmg-title "Install xbar"
#tar -czvf xbar.${VERSION}.tar.gz ./xbar.app
#rm -rf ./xbar.app

gon -log-level=debug ./gon.config.json

mv ./build/xbar.dmg "./build/xbar.${VERSION}.dmg"
mv ./build/xbar.zip "./build/xbar.${VERSION}.zip"

open ./build

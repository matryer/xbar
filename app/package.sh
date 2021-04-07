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

rm -rf ./build

sed "s/0.0.0/${VERSION}/" ./assets/mac/Info.plist.src > ./assets/mac/Info.plist
CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/amd64
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/arm64
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/universal
#cd ./build/darwin/desktop
#create-dmg ./xbar.app --overwrite --dmg-title "Install xbar"
#tar -czvf xbar.${VERSION}.tar.gz ./xbar.app
#rm -rf ./xbar.app

gon -log-level=debug ./gon.config.json

mv ./build/xbar.dmg "./build/xbar.${VERSION}.dmg"
mv ./build/xbar.zip "./build/xbar.${VERSION}.zip"

open ./build

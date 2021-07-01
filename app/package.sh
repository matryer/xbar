#!/bin/bash

set -e

VERSION=`git describe --tags`

# usage:
#   git tag -a v0.1.0 -m "release tag."
#   git push origin v0.1.0
#   ./build.sh


# functions
requeststatus() { # $1: requestUUID
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --username "${AC_USERNAME}" \
                              --password "${AC_PASSWORD}" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$req_status"
}

notarizefile() { # $1: path to file to notarize, $2: identifier
    filepath=${1:?"need a filepath"}
    identifier=${2:?"need an identifier"}
    
    # upload file
    echo "## uploading $filepath for notarization"
    requestUUID=$(xcrun altool --notarize-app \
                               --primary-bundle-id "$identifier" \
                               --username "${AC_USERNAME}" \
                               --password "${AC_PASSWORD}" \
                               --asc-provider "${AC_PROVIDER}" \
                               --file "$filepath" 2>&1 \
                  | awk '/RequestUUID/ { print $NF; }')
                               
    echo "Notarization RequestUUID: $requestUUID"
    
    if [[ $requestUUID == "" ]]; then 
        echo "could not upload for notarization"
        exit 1
    fi
        
    # wait for status to be not "in progress" any more
    request_status="in progress"
    while [[ "$request_status" == "in progress" ]]; do
        echo -n "waiting... "
        sleep 10
        request_status=$(requeststatus "$requestUUID")
        echo "$request_status"
    done
    
    # print status information
    xcrun altool --notarization-info "$requestUUID" \
                 --username "${AC_USERNAME}" \
                 --password "${AC_PASSWORD}"
    echo 
    
    if [[ $request_status != "success" ]]; then
        echo "## could not notarize $filepath"
        exit 1
    fi
    
}




echo ""
echo "  xbar ${VERSION}..."
echo ""
echo -n $VERSION > .version

# run all tests
./test.sh

rm -rf ./build/bin

sed "s/0.0.0/${VERSION}/" ./build/darwin/Info.plist.src > ./build/darwin/Info.plist
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/amd64 -o xbar
#CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/arm64 -o xbar
CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/universal -o xbar

cd ./build/bin/

echo "Signing the binary..."
codesign -s "${XBAR_SIGNING_IDENTITY}" -o runtime -v "./xbar.app/Contents/MacOS/xbar"

echo "Creating DMG..."
create-dmg ./xbar.app --overwrite --identity="${XBAR_SIGNING_IDENTITY}" --dmg-title "Install xbar"
mv xbar*.dmg "xbar.${VERSION}.dmg"

echo "TARing..."
tar -czvf xbar.${VERSION}.tar.gz ./xbar.app

echo "Zipping..."
zip -r xbar.zip ./xbar.app
mv xbar.zip "xbar.${VERSION}.zip"

#xcrun notarytool submit "xbar.${VERSION}.zip" --keychain-profile "${AC_PASSWORD}" --wait
echo "Notorizing..."

notarizefile "xbar.${VERSION}.zip" "com.xbarapp.app"
notarizefile "xbar.${VERSION}.dmg" "com.xbarapp.app"
xcrun stapler staple "xbar.${VERSION}.dmg"

rm -rf ./build/bin/xbar.app

open ./build/bin

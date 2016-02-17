#!/bin/sh
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  xctool -project $TRAVIS_XCODE_PROJECT -scheme $TRAVIS_XCODE_SCHEME -sdk $TRAVIS_XCODE_SDK -configuration Release OBJROOT=$PWD/build SYMROOT=$PWD/build ONLY_ACTIVE_ARCH=NO build analyze
else
  xctool -project $TRAVIS_XCODE_PROJECT -scheme $TRAVIS_XCODE_SCHEME -sdk $TRAVIS_XCODE_SDK -configuration Release OBJROOT=$PWD/build SYMROOT=$PWD/build ONLY_ACTIVE_ARCH=NO build analyze -failOnWarnings
fi

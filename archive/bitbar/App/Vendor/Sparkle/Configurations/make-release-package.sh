#!/bin/bash
set -e

if [ "$ACTION" = "" ] ; then
    # Sanity check that the Podspec version matches the Sparkle version
    spec_version=$(printf "require 'cocoapods'\nspec = %s\nprint spec.version" "$(cat "$SRCROOT/Sparkle.podspec")" | LANG=en_US.UTF-8 ruby)
    if [ "$spec_version" != "$CURRENT_PROJECT_VERSION" ] ; then
        echo "podspec version '$spec_version' does not match the current project version '$CURRENT_PROJECT_VERSION'" >&2
        exit 1
    fi

    rm -rf "$CONFIGURATION_BUILD_DIR/staging"
    rm -f "Sparkle-$CURRENT_PROJECT_VERSION.tar.bz2"

    mkdir -p "$CONFIGURATION_BUILD_DIR/staging"
    cp "$SRCROOT/CHANGELOG" "$SRCROOT/LICENSE" "$SRCROOT/Resources/SampleAppcast.xml" "$CONFIGURATION_BUILD_DIR/staging"
    cp -R "$SRCROOT/bin" "$CONFIGURATION_BUILD_DIR/staging"
    cp "$CONFIGURATION_BUILD_DIR/BinaryDelta" "$CONFIGURATION_BUILD_DIR/staging/bin"
    cp -R "$CONFIGURATION_BUILD_DIR/Sparkle Test App.app" "$CONFIGURATION_BUILD_DIR/staging"
    cp -R "$CONFIGURATION_BUILD_DIR/Sparkle.framework" "$CONFIGURATION_BUILD_DIR/staging"

    # Only copy dSYMs for Release builds, but don't check for the presence of the actual files
    # because missing dSYMs in a release build SHOULD trigger a build failure
    if [ "$CONFIGURATION" = "Release" ] ; then
        cp -R "$CONFIGURATION_BUILD_DIR/BinaryDelta.dSYM" "$CONFIGURATION_BUILD_DIR/staging/bin"
        cp -R "$CONFIGURATION_BUILD_DIR/Sparkle Test App.app.dSYM" "$CONFIGURATION_BUILD_DIR/staging"
        cp -R "$CONFIGURATION_BUILD_DIR/Sparkle.framework.dSYM" "$CONFIGURATION_BUILD_DIR/staging"
    fi

    cd "$CONFIGURATION_BUILD_DIR/staging"
    # Sorted file list groups similar files together, which improves tar compression
    find . \! -type d | rev | sort | rev | tar cjvf "../Sparkle-$CURRENT_PROJECT_VERSION.tar.bz2" --files-from=-
    rm -rf "$CONFIGURATION_BUILD_DIR/staging"
fi

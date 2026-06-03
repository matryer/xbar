#!/bin/bash
set -e

VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")

echo ""
echo "  xbar ${VERSION}..."
echo ""
printf '%s' "$VERSION" > .version

# Detect host architecture and set appropriate macOS minimum version.
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  # Apple Silicon – macOS 11.0 is the minimum for arm64.
  export CGO_LDFLAGS="-mmacosx-version-min=11.0"
  echo "  Building for Apple Silicon (arm64)..."
  wails build -o xbar
else
  # Intel – keep 10.13 for broad compatibility.
  export CGO_LDFLAGS="-mmacosx-version-min=10.13"
  echo "  Building for Intel (amd64)..."
  wails build -o xbar
fi

echo ""
echo "  Done. Output: build/bin/xbar.app"

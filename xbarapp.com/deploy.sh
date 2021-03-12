#!/bin/bash

set -e
VERSION=`git describe --tags`
echo -n "${VERSION}" > .version

echo "Deploying xbarapp.com (${VERSION})..."

go test
gcloud app deploy --project xbarapp --version=beta

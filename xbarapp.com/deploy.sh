#!/bin/bash

set -e
VERSION=`git describe --tags`
printf "package main\n\nconst version = \"${VERSION}\"" > version.gen.go

echo "Deploying xbarapp.com (${VERSION})..."

go test
gcloud app deploy --project xbarapp --version=beta

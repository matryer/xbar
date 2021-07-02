#!/bin/bash

set -e
VERSION=`git describe --tags`
printf "package main\n\nconst version = \"${VERSION}\"" > version.gen.go

echo "Running test..."
go test -v

echo "Deploying xbarapp.com (${VERSION})..."
gcloud app deploy --project xbarapp --version=beta

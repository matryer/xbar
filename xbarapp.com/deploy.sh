#!/bin/bash

VERSION=`git describe --tags`

echo "Deploying xbarapp.com (${VERSION})..."

gcloud app deploy --project xbarapp --version=beta

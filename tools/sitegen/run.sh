#!/bin/bash

set -e
VERSION=`git describe --tags`
echo -n "${VERSION}" > .version

go build -o sitegen 
./sitegen
rm sitegen

# run the tests in xbarapp.com - we may have
# just broken them
cd ../../xbarapp.com
echo -n "${VERSION}" > .version
go test

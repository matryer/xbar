#!/bin/bash

set -e
VERSION=`git describe --tags`
echo -n "${VERSION}" > .version

go build -o bloggen 
./bloggen $1
rm bloggen

# run the tests in xbarapp.com - we may have
# just broken them
cd ../../xbarapp.com
./gen.sh
npm run build

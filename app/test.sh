#!/bin/bash

set -e

VERSION=`git describe --tags`

go test

cd ../pkg/metadata
go test
cd ../../app

cd ../pkg/plugins
go test
cd ../../app

cd ../pkg/update
go test
cd ../../app

cd ../tools/sitegen
echo -n $VERSION > .version
go test -short
cd ../../app

cd ../xbarapp.com
go test
cd ../app

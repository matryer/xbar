#!/bin/bash

set -e

cd app
go test
cd ..

cd pkg/metadata
go test
cd ../../

cd pkg/plugins
go test
cd ../../

cd pkg/update
go test
cd ../../

cd tools/sitegen
go test -short
cd ../../

cd xbarapp.com
go test
cd ..

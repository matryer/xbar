#!/bin/bash

VERSION=`git describe --tags`

echo -n "${VERSION}" > .version

go build -o sitegen 
./sitegen
rm sitegen

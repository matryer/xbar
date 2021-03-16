#!/bin/bash

function ignore() {
    echo "ignoring signal (naughty script)"
}

trap ignore SIGINT

while true
do
    echo waiting...
    sleep 10
done

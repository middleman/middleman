#!/bin/sh

MIDDLEMAN_VERSION=4.3.0.rc.2

docker build . -t middleman/middleman:"$MIDDLEMAN_VERSION" --build-arg MIDDLEMAN_VERSION="$MIDDLEMAN_VERSION"
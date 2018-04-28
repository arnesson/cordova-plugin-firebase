#!/bin/sh

PLATFORM=$1
PLATFORM_VERSION=$2
FOLDER=".build-$1"

sh ./test/platform-add.sh $PLATFORM $PLATFORM_VERSION
sh ./test/platform-build.sh $PLATFORM $PLATFORM_VERSION

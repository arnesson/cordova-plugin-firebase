#!/bin/sh

PLATFORM=$1
PLATFORM_VERSION=$2
PLUGIN=$3
FOLDER=".build-$1"

sh ./test/platform-add.sh $PLATFORM $PLATFORM_VERSION
sh ./test/plugin-add.sh $PLATFORM $PLATFORM_VERSION $PLUGIN
sh ./test/platform-build.sh $PLATFORM $PLATFORM_VERSION

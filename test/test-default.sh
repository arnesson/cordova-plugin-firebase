#!/bin/bash
set -x #echo on
set -e #exit on error

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
ADDITIONAL_PLUGIN=$4

bash ./test/platform-add.sh $CORDOVA_VERSION $PLATFORM $PLATFORM_VERSION
bash ./test/plugin-add.sh $CORDOVA_VERSION $PLATFORM $PLATFORM_VERSION ..
bash ./test/platform-build.sh $CORDOVA_VERSION $PLATFORM $PLATFORM_VERSION

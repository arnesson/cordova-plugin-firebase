#!/bin/bash

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
PLUGIN=$4

FOLDER=".build-$PLATFORM"
cd $FOLDER

CORDOVA_MAJOR_VERSION=$(echo $CORDOVA_VERSION | cut -c 1-1)

if [[ "$CORDOVA_MAJOR_VERSION" == "6" ]]; then
  ../node_modules/.bin/cordova plugin add $PLUGIN --fetch
else
  ../node_modules/.bin/cordova plugin add $PLUGIN
fi

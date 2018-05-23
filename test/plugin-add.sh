#!/bin/sh

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
PLUGIN=$4

FOLDER=".build-$PLATFORM"
cd $FOLDER

if [[ "${CORDOVA_VERSION:0:1}" == "6" ]]; then
  ../node_modules/.bin/cordova plugin add $PLUGIN --fetch
else
  ../node_modules/.bin/cordova plugin add $PLUGIN
fi

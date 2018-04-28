#!/bin/sh

PLATFORM=$1
PLATFORM_VERSION=$2
PLUGIN=$3
FOLDER=".build-$1"

cd $FOLDER

../node_modules/.bin/cordova plugin add $PLUGIN

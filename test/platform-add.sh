#!/bin/bash
set -x #echo on
set -e #exit on error

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3

FOLDER=".build-$PLATFORM"
rm -rf $FOLDER

npm install -g "cordova@$CORDOVA_VERSION"
cordova create $FOLDER com.github.cordova_plugin_firebase HelloWorld
cp ./test/google-services.json $FOLDER

cd $FOLDER

cordova platform add "$PLATFORM@$PLATFORM_VERSION"

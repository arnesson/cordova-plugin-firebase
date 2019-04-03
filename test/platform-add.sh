#!/bin/bash
set -x #echo on
set -e #exit on error

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3

FOLDER=".build-$PLATFORM"
rm -rf $FOLDER

if [[ "$PLATFORM" == "ios" ]]; then
    npm install xcode --no-save
fi

npm install "cordova@$CORDOVA_VERSION" --no-save
./node_modules/.bin/cordova create $FOLDER com.github.cordova_plugin_firebase HelloWorld

cd $FOLDER

../node_modules/.bin/cordova platform add "$PLATFORM@$PLATFORM_VERSION"

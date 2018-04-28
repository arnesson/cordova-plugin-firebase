#!/bin/sh

PLATFORM=$1
PLATFORM_VERSION=$2
FOLDER=".build-$1"

rm -rf $FOLDER

./node_modules/.bin/cordova create $FOLDER com.example.hello HelloWorld

cd $FOLDER

../node_modules/.bin/cordova platform add "$PLATFORM@$PLATFORM_VERSION"

../node_modules/.bin/cordova plugin add ..

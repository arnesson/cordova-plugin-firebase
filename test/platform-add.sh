#!/bin/sh

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
ADDITIONAL_PLUGIN=$4

FOLDER=".build-$PLATFORM"
rm -rf $FOLDER

npm install "cordova@$CORDOVA_VERSION" --no-save
./node_modules/.bin/cordova create $FOLDER com.example.hello HelloWorld

cd $FOLDER

../node_modules/.bin/cordova platform add "$PLATFORM@$PLATFORM_VERSION"

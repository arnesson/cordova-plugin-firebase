#!/bin/bash
set -x #echo on
set -e #exit on error

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
PLUGIN=$4

FOLDER=".build-$PLATFORM"
cd $FOLDER

CORDOVA_MAJOR_VERSION=$(echo $CORDOVA_VERSION | cut -c 1-1)

if [[ "$CORDOVA_MAJOR_VERSION" == "6" ]]; then
  FETCH_COMMAND="--fetch"
else
  FETCH_COMMAND=""
fi

if [[ "$PLUGIN" == "cordova-android-play-services-gradle-release" ]]; then
  ../node_modules/.bin/cordova plugin add $PLUGIN --variable PLAY_SERVICES_VERSION=+ $FETCH_COMMAND --save
elif [[ "$PLUGIN" == "cordova-android-firebase-gradle-release" ]]; then
  ../node_modules/.bin/cordova plugin add $PLUGIN --variable FIREBASE_VERSION=+ $FETCH_COMMAND --save
else
  ../node_modules/.bin/cordova plugin add $PLUGIN $FETCH_COMMAND
fi

#!/bin/bash

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3
PLUGIN=$4

FOLDER=".build-$PLATFORM"
cd $FOLDER

CORDOVA_MAJOR_VERSION=$(echo $CORDOVA_VERSION | cut -c 1-1)

if [[ "$CORDOVA_MAJOR_VERSION" == "6" ]]; then
  if [[ "$PLUGIN" == "cordova-android-play-services-gradle-release" ]]; then
    ../node_modules/.bin/cordova plugin add $PLUGIN --fetch --variable PLAY_SERVICES_VERSION=15.+
  elif [[ "$PLUGIN" == "cordova-android-firebase-gradle-release" ]]; then
    ../node_modules/.bin/cordova plugin add $PLUGIN --fetch --variable FIREBASE_VERSION=15.+
  else
    ../node_modules/.bin/cordova plugin add $PLUGIN --fetch
  fi
else
  if [[ "$PLUGIN" == "cordova-android-play-services-gradle-release" ]]; then
    ../node_modules/.bin/cordova plugin add $PLUGIN --variable PLAY_SERVICES_VERSION=15.+
  elif [[ "$PLUGIN" == "cordova-android-firebase-gradle-release" ]]; then
    ../node_modules/.bin/cordova plugin add $PLUGIN --variable FIREBASE_VERSION=15.+
  else
    ../node_modules/.bin/cordova plugin add $PLUGIN
  fi
fi

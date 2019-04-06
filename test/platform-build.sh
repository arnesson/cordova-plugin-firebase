#!/bin/bash
set -x #echo on
set -e #exit on error

CORDOVA_VERSION=$1
PLATFORM=$2
PLATFORM_VERSION=$3

FOLDER=".build-$PLATFORM"
cd $FOLDER

cordova build $PLATFORM

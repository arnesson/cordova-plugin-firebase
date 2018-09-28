#!/usr/bin/env node

'use strict';

/**
 * This hook makes sure projects using [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase)
 * will build properly and have the required key files copied to the proper destinations when the app is build on Ionic Cloud using the package command.
 * Credits: https://github.com/arnesson.
 */
var fs = require('fs');
var path = require('path');
var utilities = require("../lib/utilities");

var config = fs.readFileSync('config.xml').toString();
var name = utilities.getValue(config, 'name');

var IOS_DIR = 'platforms/ios';

var PLATFORM = {
  IOS: {
    dest: [
      IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
      IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
    ],
    src: [
      'GoogleService-Info.plist',
      IOS_DIR + '/www/GoogleService-Info.plist',
      'www/GoogleService-Info.plist'
    ]
  }
};

module.exports = function (context) {
  // Copy key files to their platform specific folders
  if (utilities.directoryExists(IOS_DIR)) {
    console.log('Preparing Firebase on iOS');
    utilities.copyKey(PLATFORM.IOS);
  }
};

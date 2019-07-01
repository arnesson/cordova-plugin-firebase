#!/usr/bin/env node

'use strict';

/**
 * This hook makes sure projects using [cordova-plugin-firebase-lib](https://github.com/wizpanda/cordova-plugin-firebase-lib)
 * will build properly and have the required key files copied to the proper destinations when the app is build on Ionic Cloud using the package command.
 * Credits: https://github.com/arnesson.
 */
const chalk = require('chalk');
const utilities = require('./lib/utilities');

let name = utilities.getAppName();
if (name.includes('&amp;')) {
    name = name.replace(/&amp;/g, '&');
}

const IOS_DIR = 'platforms/ios';
const ANDROID_DIR = 'platforms/android';

const PLATFORM = {
    IOS: {
        dest: [
            IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
            IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
        ],
        src: 'GoogleService-Info.plist'
    },
    ANDROID: {
        dest: [
            ANDROID_DIR + '/app/google-services.json'
        ],
        src: 'google-services.json'
    }
};

module.exports = function (context) {
    // Get platform from the context supplied by cordova
    const platforms = context.opts.platforms;

    // Copy key files to their platform specific folders
    if (platforms.indexOf('ios') !== -1 && utilities.directoryExists(IOS_DIR)) {
        console.log(chalk.green.bold('Preparing Firebase on iOS'));
        utilities.copyKey(PLATFORM.IOS);
    }
    if (platforms.indexOf('android') !== -1 && utilities.directoryExists(ANDROID_DIR)) {
        console.log(chalk.green.bold('Preparing Firebase on Android'));
        utilities.copyKey(PLATFORM.ANDROID);
    }
};

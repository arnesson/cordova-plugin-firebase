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
    const log = console.log;
    // Get platform from the context supplied by cordova
    const platforms = context.opts.platforms;

    // Copy key files to their platform specific folders
    if (platforms.indexOf('ios') !== -1 && utilities.directoryExists(IOS_DIR)) {
        log(chalk.green.bold('Preparing Firebase on iOS'));
        utilities.copyKey(PLATFORM.IOS);

        const rightPath = './platforms/ios/' + name + '.xcworkspace';
        const wrongPath = './platforms/ios/' + name + '.xcodeproj';

        log(chalk.bold.red.underline('\nIMPORTANT:'));
        log(chalk.green('Please make sure you open', chalk.bold(rightPath), 'instead of', chalk.bold(wrongPath),
            'if you are using Xcode to build.'));
        log(chalk.green('Alternatively, you can simply run', chalk.bold('open -a Xcode platforms/ios')));
    }

    if (platforms.indexOf('android') !== -1 && utilities.directoryExists(ANDROID_DIR)) {
        log(chalk.green.bold('Preparing Firebase on Android'));
        utilities.copyKey(PLATFORM.ANDROID);
    }
};

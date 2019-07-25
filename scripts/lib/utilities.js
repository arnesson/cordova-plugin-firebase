/**
 * Utilities and shared functionality for the build hooks.
 */
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const ConfigParser = require('cordova-common').ConfigParser;

fs.ensureDirSync = function (dir) {
    // TODO Use Node.js 10 & use mkdirSync with recursive option
    if (!fs.existsSync(dir)) {
        dir.split(path.sep).reduce(function (currentPath, folder) {
            currentPath += folder + path.sep;
            if (!fs.existsSync(currentPath)) {
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
};

module.exports = {
    getAppName: function () {
        const config = new ConfigParser('config.xml');
        return config.name();
    },

    copyKey: function (platform) {
        const file = platform.src;

        if (this.fileExists(file)) {
            const contents = fs.readFileSync(file).toString();

            try {
                platform.dest.forEach(function (destinationPath) {
                    const folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                    fs.ensureDirSync(folder);
                    fs.writeFileSync(destinationPath, contents);
                });
            } catch (e) {
                // skip
            }
        } else {
            console.warn(chalk.yellow.bold('File: [' + file + '] not found. Please checkout',
                'https://github.com/wizpanda/cordova-plugin-firebase-lib#setup'));
        }
    },

    fileExists: function (path) {
        try {
            return fs.statSync(path).isFile();
        } catch (e) {
            return false;
        }
    },

    directoryExists: function (path) {
        try {
            return fs.statSync(path).isDirectory();
        } catch (e) {
            return false;
        }
    }
};

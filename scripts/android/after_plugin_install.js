var androidHelper = require('../lib/android-helper');
var utilities = require("../lib/utilities");

module.exports = function(context) {

    // Modify the Gradle build file to add a task that will upload the debug symbols
    // at build time.
    androidHelper.restoreRootBuildGradle();
    androidHelper.modifyRootBuildGradle();
};

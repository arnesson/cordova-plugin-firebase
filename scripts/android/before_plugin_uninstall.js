var androidHelper = require('../lib/android-helper');
var utilities = require("../lib/utilities");

module.exports = function(context) {

    // Remove the Gradle modifications that were added when the plugin was installed.
    androidHelper.restoreRootBuildGradle();
};

const helper = require('./helper');

module.exports = function () {
    // Remove the Gradle modifications that were added when the plugin was installed.
    helper.restoreRootBuildGradle();
};

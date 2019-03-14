var helper = require('./helper');

module.exports = function(context) {

    // Remove the Gradle modifications that were added when the plugin was installed.
    helper.restoreRootBuildGradle();
};

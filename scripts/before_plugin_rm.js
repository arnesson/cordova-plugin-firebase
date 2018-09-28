
var androidHelper = require('./lib/android-helper');
var iosHelper = require("./lib/ios-helper");
var utilities = require("./lib/utilities");

module.exports = function(context) {

    const platforms = context.opts.cordova.platforms,
          plugins = context.opts.plugins;

    // Ignore if not removing this plugin
    if (plugins.indexOf('cordova-plugin-firebase') === -1) {
        return;
    }

    // Remove the Gradle modifications that were added when the plugin was installed.
    if (platforms.indexOf("android") !== -1) {
        androidHelper.restoreRootBuildGradle();
    }

    // Remove the build script that was added when the plugin was installed.
    if (platforms.indexOf("ios") !== -1) {
        var xcodeProjectPath = utilities.getXcodeProjectPath(context);
        iosHelper.removeShellScriptBuildPhase(context, xcodeProjectPath);
    }
};

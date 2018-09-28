var iosHelper = require("../lib/ios-helper");
var utilities = require("../lib/utilities");

module.exports = function(context) {

    // Remove the build script that was added when the plugin was installed.
    var xcodeProjectPath = utilities.getXcodeProjectPath(context);
    iosHelper.removeShellScriptBuildPhase(context, xcodeProjectPath);
};

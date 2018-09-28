var iosHelper = require("../lib/ios-helper");
var utilities = require("../lib/utilities");

module.exports = function(context) {

    // Add a build phase which runs a shell script that executes the Crashlytics
    // run command line tool which uploads the debug symbols at build time.
    var xcodeProjectPath = utilities.getXcodeProjectPath(context);
    iosHelper.removeShellScriptBuildPhase(context, xcodeProjectPath);
    iosHelper.addShellScriptBuildPhase(context, xcodeProjectPath);
};

var helper = require("./helper");

module.exports = function(context) {

    // Add a build phase which runs a shell script that executes the Crashlytics
    // run command line tool which uploads the debug symbols at build time.
    var xcodeProjectPath = helper.getXcodeProjectPath();
    helper.removeShellScriptBuildPhase(context, xcodeProjectPath);
    helper.addShellScriptBuildPhase(context, xcodeProjectPath);
};

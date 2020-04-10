var helper = require("./helper");

module.exports = function(context) {

    // Remove the build script that was added when the plugin was installed.
    var xcodeProjectPath = helper.getXcodeProjectPath();
    helper.removeShellScriptBuildPhase(context, xcodeProjectPath);
};

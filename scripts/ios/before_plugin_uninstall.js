const helper = require("./helper");

module.exports = function (context) {

    // Remove the build script that was added when the plugin was installed.
    const xcodeProjectPath = helper.getXcodeProjectPath(context);
    helper.removeShellScriptBuildPhase(context, xcodeProjectPath);
};

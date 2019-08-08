var helper = require("./helper");

module.exports = function(context) {

    // Remove the build script that was added when the plugin was installed.
    helper.getXcodeProjectPath(function(xcodeProjectPath){
        helper.removeShellScriptBuildPhase(context, xcodeProjectPath);
    });
};

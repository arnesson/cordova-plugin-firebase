var fs = require("fs");
var path = require("path");
var utilities = require("../lib/utilities");

/**
 * This is used as the display text for the build phase block in XCode as well as the
 * inline comments inside of the .pbxproj file for the build script phase block.
 */
var comment = "\"Crashlytics\"";

module.exports = {

  /**
     * Used to get the path to the XCode project's .pbxproj file.
     *
     * @param {object} context - The Cordova context.
     * @returns The path to the XCode project's .pbxproj file.
     */
  getXcodeProjectPath: function (context) {

    var appName = utilities.getAppName(context);

    return path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
  },

  /**
     * This helper is used to add a build phase to the XCode project which runs a shell
     * script during the build process. The script executes Crashlytics run command line
     * tool with the API and Secret keys. This tool is used to upload the debug symbols
     * (dSYMs) so that Crashlytics can display stack trace information in it's web console.
     */
  addShellScriptBuildPhase: function (context, xcodeProjectPath) {
    var xcode = context.requireCordovaModule("xcode");

    // Read and parse the XCode project (.pxbproj) from disk.
    // File format information: http://www.monobjc.net/xcode-project-file-format.html
    var xcodeProject = xcode.project(xcodeProjectPath);
    xcodeProject.parseSync();

    // Build the body of the script to be executed during the build phase.
    var script = '"' + '\\"${SRCROOT}\\"' + "/\\\"" + utilities.getAppName(context) + "\\\"/Plugins/" + utilities.getPluginId() + "/Fabric.framework/run" + '"';

    // Generate a unique ID for our new build phase.
    var id = xcodeProject.generateUuid();
    // Create the build phase.
    xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[id] = {
          isa: "PBXShellScriptBuildPhase",
          buildActionMask: 2147483647,
          files: [],
          inputPaths: [],
          name: comment,
          outputPaths: [],
          runOnlyForDeploymentPostprocessing: 0,
          shellPath: "/bin/sh",
          shellScript: script,
          showEnvVarsInLog: 0
        };

    // Add a comment to the block (viewable in the source of the pbxproj file).
    xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[id + "_comment"] = comment;

    // Add this new shell script build phase block to the targets.
    for (var nativeTargetId in xcodeProject.hash.project.objects.PBXNativeTarget) {

      // Skip over the comment blocks.
      if (nativeTargetId.indexOf("_comment") !== -1) {
        continue;
      }

      var nativeTarget = xcodeProject.hash.project.objects.PBXNativeTarget[nativeTargetId];

      nativeTarget.buildPhases.push({
        value: id,
        comment: comment
      });
    }

    // Finally, write the .pbxproj back out to disk.
    fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
  },

  /**
     * This helper is used to remove the build phase from the XCode project that was added
     * by the addShellScriptBuildPhase() helper method.
     */
  removeShellScriptBuildPhase: function (context, xcodeProjectPath) {

    var xcode = context.requireCordovaModule("xcode");

    // Read and parse the XCode project (.pxbproj) from disk.
    // File format information: http://www.monobjc.net/xcode-project-file-format.html
    var xcodeProject = xcode.project(xcodeProjectPath);
    xcodeProject.parseSync();

    // First, we want to delete the build phase block itself.

    var buildPhases = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase;

    for (var buildPhaseId in buildPhases) {

      var buildPhase = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[buildPhaseId];
      var shouldDelete = false;

      if (buildPhaseId.indexOf("_comment") === -1) {
        // Dealing with a build phase block.

        // If the name of this block matches ours, then we want to delete it.
        shouldDelete = buildPhase.name && buildPhase.name.indexOf(comment) !== -1;
      } else {
        // Dealing with a comment block.

        // If this is a comment block that matches ours, then we want to delete it.
        shouldDelete = buildPhaseId === comment;
      }

      if (shouldDelete) {
        delete buildPhases[buildPhaseId];
      }
    }

    // Second, we want to delete the native target reference to the block.

    var nativeTargets = xcodeProject.hash.project.objects.PBXNativeTarget;

    for (var nativeTargetId in nativeTargets) {

      // Skip over the comment blocks.
      if (nativeTargetId.indexOf("_comment") !== -1) {
        continue;
      }

      var nativeTarget = nativeTargets[nativeTargetId];

      // We remove the reference to the block by filtering out the the ones that match.
      nativeTarget.buildPhases = nativeTarget.buildPhases.filter(function (buildPhase) {
        return buildPhase.comment !== comment;
      });
    }

    // Finally, write the .pbxproj back out to disk.
    fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
  }
};

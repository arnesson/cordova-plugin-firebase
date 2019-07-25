const fs = require('fs');
const path = require('path');
const xcode = require('xcode');
const chalk = require('chalk');
const utilities = require('../lib/utilities');

/**
 * This is used as the display text for the build phase block in XCode as well as the
 * inline comments inside of the .pbxproj file for the build script phase block.
 */
const comment = '"Crashlytics"';

module.exports = {

    /**
     * @returns string path to the XCode project's .pbxproj file.
     */
    getXcodeProjectPath: function () {
        const appName = utilities.getAppName();
        const xcodeProjectPath = path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
        console.log(chalk.blue.bold('Xcode project path:', xcodeProjectPath));
        return xcodeProjectPath;
    },

    /**
     * This helper is used to add a build phase to the XCode project which runs a shell
     * script during the build process. The script executes Crashlytics run command line
     * tool with the API and Secret keys. This tool is used to upload the debug symbols
     * (dSYMs) so that Crashlytics can display stack trace information in it's web console.
     */
    addShellScriptBuildPhase: function (context, xcodeProjectPath) {
        // Read and parse the XCode project (.pxbproj) from disk.
        // File format information: http://www.monobjc.net/xcode-project-file-format.html
        const xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        // Build the body of the script to be executed during the build phase.
        const script = '"' + '\\"${PODS_ROOT}/Fabric/run\\"' + '"';

        // Generate a unique ID for our new build phase.
        const id = xcodeProject.generateUuid();
        // Create the build phase.
        xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[id] = {
            isa: "PBXShellScriptBuildPhase",
            buildActionMask: 2147483647,
            files: [],
            inputPaths: ['"' + '$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)' + '"'],
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
        for (const nativeTargetId in xcodeProject.hash.project.objects.PBXNativeTarget) {

            // Skip over the comment blocks.
            if (nativeTargetId.indexOf("_comment") !== -1) {
                continue;
            }

            const nativeTarget = xcodeProject.hash.project.objects.PBXNativeTarget[nativeTargetId];

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
        // Read and parse the XCode project (.pxbproj) from disk.
        // File format information: http://www.monobjc.net/xcode-project-file-format.html
        const xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        // First, we want to delete the build phase block itself.

        const buildPhases = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase;

        const commentTest = comment.replace(/"/g, '');
        for (const buildPhaseId in buildPhases) {

            const buildPhase = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[buildPhaseId];
            let shouldDelete = false;

            if (buildPhaseId.indexOf("_comment") === -1) {
                // Dealing with a build phase block.

                // If the name of this block matches ours, then we want to delete it.
                shouldDelete = buildPhase.name && buildPhase.name.indexOf(commentTest) !== -1;
            } else {
                // Dealing with a comment block.

                // If this is a comment block that matches ours, then we want to delete it.
                shouldDelete = buildPhase === commentTest;
            }

            if (shouldDelete) {
                delete buildPhases[buildPhaseId];
            }
        }

        // Second, we want to delete the native target reference to the block.

        const nativeTargets = xcodeProject.hash.project.objects.PBXNativeTarget;

        for (const nativeTargetId in nativeTargets) {

            // Skip over the comment blocks.
            if (nativeTargetId.indexOf("_comment") !== -1) {
                continue;
            }

            const nativeTarget = nativeTargets[nativeTargetId];

            // We remove the reference to the block by filtering out the the ones that match.
            nativeTarget.buildPhases = nativeTarget.buildPhases.filter(function (buildPhase) {
                return buildPhase.comment !== commentTest;
            });
        }

        // Finally, write the .pbxproj back out to disk.
        fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync());
    }
};

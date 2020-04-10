var fs = require("fs");
var path = require("path");
var utilities = require("../lib/utilities");
var xcode = require("xcode");
var plist = require('plist');

/**
 * This is used as the display text for the build phase block in XCode as well as the
 * inline comments inside of the .pbxproj file for the build script phase block.
 */
var comment = "\"Crashlytics\"";

module.exports = {

    /**
     * Used to get the path to the XCode project's .pbxproj file.
     */
    getXcodeProjectPath: function () {
        var appName = utilities.getAppName();
        return path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
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
        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        // Build the body of the script to be executed during the build phase.
        var script = '"' + '\\"${PODS_ROOT}/Fabric/run\\"' + '"';

        // Generate a unique ID for our new build phase.
        var id = xcodeProject.generateUuid();
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
        fs.writeFileSync(path.resolve(xcodeProjectPath), xcodeProject.writeSync());
    },

    /**
     * This helper is used to remove the build phase from the XCode project that was added
     * by the addShellScriptBuildPhase() helper method.
     */
    removeShellScriptBuildPhase: function (context, xcodeProjectPath) {

        // Read and parse the XCode project (.pxbproj) from disk.
        // File format information: http://www.monobjc.net/xcode-project-file-format.html
        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        // First, we want to delete the build phase block itself.

        var buildPhases = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase;

        var commentTest = comment.replace(/"/g, '');
        for (var buildPhaseId in buildPhases) {

            var buildPhase = xcodeProject.hash.project.objects.PBXShellScriptBuildPhase[buildPhaseId];
            var shouldDelete = false;

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

        var nativeTargets = xcodeProject.hash.project.objects.PBXNativeTarget;

        for (var nativeTargetId in nativeTargets) {

            // Skip over the comment blocks.
            if (nativeTargetId.indexOf("_comment") !== -1) {
                continue;
            }

            var nativeTarget = nativeTargets[nativeTargetId];

            // We remove the reference to the block by filtering out the the ones that match.
            nativeTarget.buildPhases = nativeTarget.buildPhases.filter(function (buildPhase) {
                return buildPhase.comment !== commentTest;
            });
        }

        // Finally, write the .pbxproj back out to disk.
        fs.writeFileSync(path.resolve(xcodeProjectPath), xcodeProject.writeSync());
    },

    ensureRunpathSearchPath: function(context, xcodeProjectPath){

        function addRunpathSearchBuildProperty(proj, build) {
            const LD_RUNPATH_SEARCH_PATHS = proj.getBuildProperty("LD_RUNPATH_SEARCH_PATHS", build);
            if (!LD_RUNPATH_SEARCH_PATHS) {
                proj.addBuildProperty("LD_RUNPATH_SEARCH_PATHS", "\"$(inherited) @executable_path/Frameworks\"", build);
            }
            if (LD_RUNPATH_SEARCH_PATHS.indexOf("@executable_path/Frameworks") == -1) {
                var newValue = LD_RUNPATH_SEARCH_PATHS.substr(0, LD_RUNPATH_SEARCH_PATHS.length - 1);
                newValue += ' @executable_path/Frameworks\"';
                proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
            }
            if (LD_RUNPATH_SEARCH_PATHS.indexOf("$(inherited)") == -1) {
                var newValue = LD_RUNPATH_SEARCH_PATHS.substr(0, LD_RUNPATH_SEARCH_PATHS.length - 1);
                newValue += ' $(inherited)\"';
                proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
            }
        }

        // Read and parse the XCode project (.pxbproj) from disk.
        // File format information: http://www.monobjc.net/xcode-project-file-format.html
        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();

        // Add search paths build property
        addRunpathSearchBuildProperty(xcodeProject, "Debug");
        addRunpathSearchBuildProperty(xcodeProject, "Release");

        // Finally, write the .pbxproj back out to disk.
        fs.writeFileSync(path.resolve(xcodeProjectPath), xcodeProject.writeSync());
    },
    stripDebugSymbols: function(){
        var podFilePath = 'platforms/ios/Podfile',
            podFile = fs.readFileSync(path.resolve(podFilePath)).toString();
        if(!podFile.match('DEBUG_INFORMATION_FORMAT')){
            podFile += "\npost_install do |installer|\n" +
                "    installer.pods_project.targets.each do |target|\n" +
                "        target.build_configurations.each do |config|\n" +
                "            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'\n" +
                "        end\n" +
                "    end\n" +
                "end";
            fs.writeFileSync(path.resolve(podFilePath), podFile);
            console.log('cordova-plugin-firebasex: Applied IOS_STRIP_DEBUG to Podfile');
        }
    },
    applyPluginVarsToPlists: function(googlePlistPath, appPlistPath, pluginVariables){
        var googlePlist = plist.parse(fs.readFileSync(path.resolve(googlePlistPath), 'utf8')),
            appPlist = plist.parse(fs.readFileSync(path.resolve(appPlistPath), 'utf8')),
            googlePlistModified = false,
            appPlistModified = false;

        if(typeof pluginVariables['FIREBASE_ANALYTICS_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FIREBASE_ANALYTICS_COLLECTION_ENABLED"] = (pluginVariables['FIREBASE_ANALYTICS_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(typeof pluginVariables['FIREBASE_PERFORMANCE_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FIREBASE_PERFORMANCE_COLLECTION_ENABLED"] = (pluginVariables['FIREBASE_PERFORMANCE_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(typeof pluginVariables['FIREBASE_CRASHLYTICS_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FIREBASE_CRASHLYTICS_COLLECTION_ENABLED"] = (pluginVariables['FIREBASE_CRASHLYTICS_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(pluginVariables['SETUP_RECAPTCHA_VERIFICATION'] === 'true'){
            var reversedClientId = googlePlist['REVERSED_CLIENT_ID'];

            if(!appPlist['CFBundleURLTypes']) appPlist['CFBundleURLTypes'] = [];
            var entry, i;
            for(i=0; i<appPlist['CFBundleURLTypes'].length; i++){
                if(typeof appPlist['CFBundleURLTypes'][i] === 'object' && appPlist['CFBundleURLTypes'][i]['CFBundleURLSchemes']){
                    entry = appPlist['CFBundleURLTypes'][i];
                    break;
                }
            }
            if(!entry) entry = {};
            if(!entry['CFBundleTypeRole']) entry['CFBundleTypeRole'] = 'Editor';
            if(!entry['CFBundleURLSchemes']) entry['CFBundleURLSchemes'] = [];
            if(entry['CFBundleURLSchemes'].indexOf(reversedClientId) === -1){
                entry['CFBundleURLSchemes'].push(reversedClientId)
            }
            appPlist['CFBundleURLTypes'][i] = entry;
            appPlistModified = true;
        }

        if(googlePlistModified) fs.writeFileSync(path.resolve(googlePlistPath), plist.build(googlePlist));
        if(appPlistModified) fs.writeFileSync(path.resolve(appPlistPath), plist.build(appPlist));
    }
};

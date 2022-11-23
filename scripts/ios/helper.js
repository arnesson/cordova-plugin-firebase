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

var versionRegex = /\d+\.\d+\.\d+/,
    firebasePodRegex = /pod 'Firebase\/([^']+)', '(\d+\.\d+\.\d+)'/g,
    standardFirestorePodRegEx = /pod 'Firebase\/Firestore', '(\d+\.\d+\.\d+)'/,
    googleSignInPodRegEx = /pod 'GoogleSignIn', '(\d+\.\d+\.\d+)'/,
    googleTagManagerPodRegEx = /pod 'GoogleTagManager', '(\d+\.\d+\.\d+)'/,
    prebuiltFirestorePodTemplate = "pod 'FirebaseFirestore', :tag => '{version}', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git'",
    iosDeploymentTargetPodRegEx = /platform :ios, '(\d+\.\d+)'/;

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
        var script = '"' + '\\"${PODS_ROOT}/FirebaseCrashlytics/run\\"' + '"';

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
            let LD_RUNPATH_SEARCH_PATHS = proj.getBuildProperty("LD_RUNPATH_SEARCH_PATHS", build);

            if (!Array.isArray(LD_RUNPATH_SEARCH_PATHS)) {
                LD_RUNPATH_SEARCH_PATHS = [LD_RUNPATH_SEARCH_PATHS];
            }

            LD_RUNPATH_SEARCH_PATHS.forEach(LD_RUNPATH_SEARCH_PATH => {
                if (!LD_RUNPATH_SEARCH_PATH) {
                    proj.addBuildProperty("LD_RUNPATH_SEARCH_PATHS", "\"$(inherited) @executable_path/Frameworks\"", build);
                }
                if (LD_RUNPATH_SEARCH_PATH.indexOf("@executable_path/Frameworks") == -1) {
                    var newValue = LD_RUNPATH_SEARCH_PATH.substr(0, LD_RUNPATH_SEARCH_PATH.length - 1);
                    newValue += ' @executable_path/Frameworks\"';
                    proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
                }
                if (LD_RUNPATH_SEARCH_PATH.indexOf("$(inherited)") == -1) {
                    var newValue = LD_RUNPATH_SEARCH_PATH.substr(0, LD_RUNPATH_SEARCH_PATH.length - 1);
                    newValue += ' $(inherited)\"';
                    proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
                }
            });
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
    applyPodsPostInstall: function(pluginVariables, iosPlatform){
        var podFileModified = false,
            podFilePath = iosPlatform.podFile,
            podFile = fs.readFileSync(path.resolve(podFilePath)).toString(),
            DEBUG_INFORMATION_FORMAT = pluginVariables['IOS_STRIP_DEBUG'] && pluginVariables['IOS_STRIP_DEBUG'] === 'true' ? 'dwarf' : 'dwarf-with-dsym',
            IPHONEOS_DEPLOYMENT_TARGET = podFile.match(iosDeploymentTargetPodRegEx)[1];

        if(!podFile.match('post_install')){
            podFile += `
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = '${DEBUG_INFORMATION_FORMAT}'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '${IPHONEOS_DEPLOYMENT_TARGET}'
            if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
                config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            end
        end
    end
end
                `;
            fs.writeFileSync(path.resolve(podFilePath), podFile);
            utilities.log('cordova-plugin-firebasex: Applied post install block to Podfile');
            podFileModified = true;
        }
        return podFileModified;
    },
    applyPluginVarsToPlists: function(pluginVariables, iosPlatform){
        var googlePlist = plist.parse(fs.readFileSync(path.resolve(iosPlatform.dest), 'utf8')),
            appPlist = plist.parse(fs.readFileSync(path.resolve(iosPlatform.appPlist), 'utf8')),
            entitlementsDebugPlist = plist.parse(fs.readFileSync(path.resolve(iosPlatform.entitlementsDebugPlist), 'utf8')),
            entitlementsReleasePlist = plist.parse(fs.readFileSync(path.resolve(iosPlatform.entitlementsReleasePlist), 'utf8')),
            googlePlistModified = false,
            appPlistModified = false,
            entitlementsPlistsModified = false;

        if(typeof pluginVariables['FIREBASE_ANALYTICS_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FIREBASE_ANALYTICS_COLLECTION_ENABLED"] = (pluginVariables['FIREBASE_ANALYTICS_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(typeof pluginVariables['FIREBASE_PERFORMANCE_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FIREBASE_PERFORMANCE_COLLECTION_ENABLED"] = (pluginVariables['FIREBASE_PERFORMANCE_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(typeof pluginVariables['FIREBASE_CRASHLYTICS_COLLECTION_ENABLED'] !== 'undefined'){
            googlePlist["FirebaseCrashlyticsCollectionEnabled"] = (pluginVariables['FIREBASE_CRASHLYTICS_COLLECTION_ENABLED'] !== "false" ? "true" : "false") ;
            googlePlistModified = true;
        }
        if(typeof pluginVariables['IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL'] !== 'undefined'){
            appPlist["shouldEstablishDirectChannel"] = (pluginVariables['IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL'] === "true") ;
            appPlistModified = true;
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
        if(pluginVariables['IOS_ENABLE_APPLE_SIGNIN'] === 'true'){
            entitlementsDebugPlist["com.apple.developer.applesignin"] = ["Default"];
            entitlementsReleasePlist["com.apple.developer.applesignin"] = ["Default"];
            entitlementsPlistsModified = true;
        }

        if(pluginVariables['IOS_ENABLE_CRITICAL_ALERTS_ENABLED'] === 'true'){
            entitlementsDebugPlist["com.apple.developer.usernotifications.critical-alerts"] = true;
            entitlementsReleasePlist["com.apple.developer.usernotifications.critical-alerts"] = true;
            entitlementsPlistsModified = true;
        }

        if(typeof pluginVariables['FIREBASE_FCM_AUTOINIT_ENABLED'] !== 'undefined'){
            appPlist["FirebaseMessagingAutoInitEnabled"] = (pluginVariables['FIREBASE_FCM_AUTOINIT_ENABLED'] === "true") ;
            appPlistModified = true;
        }

        if(googlePlistModified) fs.writeFileSync(path.resolve(iosPlatform.dest), plist.build(googlePlist));
        if(appPlistModified) fs.writeFileSync(path.resolve(iosPlatform.appPlist), plist.build(appPlist));
        if(entitlementsPlistsModified){
            fs.writeFileSync(path.resolve(iosPlatform.entitlementsDebugPlist), plist.build(entitlementsDebugPlist));
            fs.writeFileSync(path.resolve(iosPlatform.entitlementsReleasePlist), plist.build(entitlementsReleasePlist));
        }
    },
    applyPluginVarsToPodfile: function(pluginVariables, iosPlatform){
        var podFileContents = fs.readFileSync(path.resolve(iosPlatform.podFile), 'utf8'),
            podFileModified = false;

        if(pluginVariables['IOS_FIREBASE_SDK_VERSION']){
            if(pluginVariables['IOS_FIREBASE_SDK_VERSION'].match(versionRegex)){
                var matches = podFileContents.match(firebasePodRegex);
                if(matches){
                    var currentVersion = matches[0].match(versionRegex)[0];
                    matches.forEach((match) => {
                        if(!match.match(pluginVariables['IOS_FIREBASE_SDK_VERSION'])){
                            podFileContents = podFileContents.replace(match, match.replace(currentVersion, pluginVariables['IOS_FIREBASE_SDK_VERSION']));
                            podFileModified = true;
                        }
                    });
                    if(podFileModified) utilities.log("Firebase iOS SDK version set to v"+pluginVariables['IOS_FIREBASE_SDK_VERSION']+" in Podfile");
                }
            }else{
                throw new Error("The value \""+pluginVariables['IOS_FIREBASE_SDK_VERSION']+"\" for IOS_FIREBASE_SDK_VERSION is not a valid version in the format 'X.Y.Z'")
            }
        }

        if(pluginVariables['IOS_GOOGLE_SIGIN_VERSION']){
            if(pluginVariables['IOS_GOOGLE_SIGIN_VERSION'].match(versionRegex)){
                var matches = podFileContents.match(googleSignInPodRegEx);
                if(matches){
                    var currentVersion = matches[0].match(versionRegex)[0];
                    matches.forEach((match) => {
                        if(!match.match(pluginVariables['IOS_GOOGLE_SIGIN_VERSION'])){
                            podFileContents = podFileContents.replace(match, match.replace(currentVersion, pluginVariables['IOS_GOOGLE_SIGIN_VERSION']));
                            podFileModified = true;
                        }
                    });
                    if(podFileModified) utilities.log("Google Sign In version set to v"+pluginVariables['IOS_GOOGLE_SIGIN_VERSION']+" in Podfile");
                }
            }else{
                throw new Error("The value \""+pluginVariables['IOS_GOOGLE_SIGIN_VERSION']+"\" for IOS_GOOGLE_SIGIN_VERSION is not a valid version in the format 'X.Y.Z'")
            }
        }

        if(pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION']){
            if(pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION'].match(versionRegex)){
                var matches = podFileContents.match(googleTagManagerPodRegEx);
                if(matches){
                    var currentVersion = matches[0].match(versionRegex)[0];
                    matches.forEach((match) => {
                        if(!match.match(pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION'])){
                            podFileContents = podFileContents.replace(match, match.replace(currentVersion, pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION']));
                            podFileModified = true;
                        }
                    });
                    if(podFileModified) utilities.log("Google Tag Manager version set to v"+pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION']+" in Podfile");
                }
            }else{
                throw new Error("The value \""+pluginVariables['IOS_GOOGLE_TAG_MANAGER_VERSION']+"\" for IOS_GOOGLE_TAG_MANAGER_VERSION is not a valid version in the format 'X.Y.Z'")
            }
        }

        if(pluginVariables['IOS_USE_PRECOMPILED_FIRESTORE_POD'] === 'true'){
            var standardFirestorePodMatches = podFileContents.match(standardFirestorePodRegEx);
            if(standardFirestorePodMatches){
                podFileContents = podFileContents.replace(standardFirestorePodMatches[0], prebuiltFirestorePodTemplate.replace('{version}', standardFirestorePodMatches[1]));
                podFileModified = true;
                utilities.log("Configured Podfile for pre-built Firestore pod");
            }
        }
        if(podFileModified) {
            fs.writeFileSync(path.resolve(iosPlatform.podFile), podFileContents);
        }

        return podFileModified;
    }
};

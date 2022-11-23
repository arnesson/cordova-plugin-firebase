#!/usr/bin/env node

'use strict';

/**
 * This hook makes sure projects using [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase)
 * will build properly and have the required key files copied to the proper destinations when the app is build on Ionic Cloud using the package command.
 * Credits: https://github.com/arnesson.
 */
var fs = require('fs');
var path = require("path");
var execSync = require('child_process').execSync;
var utilities = require("./lib/utilities");

var appName;
var pluginVariables = {};

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';
var PLUGIN_ID;

var PLATFORM;

var setupEnv = function(){
    appName = utilities.getAppName();
    PLUGIN_ID = utilities.getPluginId();
    PLATFORM = {
        IOS: {
            platformDir: IOS_DIR,
            dest: IOS_DIR + '/' + appName + '/Resources/GoogleService-Info.plist',
            src: [
                'GoogleService-Info.plist',
                IOS_DIR + '/www/GoogleService-Info.plist',
                'www/GoogleService-Info.plist'
            ],
            appPlist: IOS_DIR + '/' + appName + '/' + appName + '-Info.plist',
            entitlementsDebugPlist: IOS_DIR + '/' + appName + '/Entitlements-Debug.plist',
            entitlementsReleasePlist: IOS_DIR + '/' + appName + '/Entitlements-Release.plist',
            podFile: IOS_DIR + '/Podfile'
        },
        ANDROID: {
            platformDir: ANDROID_DIR,
            dest: ANDROID_DIR + '/app/google-services.json',
            src: [
                'google-services.json',
                ANDROID_DIR + '/assets/www/google-services.json',
                'www/google-services.json',
                ANDROID_DIR + '/app/src/main/google-services.json'
            ],
            colorsXml: {
                src: './plugins/' + utilities.getPluginId() + '/src/android/colors.xml',
                target: ANDROID_DIR + '/app/src/main/res/values/colors.xml'
            },
            performanceGradlePlugin: {
                classDef: 'com.google.firebase:perf-plugin',
                pluginDef: 'com.google.firebase.firebase-perf'
            }
        }
    };
}

module.exports = function(context){
    //get platform from the context supplied by cordova
    var platforms = context.opts.platforms;
    utilities.setContext(context);
    setupEnv();

    pluginVariables = utilities.parsePluginVariables();

    // set platform key path from plugin variable
    if(pluginVariables.ANDROID_FIREBASE_CONFIG_FILEPATH) PLATFORM.ANDROID.src = [pluginVariables.ANDROID_FIREBASE_CONFIG_FILEPATH];
    if(pluginVariables.IOS_FIREBASE_CONFIG_FILEPATH) PLATFORM.IOS.src = [pluginVariables.IOS_FIREBASE_CONFIG_FILEPATH];


    // Copy key files to their platform specific folders
    if(platforms.indexOf('android') !== -1 && utilities.directoryExists(ANDROID_DIR)){
        utilities.log('Preparing Firebase on Android');
        utilities.copyKey(PLATFORM.ANDROID);

        var androidHelper = require("./lib/android");

        // Apply colours
        if(!fs.existsSync(path.resolve(PLATFORM.ANDROID.colorsXml.target))){
            fs.copyFileSync(path.resolve(PLATFORM.ANDROID.colorsXml.src), path.resolve(PLATFORM.ANDROID.colorsXml.target));
        }

        const $colorsXml = utilities.parseXmlFileToJson(PLATFORM.ANDROID.colorsXml.target, {compact: true});
        var accentColor = pluginVariables.ANDROID_ICON_ACCENT,
            $resources = $colorsXml.resources,
            existingAccent = false,
            writeChanges = false;

        if($resources.color){
            var $colors = $resources.color.length ? $resources.color : [$resources.color];
            $colors.forEach(function($color){
                if($color._attributes.name === 'accent'){
                    existingAccent = true;
                    if($color._text !== accentColor){
                        $color._text = accentColor;
                        writeChanges = true;
                    }
                }
            });
        }else{
            $resources.color = {};
        }

        if(!existingAccent){
            var $accentColor = {
                _attributes: {
                    name: 'accent'
                },
                _text: accentColor
            };
            if($resources.color && Object.keys($resources.color).length){
                if(typeof $resources.color.length === 'undefined'){
                    $resources.color = [$resources.color];
                }
                $resources.color.push($accentColor)
            }else{
                $resources.color = $accentColor;
            }
            writeChanges = true;
        }

        if(writeChanges){
            utilities.writeJsonToXmlFile($colorsXml, PLATFORM.ANDROID.colorsXml.target);
            utilities.log('Updated colors.xml with accent color');
        }

        if(pluginVariables['ANDROID_FIREBASE_PERFORMANCE_MONITORING'] && pluginVariables['ANDROID_FIREBASE_PERFORMANCE_MONITORING'] === 'true'){
            // Add Performance Monitoring gradle plugin for Android network traffic
            androidHelper.addDependencyToRootGradle(PLATFORM.ANDROID.performanceGradlePlugin.classDef+":"+pluginVariables["ANDROID_FIREBASE_PERF_GRADLE_PLUGIN_VERSION"]);
            androidHelper.applyPluginToAppGradle(PLATFORM.ANDROID.performanceGradlePlugin.pluginDef);
        }
    }

    if(platforms.indexOf('ios') !== -1 && utilities.directoryExists(IOS_DIR)){
        utilities.log('Preparing Firebase on iOS');
        utilities.copyKey(PLATFORM.IOS);

        var helper = require("./ios/helper");
        var xcodeProjectPath = helper.getXcodeProjectPath();
        var podFileModified = false;
        helper.ensureRunpathSearchPath(context, xcodeProjectPath);
        podFileModified = helper.applyPodsPostInstall(pluginVariables, PLATFORM.IOS);
        helper.applyPluginVarsToPlists(pluginVariables, PLATFORM.IOS);
        podFileModified = helper.applyPluginVarsToPodfile(pluginVariables, PLATFORM.IOS) || podFileModified;

        if(podFileModified){
            utilities.log('Updating installed Pods');
            execSync('pod install', {
                cwd: path.resolve(PLATFORM.IOS.platformDir),
                encoding: 'utf8'
            });
        }
    }
};

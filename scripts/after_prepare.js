#!/usr/bin/env node

'use strict';

/**
 * This hook makes sure projects using [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase)
 * will build properly and have the required key files copied to the proper destinations when the app is build on Ionic Cloud using the package command.
 * Credits: https://github.com/arnesson.
 */
var fs = require('fs');
var path = require("path");
var Utilities = require("./lib/utilities");

var appName;
var pluginVariables = {};

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';
var PLUGIN_ID;

var PLATFORM;

var setupEnv = function(){
    appName = Utilities.getAppName();
    PLUGIN_ID = Utilities.getPluginId();
    PLATFORM = {
        IOS: {
            dest: IOS_DIR + '/' + appName + '/Resources/GoogleService-Info.plist',
            src: [
                'GoogleService-Info.plist',
                IOS_DIR + '/www/GoogleService-Info.plist',
                'www/GoogleService-Info.plist'
            ],
            appPlist: IOS_DIR + '/' + appName + '/' + appName + '-Info.plist',
            entitlementsDebugPlist: IOS_DIR + '/' + appName + '/Entitlements-Debug.plist',
            entitlementsReleasePlist: IOS_DIR + '/' + appName + '/Entitlements-Release.plist',
        },
        ANDROID: {
            dest: ANDROID_DIR + '/app/google-services.json',
            src: [
                'google-services.json',
                ANDROID_DIR + '/assets/www/google-services.json',
                'www/google-services.json',
                ANDROID_DIR + '/app/src/main/google-services.json'
            ],
            colorsXml: {
                src: './plugins/' + Utilities.getPluginId() + '/src/android/colors.xml',
                target: ANDROID_DIR + '/app/src/main/res/values/colors.xml'
            }
        }
    };
}

module.exports = function(context){
    //get platform from the context supplied by cordova
    var platforms = context.opts.platforms;
    Utilities.setContext(context);
    setupEnv();

    pluginVariables = Utilities.parsePluginVariables();

    // set platform key path from plugin variable
    if(pluginVariables.ANDROID_FIREBASE_CONFIG_FILEPATH) PLATFORM.ANDROID.src = [pluginVariables.ANDROID_FIREBASE_CONFIG_FILEPATH];
    if(pluginVariables.IOS_FIREBASE_CONFIG_FILEPATH) PLATFORM.IOS.src = [pluginVariables.IOS_FIREBASE_CONFIG_FILEPATH];


    // Copy key files to their platform specific folders
    if(platforms.indexOf('android') !== -1 && Utilities.directoryExists(ANDROID_DIR)){
        Utilities.log('Preparing Firebase on Android');
        Utilities.copyKey(PLATFORM.ANDROID);

        if(!fs.existsSync(path.resolve(PLATFORM.ANDROID.colorsXml.target))){
            fs.copyFileSync(path.resolve(PLATFORM.ANDROID.colorsXml.src), path.resolve(PLATFORM.ANDROID.colorsXml.target));
        }

        const $colorsXml = Utilities.parseXmlFileToJson(PLATFORM.ANDROID.colorsXml.target, {compact: true});
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
            Utilities.writeJsonToXmlFile($colorsXml, PLATFORM.ANDROID.colorsXml.target);
            Utilities.log('Updated colors.xml with accent color');
        }
    }

    if(platforms.indexOf('ios') !== -1 && Utilities.directoryExists(IOS_DIR)){
        Utilities.log('Preparing Firebase on iOS');
        Utilities.copyKey(PLATFORM.IOS);

        var helper = require("./ios/helper");
        var xcodeProjectPath = helper.getXcodeProjectPath();
        helper.ensureRunpathSearchPath(context, xcodeProjectPath);

        if(pluginVariables['IOS_STRIP_DEBUG'] && pluginVariables['IOS_STRIP_DEBUG'] === 'true'){
            helper.stripDebugSymbols();
        }
        helper.applyPluginVarsToPlists(pluginVariables, PLATFORM.IOS);
    }
};

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

var appName = Utilities.getAppName();
var pluginVariables = {};

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';
var PLUGIN_ID = 'cordova-plugin-firebasex';

var PLATFORM = {
    IOS: {
        dest: IOS_DIR + '/' + appName + '/Resources/GoogleService-Info.plist',
        src: [
            'GoogleService-Info.plist',
            IOS_DIR + '/www/GoogleService-Info.plist',
            'www/GoogleService-Info.plist'
        ],
        appPlist: IOS_DIR + '/' + appName + '/'+appName+'-Info.plist',
    },
    ANDROID: {
        dest: ANDROID_DIR + '/app/google-services.json',
        src: [
            'google-services.json',
            ANDROID_DIR + '/assets/www/google-services.json',
            'www/google-services.json',
            ANDROID_DIR + '/app/src/main/google-services.json'
        ],
        colorsXml:{
            src: './plugins/' + Utilities.getPluginId() +'/src/android/colors.xml',
            target: ANDROID_DIR + '/app/src/main/res/values/colors.xml'
        }
    }
};


var parsePluginVariables = function(){
    // Parse plugin.xml
    var plugin = Utilities.parsePluginXml();
    var prefs = [];
    if(plugin.plugin.preference){
        prefs = prefs.concat(plugin.plugin.preference);
    }
    plugin.plugin.platform.forEach(function(platform){
        if(platform.preference){
            prefs = prefs.concat(platform.preference);
        }
    });
    prefs.forEach(function(pref){
        pluginVariables[pref._attributes.name] = pref._attributes.default;
    });

    // Parse config.xml
    var config = Utilities.parseConfigXml();
    (config.widget.plugin ? [].concat(config.widget.plugin) : []).forEach(function(plugin){
        (plugin.variable ? [].concat(plugin.variable) : []).forEach(function(variable){
            if((plugin._attributes.name === PLUGIN_ID || plugin._attributes.id === PLUGIN_ID) && variable._attributes.name && variable._attributes.value){
                pluginVariables[variable._attributes.name] = variable._attributes.value;
            }
        });
    });

    // Parse package.json
    var packageJSON = Utilities.parsePackageJson();
    if(packageJSON.cordova && packageJSON.cordova.plugins){
        for(const pluginId in packageJSON.cordova.plugins){
            if(pluginId === PLUGIN_ID){
                for(const varName in packageJSON.cordova.plugins[pluginId]){
                    var varValue = packageJSON.cordova.plugins[pluginId][varName];
                    pluginVariables[varName] = varValue;
                }
            }
        }
    }
};

module.exports = function (context) {

  //get platform from the context supplied by cordova
  var platforms = context.opts.platforms;
  parsePluginVariables();

    // Copy key files to their platform specific folders
    if (platforms.indexOf('android') !== -1 && Utilities.directoryExists(ANDROID_DIR)) {
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
            if($resources.color && $resources.color._text){
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

    if (platforms.indexOf('ios') !== -1 && Utilities.directoryExists(IOS_DIR)){
        Utilities.log('Preparing Firebase on iOS');
        Utilities.copyKey(PLATFORM.IOS);

        var helper = require("./ios/helper");
        var xcodeProjectPath = helper.getXcodeProjectPath();
        helper.ensureRunpathSearchPath(context, xcodeProjectPath);

        if(pluginVariables['IOS_STRIP_DEBUG'] && pluginVariables['IOS_STRIP_DEBUG'] === 'true'){
            helper.stripDebugSymbols();
        }
        helper.applyPluginVarsToPlists(PLATFORM.IOS.dest, PLATFORM.IOS.appPlist, pluginVariables);
    }
};

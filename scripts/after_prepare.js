#!/usr/bin/env node

'use strict';

/**
 * This hook makes sure projects using [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase)
 * will build properly and have the required key files copied to the proper destinations when the app is build on Ionic Cloud using the package command.
 * Credits: https://github.com/arnesson.
 */
var fs = require('fs');
var path = require('path');
var Q = require('q');
var parser = new (require('xml2js')).Parser();

var utilities = require("./lib/utilities");

var configJson;
var appName;
var pluginVariables = {};

var IOS_DIR = 'platforms/ios';
var ANDROID_DIR = 'platforms/android';
var PLUGIN_ID = 'cordova-plugin-firebasex';

var PLATFORM;

var resolveAppName = function(config){
    appName = config.widget.name.toString().trim();
    if (appName.includes('&amp;')) {
        appName = appName.replace(/&amp;/g, '&');
    }
    PLATFORM = {
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
        }
    };
};

var parseConfigXml = function () {
    const deferred = Q.defer();
    if(configJson){
        deferred.resolve(configJson);
    }else{
        var configXml = fs.readFileSync('config.xml').toString();
        parser.parseString(configXml, function (err, _config) {
            configJson = _config;
            deferred.resolve(_config);
        });
    }
    return deferred.promise;
};

var parsePackageJson = function(){
    return JSON.parse(fs.readFileSync('./package.json'));
};

var parsePluginVariables = function(){
    const deferred = Q.defer();
    parseConfigXml().then(function(config){
        (config.widget.plugin || []).forEach(function(plugin){
            (plugin.variable || []).forEach(function(variable){
                if((plugin.$.name === PLUGIN_ID || plugin.$.id === PLUGIN_ID) && variable.$.name && variable.$.value){
                    pluginVariables[variable.$.name] = variable.$.value;
                }
            });
        });

        var packageJSON = parsePackageJson();
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
        deferred.resolve();
    });
    return deferred.promise;
};

module.exports = function (context) {
  const deferred = Q.defer();

  //get platform from the context supplied by cordova
  var platforms = context.opts.platforms;


  parseConfigXml().then(function(config){
      resolveAppName(config);

      // Copy key files to their platform specific folders
      if (platforms.indexOf('android') !== -1 && utilities.directoryExists(ANDROID_DIR)) {
          console.log('Preparing Firebase on Android');
          utilities.copyKey(PLATFORM.ANDROID);
      }

      if (platforms.indexOf('ios') !== -1 && utilities.directoryExists(IOS_DIR)) {
          console.log('Preparing Firebase on iOS');
          utilities.copyKey(PLATFORM.IOS);

          var helper = require("./ios/helper");
          helper.getXcodeProjectPath(function(xcodeProjectPath){
              helper.ensureRunpathSearchPath(context, xcodeProjectPath);
          });

          parsePluginVariables().then(function(){
              if(pluginVariables['IOS_STRIP_DEBUG'] && pluginVariables['IOS_STRIP_DEBUG'] === 'true'){
                  helper.stripDebugSymbols();
              }
              helper.applyPluginVarsToPlists(PLATFORM.IOS.dest, PLATFORM.IOS.appPlist, pluginVariables);

              deferred.resolve();
          }).catch(error => {
              deferred.reject(error);
          });
      }else{
          deferred.resolve();
      }
  });

  return deferred.promise;
};

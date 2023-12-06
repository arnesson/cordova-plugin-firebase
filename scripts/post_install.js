#!/usr/bin/env node

/**********
 * Globals
 **********/

const PLUGIN_NAME = "FirebaseX plugin";
const PLUGIN_ID = "cordova-plugin-firebasex";

const VARIABLE_NAMES = [
    "IOS_USE_PRECOMPILED_FIRESTORE_POD",
    "FIREBASE_ANALYTICS_WITHOUT_ADS",
    "IOS_ON_DEVICE_CONVERSION_ANALYTICS"
];

const variableApplicators = {};

// Node dependencies
let path, cwd, fs;

// External dependencies
let parser;

// Global vars
let projectPath, modulesPath, pluginNodePath,
    projectPackageJsonPath, projectPackageJsonData,
    configXmlPath, configXmlData,
    pluginXmlPath, pluginXmlText, pluginXmlData,
    pluginVariables;

let pluginXmlModified = false;

/*********************
 * Internal functions
 *********************/

variableApplicators.IOS_USE_PRECOMPILED_FIRESTORE_POD = function(){
    const firestorePodsRegExp = /<pod name="FirebaseFirestore" spec="(\d+\.\d+\.\d+)"\/>/,
        precompiledPodReplacementPattern = `<pod name="FirebaseFirestore" tag="$version$" git="https://github.com/invertase/firestore-ios-sdk-frameworks.git" />`,
        match = pluginXmlText.match(firestorePodsRegExp);
    if(!match){
        console.warn(`Failed to find <pod name="FirebaseFirestore"> in ${PLUGIN_ID}/plugin.xml`);
        return;
    }

    const precompiledPodReplacement = precompiledPodReplacementPattern.replace("$version$", match[1]);
    pluginXmlText = pluginXmlText.replace(firestorePodsRegExp, precompiledPodReplacement);
    pluginXmlModified = true;
}

variableApplicators.FIREBASE_ANALYTICS_WITHOUT_ADS = function(){
    // iOS
    const firebaseAnalyticsWithAdsPodFragment = `<pod name="FirebaseAnalytics"`,
        firebaseAnalyticsWithoutAdsPodFragment = `<pod name="FirebaseAnalytics/WithoutAdIdSupport"`,
        podMatch = pluginXmlText.match(firebaseAnalyticsWithAdsPodFragment);

    if(podMatch){
        pluginXmlText = pluginXmlText.replace(firebaseAnalyticsWithAdsPodFragment, firebaseAnalyticsWithoutAdsPodFragment);
        pluginXmlModified = true;
    }else{
        console.warn(`Failed to find <pod name="FirebaseAnalytics"> in ${PLUGIN_ID}/plugin.xml`);
    }

    // Android
    const googleAnalyticsAdIdEnabled = `<meta-data android:name="google_analytics_adid_collection_enabled" android:value="true" />`,
        googleAnalyticsAdIdDisabled = `<meta-data android:name="google_analytics_adid_collection_enabled" android:value="false" />`,
        googleAnalyticsAdIdMatch = pluginXmlText.match(googleAnalyticsAdIdEnabled);

    if(googleAnalyticsAdIdMatch){
        pluginXmlText = pluginXmlText.replace(googleAnalyticsAdIdEnabled, googleAnalyticsAdIdDisabled);
        pluginXmlModified = true;
    }else{
        console.warn(`Failed to find <meta-data android:name="google_analytics_adid_collection_enabled"> in ${PLUGIN_ID}/plugin.xml`);
    }

    const commentedOutAdIdRemoval = `<!--<uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/>-->`,
        commentedInAdIdRemoval = `<uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/>`,
        commentedOutAdIdRemovalMatch = pluginXmlText.match(commentedOutAdIdRemoval);

    if(commentedOutAdIdRemovalMatch){
        pluginXmlText = pluginXmlText.replace(commentedOutAdIdRemoval, commentedInAdIdRemoval);
        pluginXmlModified = true;
    }else{
        console.warn(`Failed to find commented-out <uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/> in ${PLUGIN_ID}/plugin.xml`);
    }
}

variableApplicators.IOS_ON_DEVICE_CONVERSION_ANALYTICS = function(){
    const commentedOutPodRegExp = /<!--<pod name="FirebaseAnalyticsOnDeviceConversion" spec="(\d+\.\d+\.\d+)"\/>-->/,
        commentedInPattern = `<pod name="FirebaseAnalyticsOnDeviceConversion" spec="$version$"/>`,
        match = pluginXmlText.match(commentedOutPodRegExp);

    if(!match){
        console.warn(`Failed to find commented-out <pod name="FirebaseAnalyticsOnDeviceConversion"> in ${PLUGIN_ID}/plugin.xml`);
        return;
    }
    const replacement = commentedInPattern.replace("$version$", match[1]);
    pluginXmlText = pluginXmlText.replace(commentedOutPodRegExp, replacement);
    pluginXmlModified = true;
}

const run = function (){
    pluginVariables = parsePluginVariables();

    for(const variableName of VARIABLE_NAMES){
        applyPluginVariable(variableName);
    }

    if(pluginXmlModified) writePluginXmlText();
};

const applyPluginVariable = function(variableName){
    const shouldEnable = resolveBoolean(pluginVariables[variableName]);
    if(!shouldEnable) {
        console.log(`Skipping application of ${variableName} as not set to true.`);
        return;
    }
    console.log(`Applying ${variableName}=true to ${PLUGIN_ID}/plugin.xml`);
    variableApplicators[variableName]();
    console.log(`Applied ${variableName}=true to ${PLUGIN_ID}/plugin.xml`);
}

const handleError = function (errorMsg, errorObj) {
    errorMsg = PLUGIN_NAME + " - ERROR: " + errorMsg;
    console.error(errorMsg);
    console.dir(errorObj);
    return errorMsg;
    throw errorObj;
};

const resolveBoolean = function(value){
    if(typeof value === 'undefined' || value === null) return false;
    if(value === true || value === false) return value;
    return !isNaN(value) ? parseFloat(value) : /^\s*(true|false)\s*$/i.exec(value) ? RegExp.$1.toLowerCase() === "true" : value;
};

const parsePluginVariables = function(){

    const pluginVariables = {};
    // Parse plugin.xml
    const plugin = parsePluginXml();
    let prefs = [];
    if(plugin.plugin.preference){
        prefs = prefs.concat(plugin.plugin.preference);
    }
    if(typeof plugin.plugin.platform.length === 'undefined') plugin.plugin.platform = [plugin.plugin.platform];
    plugin.plugin.platform.forEach(function(platform){
        if(platform.preference){
            prefs = prefs.concat(platform.preference);
        }
    });
    prefs.forEach(function(pref){
        if (pref._attributes){
            pluginVariables[pref._attributes.name] = pref._attributes.default;
        }
    });

    // Parse config.xml
    const config = parseConfigXml();
    if(config) {
        (config.widget.plugin ? [].concat(config.widget.plugin) : []).forEach(function (plugin) {
            (plugin.variable ? [].concat(plugin.variable) : []).forEach(function (variable) {
                if ((plugin._attributes.name === PLUGIN_ID || plugin._attributes.id === PLUGIN_ID) && variable._attributes.name && variable._attributes.value) {
                    pluginVariables[variable._attributes.name] = variable._attributes.value;
                }
            });
        });
    }

    // Parse package.json
    const packageJSON = parsePackageJson();
    if(packageJSON && packageJSON.cordova && packageJSON.cordova.plugins){
        for(const pluginId in packageJSON.cordova.plugins){
            if(pluginId === PLUGIN_ID){
                for(const varName in packageJSON.cordova.plugins[pluginId]){
                    const varValue = packageJSON.cordova.plugins[pluginId][varName];
                    pluginVariables[varName] = varValue;
                }
            }
        }
    }

    return pluginVariables;
};

const parsePackageJson = function(){
    if(projectPackageJsonData) return projectPackageJsonData;
    try{
        projectPackageJsonData =  JSON.parse(fs.readFileSync(projectPackageJsonPath));
        return projectPackageJsonData;
    }catch(e){
        console.warn("Failed to parse package.json: " + e.message);
    }
};

const parseConfigXml = function(){
    if(configXmlData) return configXmlData;
    try{
        data = parseXmlFileToJson(configXmlPath);
        configXmlData = data.xml;
        return configXmlData;
    }catch (e){
        console.warn("Failed to parse config.xml: " + e.message);
    }
};

const parsePluginXml = function(){
    if(pluginXmlData) return pluginXmlData;
    const data = parseXmlFileToJson(pluginXmlPath);
    pluginXmlText = data.text;
    pluginXmlData = data.xml;
    return pluginXmlData;
};

const parseXmlFileToJson = function(filepath, parseOpts){
    parseOpts = parseOpts || {compact: true};
    const text = fs.readFileSync(path.resolve(filepath), 'utf-8');
    const xml = JSON.parse(parser.xml2json(text, parseOpts));
    return {text, xml};
};

const writePluginXmlText = function(){
    fs.writeFileSync(pluginXmlPath, pluginXmlText, 'utf-8');
    console.log(`Wrote modified ${PLUGIN_ID}/plugin.xml`);
};

/**********
 * Main
 **********/
const main = function() {
    try{
        fs = require('fs');
        path = require('path');

        cwd = path.resolve();
        pluginNodePath = cwd;

        modulesPath = path.resolve(pluginNodePath, "..");
        projectPath = path.resolve(modulesPath, "..");

        try{
            parser = require("xml-js");
        }catch (e){
            console.warn("Failed to load 'xml-js' module. Trying using modulesPath: "+modulesPath);
        }
        if(!parser){
            try{
                parser = require(path.resolve(modulesPath, "xml-js"));
            }catch (e){
                console.warn("Failed to load 'xml-js' module using modulesPath");
            }
        }
        if(!parser){
            throw new Error("Failed to load 'xml-js' module");
        }
    }catch(e){
        handleError("Failed to load dependencies for "+PLUGIN_ID+"': " + e.message, e);
    }

    try{
        projectPackageJsonPath = path.join(projectPath, 'package.json');
        configXmlPath = path.join(projectPath, 'config.xml');
        pluginXmlPath = path.join(pluginNodePath, "plugin.xml");
        run();
    }catch(e){
        handleError(e.message, e);
    }
};
main();

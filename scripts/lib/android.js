/**
 * Android-specific utilities
 */
const fs = require('fs');
const path = require('path');
const utilities = require("./utilities");

const ANDROID_PROJECT_ROOT = 'platforms/android';
const ROOT_GRADLE_FILEPATH = ANDROID_PROJECT_ROOT + '/build.gradle';
const APP_GRADLE_FILEPATH = ANDROID_PROJECT_ROOT + '/app/build.gradle';

const gradleDependencyTemplate = "classpath '{artifactDef}'";
const applyPluginTemplate = "apply plugin: '{pluginDef}'";

const Android = {};

Android.addDependencyToRootGradle = function(artifactDef){
    const gradleDependency = gradleDependencyTemplate.replace("{artifactDef}", artifactDef);
    let rootGradle = fs.readFileSync(path.resolve(ROOT_GRADLE_FILEPATH)).toString();
    if(rootGradle.match(gradleDependency)) return; // already exists

    rootGradle = rootGradle.replace("dependencies {", "dependencies {\n"+gradleDependency);
    fs.writeFileSync(path.resolve(ROOT_GRADLE_FILEPATH), rootGradle);
    utilities.log("Added dependency to root gradle: " + artifactDef);
};

Android.applyPluginToAppGradle = function(pluginDef){
    const applyPlugin = applyPluginTemplate.replace("{pluginDef}", pluginDef);
    let appGradle = fs.readFileSync(path.resolve(APP_GRADLE_FILEPATH)).toString();
    if(appGradle.match(applyPlugin)) return; // already exists

    appGradle += "\n"+applyPlugin;
    fs.writeFileSync(path.resolve(APP_GRADLE_FILEPATH), appGradle);
    utilities.log("Applied plugin to app gradle: " + pluginDef);
};

module.exports = Android;

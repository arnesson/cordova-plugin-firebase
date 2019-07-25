const fs = require("fs");
const path = require("path");

function rootBuildGradleExists() {
    const target = path.join("platforms", "android", "build.gradle");
    return fs.existsSync(target);
}

/*
 * Helper function to read the build.gradle that sits at the root of the project
 */
function readRootBuildGradle() {
    const target = path.join("platforms", "android", "build.gradle");
    return fs.readFileSync(target, "utf-8");
}

/*
 * Added a dependency on 'com.google.gms' based on the position of the know 'com.android.tools.build' dependency in the build.gradle
 */
function addDependencies(buildGradle) {
    // find the known line to match
    const match = buildGradle.match(/^(\s*)classpath 'com.android.tools.build(.*)/m);
    const whitespace = match[1];

    // modify the line to add the necessary dependencies
    const googlePlayDependency = whitespace + 'classpath \'com.google.gms:google-services:4.2.0\' // google-services dependency from cordova-plugin-firebase-lib';
    const fabricDependency = whitespace + 'classpath \'io.fabric.tools:gradle:1.25.4\' // fabric dependency from cordova-plugin-firebase-lib';
    const modifiedLine = match[0] + '\n' + googlePlayDependency + '\n' + fabricDependency;

    // modify the actual line
    return buildGradle.replace(/^(\s*)classpath 'com.android.tools.build(.*)/m, modifiedLine);
}

/*
 * Add 'google()' and Crashlytics to the repository repo list
 */
function addRepos(buildGradle) {
    // find the known line to match
    let match = buildGradle.match(/^(\s*)jcenter\(\)/m);
    const whitespace = match[1];

    // modify the line to add the necessary repo
    // Crashlytics goes under buildscripts which is the first grouping in the file
    const fabricMavenRepo = whitespace + 'maven { url \'https://maven.fabric.io/public\' } // Fabrics Maven repository from cordova-plugin-firebase-lib'
    let modifiedLine = match[0] + '\n' + fabricMavenRepo;

    // modify the actual line
    buildGradle = buildGradle.replace(/^(\s*)jcenter\(\)/m, modifiedLine);

    // update the all projects grouping
    const allProjectsIndex = buildGradle.indexOf('allprojects');
    if (allProjectsIndex > 0) {
        // split the string on allprojects because jcenter is in both groups and we need to modify the 2nd instance
        const firstHalfOfFile = buildGradle.substring(0, allProjectsIndex);
        let secondHalfOfFile = buildGradle.substring(allProjectsIndex);

        // Add google() to the allprojects section of the string
        match = secondHalfOfFile.match(/^(\s*)jcenter\(\)/m);
        const googlesMavenRepo = whitespace + 'google() // Google\'s Maven repository from cordova-plugin-firebase-lib';
        modifiedLine = match[0] + '\n' + googlesMavenRepo;
        // modify the part of the string that is after 'allprojects'
        secondHalfOfFile = secondHalfOfFile.replace(/^(\s*)jcenter\(\)/m, modifiedLine);

        // recombine the modified line
        buildGradle = firstHalfOfFile + secondHalfOfFile;
    } else {
        // this should not happen, but if it does, we should try to add the dependency to the buildscript
        match = buildGradle.match(/^(\s*)jcenter\(\)/m);
        const googlesMavenRepo = whitespace + 'google() // Google\'s Maven repository from cordova-plugin-firebase-lib';
        modifiedLine = match[0] + '\n' + googlesMavenRepo;
        // modify the part of the string that is after 'allprojects'
        buildGradle = buildGradle.replace(/^(\s*)jcenter\(\)/m, modifiedLine);
    }

    return buildGradle;
}

/*
 * Helper function to write to the build.gradle that sits at the root of the project
 */
function writeRootBuildGradle(contents) {
    const target = path.join("platforms", "android", "build.gradle");
    fs.writeFileSync(target, contents);
}

module.exports = {

    modifyRootBuildGradle: function () {
        // be defensive and don't crash if the file doesn't exist
        if (!rootBuildGradleExists) {
            return;
        }

        let buildGradle = readRootBuildGradle();

        // Add Google Play Services Dependency
        buildGradle = addDependencies(buildGradle);

        // Add Google's Maven Repo
        buildGradle = addRepos(buildGradle);

        writeRootBuildGradle(buildGradle);
    },

    restoreRootBuildGradle: function () {
        // be defensive and don't crash if the file doesn't exist
        if (!rootBuildGradleExists) {
            return;
        }

        let buildGradle = readRootBuildGradle();

        // remove any lines we added
        buildGradle = buildGradle.replace(/(?:^|\r?\n)(.*)cordova-plugin-firebase-lib*?(?=$|\r?\n)/g, '');

        writeRootBuildGradle(buildGradle);
    }
};

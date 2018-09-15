var fs = require("fs");
var path = require("path");

/*
 * Helper function to read the build.gradle that sits at the root of the project
 */
function readRootBuildGradle() {
  var target = path.join("platforms", "android", "build.gradle");
  return fs.readFileSync(target, "utf-8");
}

/*
 * Added a dependency on 'com.google.gms' based on the position of the know 'com.android.tools.build' dependency in the build.gradle
 */
function addGPSDependencies(buildGradle) {
  // find the known line to match
  var match = buildGradle.match(/^(\s*)classpath 'com.android.tools.build(.*)/m);
  var whitespace = match[1];
  
  // modify the line to add the necessary dependencies
  var googlePlayDependency = whitespace + 'classpath \'com.google.gms:google-services:4.1.0\' // google-services plugin from cordova-plugin-firebase';
  var modifiedLine = match[0] + '\n' + googlePlayDependency;
  
  // modify the actual line
  return buildGradle.replace(/^(\s*)classpath 'com.android.tools.build(.*)/m, modifiedLine);
}

/*
 * Add 'google()' to the repository repo list
 */
function addGoogleRepo(buildGradle) {
  // find the known line to match
  var match = buildGradle.match(/^(\s*)jcenter\(\)/m);
  var whitespace = match[1];

  // modify the line to add the necessary repo
  var googlesMavenRepo = whitespace + 'google() // Google\'s Maven repository from cordova-plugin-firebase';
  var modifiedLine = match[0] + '\n' + googlesMavenRepo;

  // modify the actual line
  return buildGradle.replace(/^(\s*)jcenter\(\)/m, modifiedLine);
}

/*
 * Helper function to write to the build.gradle that sits at the root of the project
 */
function writeRootBuildGradle(contents) {
  var target = path.join("platforms", "android", "build.gradle");
  fs.writeFileSync(target, contents);
}

module.exports = {

  modifyRootBuildGradle: function() {
    var buildGradle = readRootBuildGradle();

    // Add Google Play Services Dependency
    buildGradle = addGPSDependencies(buildGradle);
  
    // Add Google's Maven Repo
    buildGradle = addGoogleRepo(buildGradle);

    writeRootBuildGradle(buildGradle);
  },

  restoreRootBuildGradle: function() {
    var buildGradle = readRootBuildGradle();

    // remove any lines we added
    buildGradle = buildGradle.replace(/(?:^|\r?\n)(.*)cordova-plugin-firebase*?(?=$|\r?\n)/g, '');
  
    writeRootBuildGradle(buildGradle);
  }
};
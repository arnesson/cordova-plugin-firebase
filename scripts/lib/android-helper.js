var fs = require("fs");
var path = require("path");
var utilities = require("./utilities");

module.exports = {

  addFabricBuildToolsGradle: function () {

    var buildGradle = utilities.readBuildGradle();

    var addToBuildGradle = [
      "",
      "// Fabric Cordova Plugin - Start Fabric Build Tools ",
      "buildscript {",
      "    repositories {",
      "        maven { url 'https://maven.fabric.io/public' }",
      "        maven { url 'https://maven.google.com' }",
      "    }",
      "    dependencies {",
      "        classpath 'io.fabric.tools:gradle:1.25.4'",
      "        classpath 'com.google.gms:google-services:+'",
      "    }",
      "}",
      "",
      "apply plugin: 'io.fabric'",
      "apply plugin: 'com.google.gms.google-services'",
      "// Fabric Cordova Plugin - End Fabric Build Tools"
    ].join("\n");

    buildGradle = buildGradle.replace(/(\/\/ PLUGIN GRADLE EXTENSIONS START)/, addToBuildGradle + '\n\n$1');

    utilities.writeBuildGradle(buildGradle);
  },

  removeFabricBuildToolsFromGradle: function () {

    var buildGradle = utilities.readBuildGradle();

    buildGradle = buildGradle.replace(/\n\/\/ Fabric Cordova Plugin - Start Fabric Build Tools[\s\S]*\/\/ Fabric Cordova Plugin - End Fabric Build Tools/, "");

    utilities.writeBuildGradle(buildGradle);
  }
};
/**
 * Utilities and shared functionality for the build hooks.
 */

var path = require("path");

module.exports = {

  /**
     * Used to get the name of the application as defined in the config.xml.
     *
     * @param {object} context - The Cordova context.
     * @returns {string} The value of the name element in config.xml.
     */
  getAppName: function (context) {
    var ConfigParser = context.requireCordovaModule("cordova-lib").configparser;
    var config = new ConfigParser("config.xml");
    return config.name();
  },

  /**
     * The ID of the plugin; this should match the ID in plugin.xml.
     */
  getPluginId: function () {
    return "cordova-plugin-firebase";
  },

  /**
     * Used to get the path to the XCode project's .pbxproj file.
     *
     * @param {object} context - The Cordova context.
     * @returns The path to the XCode project's .pbxproj file.
     */
  getXcodeProjectPath: function (context) {

    var appName = this.getAppName(context);

    return path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
  },

};
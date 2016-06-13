cordova.define("cordova-plugin-fcm.fcm", function(require, exports, module) {
var exec = require('cordova/exec');

exports.coolMethod = function(arg0, success, error) {
    exec(success, error, "FCMPlugin", "coolMethod", [arg0]);
};

});

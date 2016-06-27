var exec = require('cordova/exec');

exports.getInstanceId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getInstanceId", []);
};

exports.logEvent = function(key, value, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [key, value]);
};

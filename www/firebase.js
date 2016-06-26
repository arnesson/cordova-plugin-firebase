var exec = require('cordova/exec');

exports.getRegistrationId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getRegistrationId", []);
};

exports.logEvent = function(key, value, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [key, value]);
};

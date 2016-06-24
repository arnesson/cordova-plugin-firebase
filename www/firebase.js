var exec = require('cordova/exec');

exports.getRegistrationId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getRegistrationId", []);
};

exports.startAnalytics = function(success, error) {
    exec(success, error, "FirebasePlugin", "startAnalytics", []);
};

exports.logEvent = function(category, action, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [category, action]);
};

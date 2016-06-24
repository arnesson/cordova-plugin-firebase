var exec = require('cordova/exec');

exports.getRegistrationId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getRegistrationId", []);
};

exports.logEvent = function(category, action, label, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [category, action]);
};

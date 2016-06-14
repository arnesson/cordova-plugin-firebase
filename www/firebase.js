var exec = require('cordova/exec');

exports.getRegistrationId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getRegistrationId", []);
};

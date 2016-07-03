var exec = require('cordova/exec');

exports.getInstanceId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getInstanceId", []);
};

exports.onNotificationOpen = function(success, error) {
    exec(success, error, "FirebasePlugin", "onNotificationOpen", []);
};

exports.grantPermission = function(success, error) {
    exec(success, error, "FirebasePlugin", "grantPermission", []);
};

exports.subscribe = function(topic, success, error) {
    exec(success, error, "FirebasePlugin", "subscribe", [topic]);
};

exports.unsubscribe = function(topic, success, error) {
    exec(success, error, "FirebasePlugin", "unsubscribe", [topic]);
};

exports.logEvent = function(key, value, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [key, value]);
};

exports.setDefaults = function (defaults, success, error) {
    exec(success, error, "FirebasePlugin", "setDefaults", [defaults]);
};

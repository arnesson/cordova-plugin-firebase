var exec = require('cordova/exec');
exports.getVerificationID = function(number, success, error) {
    exec(success, error, "FirebasePlugin", "getVerificationID", [number]);
};

exports.getInstanceId = function(success, error) {
    exec(success, error, "FirebasePlugin", "getInstanceId", []);
};

exports.getToken = function(success, error) {
    exec(success, error, "FirebasePlugin", "getToken", []);
};

exports.onNotificationOpen = function(success, error) {
    exec(success, error, "FirebasePlugin", "onNotificationOpen", []);
};

exports.onTokenRefresh = function(success, error) {
    exec(success, error, "FirebasePlugin", "onTokenRefresh", []);
};

exports.grantPermission = function(success, error) {
    exec(success, error, "FirebasePlugin", "grantPermission", []);
};

exports.hasPermission = function(success, error) {
    exec(success, error, "FirebasePlugin", "hasPermission", []);
};

exports.setBadgeNumber = function(number, success, error) {
    exec(success, error, "FirebasePlugin", "setBadgeNumber", [number]);
};

exports.getBadgeNumber = function(success, error) {
    exec(success, error, "FirebasePlugin", "getBadgeNumber", []);
};

exports.subscribe = function(topic, success, error) {
    exec(success, error, "FirebasePlugin", "subscribe", [topic]);
};

exports.unsubscribe = function(topic, success, error) {
    exec(success, error, "FirebasePlugin", "unsubscribe", [topic]);
};

exports.unregister = function(success, error) {
    exec(success, error, "FirebasePlugin", "unregister", []);
};

exports.logEvent = function(name, params, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [name, params]);
};

exports.logError = function(message, success, error) {
    exec(success, error, "FirebasePlugin", "logError", [message]);
};

exports.setScreenName = function(name, success, error) {
    exec(success, error, "FirebasePlugin", "setScreenName", [name]);
};

exports.setUserId = function(id, success, error) {
    exec(success, error, "FirebasePlugin", "setUserId", [id]);
};

exports.setUserProperty = function(name, value, success, error) {
    exec(success, error, "FirebasePlugin", "setUserProperty", [name, value]);
};

exports.activateFetched = function (success, error) {
    exec(success, error, "FirebasePlugin", "activateFetched", []);
};

exports.fetch = function (cacheExpirationSeconds, success, error) {
    var args = [];
    if (typeof cacheExpirationSeconds === 'number') {
        args.push(cacheExpirationSeconds);
    } else {
        error = success;
        success = cacheExpirationSeconds;
    }
    exec(success, error, "FirebasePlugin", "fetch", args);
};

exports.getByteArray = function (key, namespace, success, error) {
    var args = [key];
    if (typeof namespace === 'string') {
        args.push(namespace);
    } else {
        error = success;
        success = namespace;
    }
    exec(success, error, "FirebasePlugin", "getByteArray", args);
};

exports.getValue = function (key, namespace, success, error) {
    var args = [key];
    if (typeof namespace === 'string') {
        args.push(namespace);
    } else {
        error = success;
        success = namespace;
    }
    exec(success, error, "FirebasePlugin", "getValue", args);
};

exports.getInfo = function (success, error) {
    exec(success, error, "FirebasePlugin", "getInfo", []);
};

exports.setConfigSettings = function (settings, success, error) {
    exec(success, error, "FirebasePlugin", "setConfigSettings", [settings]);
};

exports.setDefaults = function (defaults, namespace, success, error) {
    var args = [defaults];
    if (typeof namespace === 'string') {
        args.push(namespace);
    } else {
        error = success;
        success = namespace;
    }
    exec(success, error, "FirebasePlugin", "setDefaults", args);
};

exports.verifyPhoneNumber = function(number, timeOutDuration, success, error) {
    exec(success, error, "FirebasePlugin", "verifyPhoneNumber", [number, timeOutDuration]);
};
var exec = require('cordova/exec');

exports.getVerificationID = function (number, success, error) {
    exec(success, error, "FirebasePlugin", "getVerificationID", [number]);
};

exports.getId = function (success, error) {
    exec(success, error, "FirebasePlugin", "getId", []);
};

exports.getToken = function (success, error) {
    exec(success, error, "FirebasePlugin", "getToken", []);
};

exports.onNotificationOpen = function (success, error) {
    exec(success, error, "FirebasePlugin", "onNotificationOpen", []);
};

exports.onTokenRefresh = function (success, error) {
    exec(success, error, "FirebasePlugin", "onTokenRefresh", []);
};

exports.grantPermission = function (success, error) {
    exec(success, error, "FirebasePlugin", "grantPermission", []);
};

exports.hasPermission = function (success, error) {
    exec(success, error, "FirebasePlugin", "hasPermission", []);
};

exports.setBadgeNumber = function (number, success, error) {
    exec(success, error, "FirebasePlugin", "setBadgeNumber", [number]);
};

exports.getBadgeNumber = function (success, error) {
    exec(success, error, "FirebasePlugin", "getBadgeNumber", []);
};

exports.subscribe = function (topic, success, error) {
    exec(success, error, "FirebasePlugin", "subscribe", [topic]);
};

exports.unsubscribe = function (topic, success, error) {
    exec(success, error, "FirebasePlugin", "unsubscribe", [topic]);
};

exports.unregister = function (success, error) {
    exec(success, error, "FirebasePlugin", "unregister", []);
};

exports.logEvent = function (name, params, success, error) {
    exec(success, error, "FirebasePlugin", "logEvent", [name, params]);
};

exports.logError = function (message, stackTrace, success, error) {
    var args = [message];
    // "stackTrace" is an optional arg that's an array of objects.
    if (stackTrace) {
        if (typeof stackTrace === 'function') {
            error = success;
            success = stackTrace;
        } else {
            args.push(stackTrace);
        }
    }
    exec(success, error, "FirebasePlugin", "logError", args);
};

exports.setCrashlyticsUserId = function (userId, success, error) {
    exec(success, error, "FirebasePlugin", "setCrashlyticsUserId", [userId]);
};

exports.setScreenName = function (name, success, error) {
    exec(success, error, "FirebasePlugin", "setScreenName", [name]);
};

exports.setUserId = function (id, success, error) {
    exec(success, error, "FirebasePlugin", "setUserId", [id]);
};

exports.setUserProperty = function (name, value, success, error) {
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

exports.getByteArray = function (key, success, error) {
    exec(success, error, "FirebasePlugin", "getByteArray", [key]);
};

exports.getValue = function (key, success, error) {
    exec(success, error, "FirebasePlugin", "getValue", [key]);
};

exports.getInfo = function (success, error) {
    exec(success, error, "FirebasePlugin", "getInfo", []);
};

exports.setConfigSettings = function (settings, success, error) {
    exec(success, error, "FirebasePlugin", "setConfigSettings", [settings]);
};

exports.setDefaults = function (defaults, success, error) {
    exec(success, error, "FirebasePlugin", "setDefaults", [defaults]);
};

exports.startTrace = function (name, success, error) {
    exec(success, error, "FirebasePlugin", "startTrace", [name]);
};

exports.incrementCounter = function (name, counterNamed, success, error) {
    exec(success, error, "FirebasePlugin", "incrementCounter", [name, counterNamed]);
};

exports.stopTrace = function (name, success, error) {
    exec(success, error, "FirebasePlugin", "stopTrace", [name]);
};

exports.setAnalyticsCollectionEnabled = function (enabled, success, error) {
    exec(success, error, "FirebasePlugin", "setAnalyticsCollectionEnabled", [enabled]);
};

exports.setPerformanceCollectionEnabled = function (enabled, success, error) {
    exec(success, error, "FirebasePlugin", "setPerformanceCollectionEnabled", [enabled]);
};

exports.verifyPhoneNumber = function (number, timeOutDuration, success, error) {
    if (typeof timeOutDuration === 'function') {
        // method being called with old signature: function(number, success, error)
        // timeOutDuration is the success callback, success is the error callback
        exec(timeOutDuration, success, "FirebasePlugin", "verifyPhoneNumber", [number]);
    } else {
        // method being called with new signature: function(number, timeOutDuration, success, error)
        // callbacks are correctly named
        exec(success, error, "FirebasePlugin", "verifyPhoneNumber", [number, timeOutDuration]);
    }
};

exports.clearAllNotifications = function (success, error) {
    exec(success, error, "FirebasePlugin", "clearAllNotifications", []);
};

// For Android O only
exports.createChannel = function (success, error, channel) {
    exec(success, error, 'FirebasePlugin', 'createChannel', [channel]);
};

exports.getVerificationID = function (number, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getToken = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getId = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.onNotificationOpen = function (success, error) {
};

exports.onTokenRefresh = function (success, error) {
};

exports.grantPermission = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setBadgeNumber = function (number, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getBadgeNumber = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.subscribe = function (topic, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.unsubscribe = function (topic, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.logEvent = function (name, params, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.logError = function (message, stackTrace, success, error) {
    // "stackTrace" is an optional arg and is an array of objects.
    if (typeof stackTrace === 'function') {
        stackTrace();
    } else if (typeof success === 'function') {
        success();
    }
};

exports.setCrashlyticsUserId = function (userId, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setScreenName = function (name, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setUserId = function (id, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setUserProperty = function (name, value, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.activateFetched = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.fetch = function (cacheExpirationSeconds, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getByteArray = function (key, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getValue = function (key, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.getInfo = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setConfigSettings = function (settings, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setDefaults = function (defaults, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.verifyPhoneNumber = function (number, timeOutDuration, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setAnalyticsCollectionEnabled = function (enabled, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.setPerformanceCollectionEnabled = function (enabled, success, error) {
    if (typeof success === 'function') {
        success();
    }
};

exports.clearAllNotifications = function (success, error) {
    if (typeof success === 'function') {
        success();
    }
};

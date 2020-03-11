var exec = require('cordova/exec');

var ensureBooleanFn = function (callback){
    return function(result){
        callback(ensureBoolean(result));
    }
};

var ensureBoolean = function(value){
    if(value === "true"){
        value = true;
    }else if(value === "false"){
        value = false;
    }
    return !!value;
};

var onAuthStateChangeCallback = function(){};

/***********************
 * Protected internals
 ***********************/
exports._onAuthStateChange = function(userSignedIn){
    onAuthStateChangeCallback(userSignedIn);
};

/**************
 * Public API
 **************/

// Notifications
exports.getId = function (success, error) {
  exec(success, error, "FirebasePlugin", "getId", []);
};

exports.getToken = function (success, error) {
  exec(success, error, "FirebasePlugin", "getToken", []);
};

exports.getAPNSToken = function (success, error) {
  exec(success, error, "FirebasePlugin", "getAPNSToken", []);
};

exports.onMessageReceived = function (success, error) {
  exec(success, error, "FirebasePlugin", "onMessageReceived", []);
};

exports.onTokenRefresh = function (success, error) {
  exec(success, error, "FirebasePlugin", "onTokenRefresh", []);
};

exports.onApnsTokenReceived = function (success, error) {
    exec(success, error, "FirebasePlugin", "onApnsTokenReceived", []);
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

exports.isAutoInitEnabled = function (success, error) {
    exec(success, error, "FirebasePlugin", "isAutoInitEnabled", []);
};

exports.setAutoInitEnabled = function (enabled, success, error) {
    exec(success, error, "FirebasePlugin", "setAutoInitEnabled", [!!enabled]);
};

// Notifications - iOS-only
exports.setBadgeNumber = function (number, success, error) {
    exec(success, error, "FirebasePlugin", "setBadgeNumber", [number]);
};

exports.getBadgeNumber = function (success, error) {
    exec(success, error, "FirebasePlugin", "getBadgeNumber", []);
};

exports.grantPermission = function (success, error) {
    exec(ensureBooleanFn(success), error, "FirebasePlugin", "grantPermission", []);
};

exports.hasPermission = function (success, error) {
    exec(ensureBooleanFn(success), error, "FirebasePlugin", "hasPermission", []);
};

// Notifications - Android-only
exports.setDefaultChannel = function (options, success, error) {
    exec(success, error, "FirebasePlugin", "setDefaultChannel", [options]);
};

exports.createChannel = function (options, success, error) {
    exec(success, error, "FirebasePlugin", "createChannel", [options]);
};

exports.deleteChannel = function (channelID, success, error) {
    exec(success, error, "FirebasePlugin", "deleteChannel", [channelID]);
};

exports.listChannels = function (success, error) {
    exec(success, error, "FirebasePlugin", "listChannels", []);
};

// Analytics
exports.setAnalyticsCollectionEnabled = function (enabled, success, error) {
    exec(success, error, "FirebasePlugin", "setAnalyticsCollectionEnabled", [!!enabled]);
};

exports.isAnalyticsCollectionEnabled = function (success, error) {
    exec(success, error, "FirebasePlugin", "isAnalyticsCollectionEnabled", []);
};

exports.logEvent = function (name, params, success, error) {
  exec(success, error, "FirebasePlugin", "logEvent", [name, params]);
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
  exec(ensureBooleanFn(success), error, "FirebasePlugin", "activateFetched", []);
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

exports.setPerformanceCollectionEnabled = function (enabled, success, error) {
  exec(success, error, "FirebasePlugin", "setPerformanceCollectionEnabled", [!!enabled]);
};

exports.isPerformanceCollectionEnabled = function (success, error) {
    exec(success, error, "FirebasePlugin", "isPerformanceCollectionEnabled", []);
};

exports.clearAllNotifications = function (success, error) {
  exec(success, error, "FirebasePlugin", "clearAllNotifications", []);
};


// Crashlytics
exports.setCrashlyticsCollectionEnabled = function (enabled, success, error) {
    exec(success, error, "FirebasePlugin", "setCrashlyticsCollectionEnabled", [!!enabled]);
};

exports.isCrashlyticsCollectionEnabled = function (success, error) {
    exec(success, error, "FirebasePlugin", "isCrashlyticsCollectionEnabled", []);
};

exports.isCrashlyticsCollectionCurrentlyEnabled = function (success, error) {
    exec(success, error, "FirebasePlugin", "isCrashlyticsCollectionCurrentlyEnabled", []);
};

exports.logMessage = function (message, success, error) {
    exec(success, error, "FirebasePlugin", "logMessage", [message]);
};

exports.sendCrash = function (success, error) {
    exec(success, error, "FirebasePlugin", "sendCrash", []);
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


// Authentication
exports.verifyPhoneNumber = function (success, error, number, timeOutDuration, fakeVerificationCode) {
    exec(function(credential){
        if(typeof credential === 'object'){
            credential.instantVerification = ensureBoolean(credential.instantVerification);
        }
        success(credential);
    }, error, "FirebasePlugin", "verifyPhoneNumber", [number, timeOutDuration, fakeVerificationCode]);
};

exports.createUserWithEmailAndPassword = function (email, password, success, error) {
    exec(success, error, "FirebasePlugin", "createUserWithEmailAndPassword", [email, password]);
};

exports.signInUserWithEmailAndPassword = function (email, password, success, error) {
    exec(success, error, "FirebasePlugin", "signInUserWithEmailAndPassword", [email, password]);
};

exports.authenticateUserWithGoogle = function (clientId, success, error) {
    exec(success, error, "FirebasePlugin", "authenticateUserWithGoogle", [clientId]);
};

exports.authenticateUserWithApple = function (success, error, locale) {
    exec(success, error, "FirebasePlugin", "authenticateUserWithApple", [locale]);
};

exports.signInWithCredential = function (credential, success, error) {
    if(typeof credential !== 'object') return error("'credential' must be an object");
    exec(success, error, "FirebasePlugin", "signInWithCredential", [credential]);
};

exports.linkUserWithCredential = function (credential, success, error) {
    if(typeof credential !== 'object') return error("'credential' must be an object");
    exec(success, error, "FirebasePlugin", "linkUserWithCredential", [credential]);
};

exports.reauthenticateWithCredential = function (credential, success, error) {
    if(typeof credential !== 'object') return error("'credential' must be an object");
    exec(success, error, "FirebasePlugin", "reauthenticateWithCredential", [credential]);
};

exports.isUserSignedIn = function (success, error) {
    exec(ensureBooleanFn(success), error, "FirebasePlugin", "isUserSignedIn", []);
};

exports.signOutUser = function (success, error) {
    exec(ensureBooleanFn(success), error, "FirebasePlugin", "signOutUser", []);
};


exports.getCurrentUser = function (success, error) {
    exec(function(user){
        user.emailIsVerified = ensureBoolean(user.emailIsVerified);
        success(user);
    }, error, "FirebasePlugin", "getCurrentUser", []);
};

exports.updateUserProfile = function (profile, success, error) {
    if(typeof profile !== 'object') return error("'profile' must be an object with keys 'name' and/or 'photoUri'");
    exec(success, error, "FirebasePlugin", "updateUserProfile", [profile]);
};

exports.updateUserEmail = function (email, success, error) {
    if(typeof email !== 'string' || !email) return error("'email' must be a valid email address");
    exec(success, error, "FirebasePlugin", "updateUserEmail", [email]);
};

exports.sendUserEmailVerification = function (success, error) {
    exec(success, error, "FirebasePlugin", "sendUserEmailVerification", []);
};

exports.updateUserPassword = function (password, success, error) {
    if(typeof password !== 'string' || !password) return error("'password' must be a valid string");
    exec(success, error, "FirebasePlugin", "updateUserPassword", [password]);
};

exports.sendUserPasswordResetEmail = function (email, success, error) {
    if(typeof email !== 'string' || !email) return error("'email' must be a valid email address");
    exec(success, error, "FirebasePlugin", "sendUserPasswordResetEmail", [email]);
};

exports.deleteUser = function (success, error) {
    exec(success, error, "FirebasePlugin", "deleteUser", []);
};

exports.registerAuthStateChangeListener = function(fn){
    if(typeof fn !== "function") throw "The specified argument must be a function";
    onAuthStateChangeCallback = fn;
};

// Firestore
exports.addDocumentToFirestoreCollection = function (document, collection, success, error) {
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");
    if(typeof document !== 'object' || typeof document.length === 'number') return error("'document' must be an object specifying record data");

    exec(success, error, "FirebasePlugin", "addDocumentToFirestoreCollection", [document, collection]);
};

exports.setDocumentInFirestoreCollection = function (documentId, document, collection, success, error) {
    if(typeof documentId !== 'string' && typeof documentId !== 'number') return error("'documentId' must be a string or number specifying the Firestore document identifier");
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");
    if(typeof document !== 'object' || typeof document.length === 'number') return error("'document' must be an object specifying record data");

    exec(success, error, "FirebasePlugin", "setDocumentInFirestoreCollection", [documentId.toString(), document, collection]);
};

exports.updateDocumentInFirestoreCollection = function (documentId, document, collection, success, error) {
    if(typeof documentId !== 'string' && typeof documentId !== 'number') return error("'documentId' must be a string or number specifying the Firestore document identifier");
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");
    if(typeof document !== 'object' || typeof document.length === 'number') return error("'document' must be an object specifying record data");

    exec(success, error, "FirebasePlugin", "updateDocumentInFirestoreCollection", [documentId.toString(), document, collection]);
};

exports.deleteDocumentFromFirestoreCollection = function (documentId, collection, success, error) {
    if(typeof documentId !== 'string' && typeof documentId !== 'number') return error("'documentId' must be a string or number specifying the Firestore document identifier");
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");

    exec(success, error, "FirebasePlugin", "deleteDocumentFromFirestoreCollection", [documentId.toString(), collection]);
};

exports.fetchDocumentInFirestoreCollection = function (documentId, collection, success, error) {
    if(typeof documentId !== 'string' && typeof documentId !== 'number') return error("'documentId' must be a string or number specifying the Firestore document identifier");
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");

    exec(success, error, "FirebasePlugin", "fetchDocumentInFirestoreCollection", [documentId.toString(), collection]);
};

exports.fetchFirestoreCollection = function (collection, success, error) {
    if(typeof collection !== 'string') return error("'collection' must be a string specifying the Firestore collection name");

    exec(success, error, "FirebasePlugin", "fetchFirestoreCollection", [collection]);
};

# API

The list of available methods for this plugin is described below.

## getToken

Get the device token (id):
```
window.FirebasePlugin.getToken(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet

## onTokenRefresh

Register for token changes:
```
window.FirebasePlugin.onTokenRefresh(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```
This is the best way to get a valid token for the device as soon as the token is established

## onNotificationOpen

Register notification callback:
```
window.FirebasePlugin.onNotificationOpen(function(notification) {
    console.log(notification);
}, function(error) {
    console.error(error);
});
```
Notification flow:

1. App is in foreground:
    1. User receives the notification data in the JavaScript callback without any notification on the device itself (this is the normal behaviour of push notifications, it is up to you, the developer, to notify the user)
2. App is in background:
    1. User receives the notification message in its device notification bar
    2. User taps the notification and the app opens
    3. User receives the notification data in the JavaScript callback

Notification icon on Android:

[Changing notification icon](NOTIFICATIONS.md#changing-notification-icon)

## grantPermission (iOS only)

Grant permission to receive push notifications (will trigger prompt):
```
window.FirebasePlugin.grantPermission();
```
## hasPermission

Check permission to receive push notifications:
```
window.FirebasePlugin.hasPermission(function(data){
    console.log(data.isEnabled);
});
```

## setBadgeNumber

Set a number on the icon badge:
```
window.FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge
```
window.FirebasePlugin.setBadgeNumber(0);
```

## getBadgeNumber

Get icon badge number:
```
window.FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

## clearAllNotifications

Clear all pending notifications from the drawer:
```
window.FirebasePlugin.clearAllNotifications();
```

## subscribe

Subscribe to a topic:
```
window.FirebasePlugin.subscribe("example");
```

## unsubscribe

Unsubscribe from a topic:
```
window.FirebasePlugin.unsubscribe("example");
```

## unregister

Unregister from firebase, used to stop receiving push notifications. Call this when you logout user from your app. :
```
window.FirebasePlugin.unregister();
```

## logEvent

Log an event using Analytics:
```
window.FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

## setCrashlyticsUserId

Set Crashlytics user identifier.
- https://firebase.google.com/docs/crashlytics/customize-crash-reports?authuser=0#set_user_ids

## setScreenName

Set the name of the current screen in Analytics:
```
window.FirebasePlugin.setScreenName("Home");
```

## setUserId

Set a user id for use in Analytics:
```
window.FirebasePlugin.setUserId("user_id");
```

## setUserProperty

Set a user property for use in Analytics:
```
window.FirebasePlugin.setUserProperty("name", "value");
```

## verifyPhoneNumber

Request a verification ID and send a SMS with a verification code. Use them to construct a credential to sign in the user (in your app).
- https://firebase.google.com/docs/auth/android/phone-auth
- https://firebase.google.com/docs/reference/js/firebase.auth.Auth#signInWithCredential
- https://firebase.google.com/docs/reference/js/firebase.User#linkWithCredential

**NOTE: This will only work on physical devices.**

iOS will return: credential (string)
Android will return:
credential.verificationId (object and with key verificationId)
credential.instantVerification (boolean)
credential.code (string) (note that this key only exists if instantVerification is true)

You need to use device plugin in order to access the right key.

IMPORTANT NOTE: Android supports auto-verify and instant device verification. Therefore in that case it doesn't make sense to ask for an sms code as you won't receive one. In this case you'll get a credential.verificationId and a credential.code where code is the auto received verification code that would normally be sent via sms. To log in using this procedure you must pass this code to PhoneAuthProvider.credential(verificationId, code). You'll find an implementation example further below.

When using node.js Firebase Admin-SDK, follow this tutorial:
- https://firebase.google.com/docs/auth/admin/create-custom-tokens

Pass back your custom generated token and call
```js
firebase.auth().signInWithCustomToken(customTokenFromYourServer);
```
instead of
```
firebase.auth().signInWithCredential(credential)
```
**YOU HAVE TO COVER THIS PROCESS, OR YOU WILL HAVE ABOUT 5% OF USERS STICKING ON YOUR SCREEN, NOT RECEIVING ANYTHING**
If this process is too complex for you, use this awesome plugin
- https://github.com/chemerisuk/cordova-plugin-firebase-authentication

It's not perfect but it fits for the most use cases and doesn't require calling your endpoint, as it has native phone auth support.

```
window.FirebasePlugin.verifyPhoneNumber(number, timeOutDuration, function(credential) {
    console.log(credential);

    // if instant verification is true use the code that we received from the firebase endpoint, otherwise ask user to input verificationCode:
    var code = credential.instantVerification ? credential.code : inputField.value.toString();

    var verificationId = credential.verificationId;

    var credential = firebase.auth.PhoneAuthProvider.credential(verificationId, code);

    // sign in with the credential
    firebase.auth().signInWithCredential(credential);

    // OR link to an account
    firebase.auth().currentUser.linkWithCredential(credential)
}, function(error) {
    console.error(error);
});
```


### Android
To use this auth you need to configure your app SHA hash in the android app configuration in the firebase console.
See https://developers.google.com/android/guides/client-auth to know how to get SHA app hash.

### iOS
Setup your push notifications first, and verify that they are arriving on your physical device before you test this method. Use the APNs auth key to generate the .p8 file and upload it to firebase.  When you call this method, FCM sends a silent push to the device to verify it.

## fetch

Fetch Remote Config parameter values for your app:
```
window.FirebasePlugin.fetch(function () {
    // success callback
}, function () {
    // error callback
});
// or, specify the cacheExpirationSeconds
window.FirebasePlugin.fetch(600, function () {
    // success callback
}, function () {
    // error callback
});
```

## activateFetched

Activate the Remote Config fetched config:
```
window.FirebasePlugin.activateFetched(function(activated) {
    // activated will be true if there was a fetched config activated,
    // or false if no fetched config was found, or the fetched config was already activated.
    console.log(activated);
}, function(error) {
    console.error(error);
});
```

## getValue

Retrieve a Remote Config value:
```
window.FirebasePlugin.getValue("key", function(value) {
    console.log(value);
}, function(error) {
    console.error(error);
});
```

## getByteArray (Android only)
**NOTE: byte array is only available for SDK 19+**
Retrieve a Remote Config byte array:
```
window.FirebasePlugin.getByteArray("key", function(bytes) {
    // a Base64 encoded string that represents the value for "key"
    console.log(bytes.base64);
    // a numeric array containing the values of the byte array (i.e. [0xFF, 0x00])
    console.log(bytes.array);
}, function(error) {
    console.error(error);
});
```

## getInfo (Android only)

Get the current state of the FirebaseRemoteConfig singleton object:
```
window.FirebasePlugin.getInfo(function(info) {
    // the status of the developer mode setting (true/false)
    console.log(info.configSettings.developerModeEnabled);
    // the timestamp (milliseconds since epoch) of the last successful fetch
    console.log(info.fetchTimeMillis);
    // the status of the most recent fetch attempt (int)
    // 0 = Config has never been fetched.
    // 1 = Config fetch succeeded.
    // 2 = Config fetch failed.
    // 3 = Config fetch was throttled.
    console.log(info.lastFetchStatus);
}, function(error) {
    console.error(error);
});
```

## setConfigSettings (Android only)

Change the settings for the FirebaseRemoteConfig object's operations:
```
var settings = {
    developerModeEnabled: true
}
window.FirebasePlugin.setConfigSettings(settings);
```

## setDefaults (Android only)

Set defaults in the Remote Config:
```
// define defaults
var defaults = {
    // map property name to value in Remote Config defaults
    mLong: 1000,
    mString: 'hello world',
    mDouble: 3.14,
    mBoolean: true,
    // map "mBase64" to a Remote Config byte array represented by a Base64 string
    // Note: the Base64 string is in an array in order to differentiate from a string config value
    mBase64: ["SGVsbG8gV29ybGQ="],
    // map "mBytes" to a Remote Config byte array represented by a numeric array
    mBytes: [0xFF, 0x00]
}
// set defaults
window.FirebasePlugin.setDefaults(defaults);
```

## startTrace

Start a trace.

```
window.FirebasePlugin.startTrace("test trace", success, error);
```

## incrementCounter

To count the performance-related events that occur in your app (such as cache hits or retries), add a line of code similar to the following whenever the event occurs, using a string other than retry to name that event if you are counting a different type of event:

```
window.FirebasePlugin.incrementCounter("test trace", "retry", success, error);
```

## stopTrace

Stop the trace

```
window.FirebasePlugin.stopTrace("test trace");
```

## setAnalyticsCollectionEnabled

Enable/disable analytics collection

```
window.FirebasePlugin.setAnalyticsCollectionEnabled(true); // Enables analytics collection

window.FirebasePlugin.setAnalyticsCollectionEnabled(false); // Disables analytics collection
```

## sendCrash

Simulates (causes) a fatal native crash.

```javascript
window.FirebasePlugin.logMessage("about to send a crash for testing!");
window.FirebasePlugin.sendCrash();
```


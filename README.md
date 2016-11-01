# cordova-plugin-firebase
This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!
Android and iOS supported (including iOS 10).

## Installation
See npm package for versions - https://www.npmjs.com/package/cordova-plugin-firebase

Install the plugin by adding it your project's config.xml:
```
<plugin name="cordova-plugin-firebase" spec="0.1.18" />
```
or by running:
```
cordova plugin add cordova-plugin-firebase@0.1.18 --save
```
Download your Firebase configuration files, GoogleService-Info.plist for ios and google-services.json for android, and place them in the root folder of your cordova project:

```
- My Project/
    platforms/
    plugins/
    www/
    config.xml
    google-services.json       <--
    GoogleService-Info.plist   <--
    ...
```

See https://support.google.com/firebase/answer/7015592 for details how to download the files from firebase.

This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely platforms/ios/\<My Project\>/Resources for ios and platforms/android for android.

**Note that the Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.**

### Notes about PhoneGap Build

Hooks does not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see src/ios and src/android) with your actual ones.


## Methods

### getToken

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

### onTokenRefresh

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

### onNotificationOpen

Register notification callback:
```
window.FirebasePlugin.onNotificationOpen(function(notification) {
    console.error(notification);
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

The plugin will look for and use notification_icon in drawable resources if it exists, otherwise the default app icon will is used. 

### grantPermission (iOS only)

Grant permission to recieve push notifications (will trigger prompt):
```
window.FirebasePlugin.grantPermission();
```

### setBadgeNumber

Set a number on the icon badge:
```
window.FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge
```
window.FirebasePlugin.setBadgeNumber(0);
```

### getBadgeNumber

Get icon badge number:
```
window.FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

### subscribe

Subscribe to a topic:
```
window.FirebasePlugin.subscribe("example");
```

### unsubscribe

Unsubscribe from a topic:
```
window.FirebasePlugin.unsubscribe("example");
```

### logEvent

Log an event using Analytics:
```
window.FirebasePlugin.logEvent("page_view", {page: "dashboard"});
```

### setUserId

Set a user id for use in Analytics:
```
window.FirebasePlugin.setUserId("user_id");
```

### setUserProperty

Set a user property for use in Analytics:
```
window.FirebasePlugin.setUserProperty("name", "value");
```

### fetch (Android only)

Fetch Remote Config parameter values for your app:
```
window.FirebasePlugin.fetch();
// or, specify the cacheExpirationSeconds
window.FirebasePlugin.fetch(600);
```

### activateFetched (Android only)

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

### getValue (Android only)

Retrieve a Remote Config value:
```
window.FirebasePlugin.getValue("key", function(value) {
    console.log(value);
}, function(error) {
    console.error(error);
});
// or, specify a namespace for the config value
window.FirebasePlugin.getValue("key", "namespace", function(value) {
    console.log(value);
}, function(error) {
    console.error(error);
});
```

### getByteArray (Android only)
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
// or, specify a namespace for the byte array
window.FirebasePlugin.getByteArray("key", "namespace", function(bytes) {
    // a Base64 encoded string that represents the value for "key"
    console.log(bytes.base64);
    // a numeric array containing the values of the byte array (i.e. [0xFF, 0x00])
    console.log(bytes.array);
}, function(error) {
    console.error(error);
});
```

### getInfo (Android only)

Get the current state of the FirebaseRemoteConfig singleton object:
```
window.FirebasePlugin.getInfo(function(info) {
    // the status of the developer mode setting (true/false)
    console.log(info.configSettings.developerModeEnabled);
    // the timestamp (milliseconds since epoch) of the last successful fetch
    console.log(info.fetchTimeMillis);
    // the status of the most recent fetch attempt (int)
    console.log(info.lastFetchStatus);
}, function(error) {
    console.error(error);
});
```

### setConfigSettings (Android only)

Change the settings for the FirebaseRemoteConfig object's operations:
```
var settings = {
    developerModeEnabled: true
}
window.FirebasePlugin.setConfigSettings(settings);
```

### setDefaults (Android only)

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
// or, specify a namespace
window.FirebasePlugin.setDefaults(defaults, "namespace");
```

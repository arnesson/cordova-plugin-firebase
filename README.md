# cordova-plugin-firebase
This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!
Android and iOS supported.

Donations are welcome and will go towards further development of this project. Use the wallet address below to donate.

BTC: 1JuXhHMCPHXT2fDfSRUTef9TpE2D67sc9f

Thank you for your support!

## in this fork
### verifyPhoneNumber (Android only)

Request a verificationId and send a SMS with a verificatioCode.
Use them to construct a credenial to sign in the user (in your app).
https://firebase.google.com/docs/auth/android/phone-auth
https://firebase.google.com/docs/reference/js/firebase.auth.Auth#signInWithCredential

NOTE: To use this auth you need to configure your app SHA hash in the android app configuration on firebase console.
See https://developers.google.com/android/guides/client-auth to know how to get SHA app hash.

NOTE: This will only works on physical devices.

```
window.FirebasePlugin.verifyPhoneNumber(number, timeOutDuration, function(credential) {
    console.log(credential);

    // ask user to input verificationCode:
    var code = inputField.value.toString();

    var verificationId = credential.verificationId;
    
    var signInCredential = firebase.auth.PhoneAuthProvider.credential(verificationId, code);
    firebase.auth().signInWithCredential(signInCredential);
}, function(error) {
    console.error(error);
});
```

## Installation
See npm package for versions - https://www.npmjs.com/package/cordova-plugin-firebase

Install the plugin by adding it your project's config.xml:
```
<plugin name="cordova-plugin-firebase" spec="0.1.25" />
```
or by running:
```
cordova plugin add cordova-plugin-firebase@0.1.25 --save
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

## Google Tag Manager
### Android
Download your container-config json file from Tag Manager and add a resource-file node in your config.xml.
```
....
<platform name="android">
        <content src="index.html" />
        <resource-file src="GTM-5MFXXXX.json" target="assets/containers/GTM-5MFXXXX.json" />
        ...
```

## Changing Notification Icon
The plugin will use notification_icon from drawable resources if it exists, otherwise the default app icon will is used.
To set a big icon and small icon for notifications, define them through drawable nodes.  
Create the required styles.xml files and add the icons to the  
`<projectroot>/res/native/android/res/<drawable-DPI>` folders.  

The example below uses a png named "ic_silhouette.png", the app Icon (@mipmap/icon) and sets a base theme.  
From android version 21 (Lollipop) notifications were changed, needing a seperate setting.  
If you only target Lollipop and above, you don't need to setup both.  
Thankfully using the version dependant asset selections, we can make one build/apk supporting all target platforms.  
`<projectroot>/res/native/android/res/values/styles.xml`
```
<?xml version="1.0" encoding="utf-8" ?>
<resources>
    <!-- inherit from the holo theme -->
    <style name="AppTheme" parent="android:Theme.Light">
        <item name="android:windowDisablePreview">true</item>
    </style>
    <drawable name="notification_big">@mipmap/icon</drawable>
    <drawable name="notification_icon">@mipmap/icon</drawable>
</resources>
```
and  
`<projectroot>/res/native/android/res/values-v21/styles.xml`
```
<?xml version="1.0" encoding="utf-8" ?>
<resources>
    <!-- inherit from the material theme -->
    <style name="AppTheme" parent="android:Theme.Material">
        <item name="android:windowDisablePreview">true</item>
    </style>
    <drawable name="notification_big">@mipmap/icon</drawable>
    <drawable name="notification_icon">@drawable/ic_silhouette</drawable>
</resources>
```

## Notification Colors

On Android Lollipop and above you can also set the accent color for the notification by adding a color setting.

`<projectroot>/res/native/android/res/values/colors.xml`
```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#FFFFFF00</color>
    <color name="primary_dark">#FF220022</color>
    <color name="accent">#FF00FFFF</color>
</resources>
```


### Notes about PhoneGap Build

Hooks does not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see src/ios and src/android) with your actual ones, as well as hard coding your app id and api key in plugin.xml.


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

[Changing notification icon](#changing-notification-icon)

### grantPermission (iOS only)

Grant permission to recieve push notifications (will trigger prompt):
```
window.FirebasePlugin.grantPermission();
```
### hasPermission

Check permission to recieve push notifications:
```
window.FirebasePlugin.hasPermission(function(data){
    console.log(data.isEnabled);
});
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

### unregister

Unregister from firebase, used to stop receiving push notifications. Call this when you logout user from your app. :
```
window.FirebasePlugin.unregister();
```

### logEvent

Log an event using Analytics:
```
window.FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

### setScreenName

Set the name of the current screen in Analytics:
```
window.FirebasePlugin.setScreenName("Home");
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

### fetch

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

### activateFetched

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

### getValue

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

### Phone Authentication
**BASED ON THE CONTRIBUTIONS OF**
IOS 
https://github.com/silverio/cordova-plugin-firebase

ANDROID 
https://github.com/apptum/cordova-plugin-firebase

**((((IOS))): SETUP YOUR PUSH NOTIFICATIONS FIRST, AND VERIFY THAT THEY ARE ARRIVING TO YOUR PHYSICAL DEVICE BEFORE YOU TEST THIS METHOD. USE THE APNS AUTH KEY TO GENERATE THE .P8 FILE AND UPLOAD IT TO FIREBASE.
WHEN YOU CALL THIS METHOD, FCM SENDS A SILENT PUSH TO THE DEVICE TO VERIFY IT.**

This method sends an SMS to the user with the SMS_code and gets the verification id you need to continue the sign in process, with the Firebase JS SDK.

```
window.FirebasePlugin.getVerificationID("+573123456789",function(id) {
                console.log("verificationID: "+id);
                
            }, function(error) {             
                console.error(error);
            });
```

Using Ionic2?
```
  (<any>window).FirebasePlugin.getVerificationID("+573123456789", id => {
          console.log("verificationID: " + id);
          this.verificationId = id;
        }, error => {
          console.log("error: " + error);
        });
```
Get the intermediate AuthCredential object
```
var credential = firebase.auth.PhoneAuthProvider.credential(verificationId, SMS_code);
```
Then, you can sign in the user with the credential:
```
firebase.auth().signInWithCredential(credential);
```
Or link to an account
```
firebase.auth().currentUser.linkWithCredential(credential)
```

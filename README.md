# cordova-plugin-firebase
This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!
Android and iOS supported.

Donations are welcome and will go towards further development of this project. Use the wallet address below to donate.

BTC: 1JuXhHMCPHXT2fDfSRUTef9TpE2D67sc9f

Thank you for your support!

# :books: Contents
- [Installation](#installation)
    + [Firebase Configuration Files](#firebase-configuration-files)
    + [iOS Setup](#ios-setup)
    + [Android Setup](#android-setup)
- [Using the plugin](#using-the-plugin)
- [API Documentation](#api-documentation)
    + [Common Methods](#common-methods)
    + [iOS Methods](#ios-methods)
    + [Android Methods](#android-methods)
    + [Phone Authentication](#phone-authentication)

## Installation

See npm package for versions - https://www.npmjs.com/package/cordova-plugin-firebase

Install the plugin in shell:

```bash
cordova plugin add cordova-plugin-firebase

```

Or add it manually to your `config.xml`
```xml
<plugin name="cordova-plugin-firebase" spec="../cordova-plugin-firebase">
    <variable name="GOOGLE_API_VERSION" value="11.6.0" />
</plugin>
```

### Firebase Configuration Files

Download your Firebase configuration files from [Firebase Console](https://console.firebase.google.com) (see [here](https://support.google.com/firebase/answer/7015592) for help finding and downloading these files):
- **`google-services.json`** &mdash; android,
- **`GoogleService-Info.plist`** &mdash; ios

Place these files in the root folder of your cordova project:

:exclamation: Note: that the Firebase SDK *requires* the configuration files above to be present and valid, otherwise your app **will crash** on boot or Firebase features won't work.

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

In the platform tag for Android, add the following **`<resource-file />`** element:

```xml
<platform name="android">
  <resource-file src="google-services.json" target="google-services.json" />
</platform>
```

**[Optional]** By default, on iOS, the plugin will register with APNS. **If you want to use FCM on iOS**, add the following `<resource-file />` element within the ios `<platform>`

```xml
<platform name="ios">
  <resource-file src="GoogleService-Info.plist" />
</platform>
```

:warning: Note: if you are using Ionic you may need to specify the SENDER_ID variable in your package.json.

## iOS Setup

Xcode version 9.0 or greater is required for building this plugin.

### CocoaPods

:warning: Since this plugin uses Cocoapods to install its Firebase dependencies, you must open the **`YourProject.xcworkspace`** from now on &mdash; **not** `YourProject.xcodeproj`.

To install CocoaPods, please follow the installation instructions [here](https://guides.cocoapods.org/using/getting-started). After installing CocoaPods, please run:

```bash
$ pod setup
```

This will clone the required CocoaPods specs-repo into your home folder at `~/.cocoapods/repos`, so it might take a while. See the [CocoaPod Disk Space](#cocoapod-disk-space) section below for more information.

Version `0.2.0` (and above) of this plugin supports [CocoaPods](https://cocoapods.org) installation of the [Firebase Cloud Messaging](https://cocoapods.org/pods/FirebaseMessaging) library.

### Common CocoaPod Installation issues

If you are attempting to install this plugin and you run into this error:

```
Installing "cordova-plugin-firebase" for ios
Failed to install 'cordova-plugin-firebase':Error: pod: Command failed with exit code 1
    at ChildProcess.whenDone (/Users/smacdona/code/push151/platforms/ios/cordova/node_modules/cordova-common/src/superspawn.js:169:23)
    at emitTwo (events.js:87:13)
    at ChildProcess.emit (events.js:172:7)
    at maybeClose (internal/child_process.js:818:16)
    at Process.ChildProcess._handle.onexit (internal/child_process.js:211:5)
Error: pod: Command failed with exit code 1
```

Please run the command `pod repo update` and re-install the plugin. You would only run `pod repo update` if you have the specs-repo already cloned on your machine through `pod setup`.

#### CocoaPod Disk Space

Running `pod setup` can take over 1 GB of disk space and that can take quite some time to download over a slow internet connection. If you are having issues with disk space/network try this neat hack from @VinceOPS.

```
git clone --verbose --depth=1 https://github.com/CocoaPods/Specs.git ~/.cocoapods/repos/master
pod setup --verbose
```

#### `Library not found for -lPods-Appname`

If you open the app in Xcode and you get an error like:

```
ld: library not found for -lPods-Appname
clang: error: linker command failed with exit code 1
```

Then you are opening the **`YourProject.xcodeproj`** file when you should be opening the **`YourProject.xcworkspace`** file.

#### `Library not found for -lGoogleToolboxForMac`

Trying to build for iOS using the latest cocoapods (1.2.1) but failed with the following error (from terminal running cordova build ios):

```
ld: library not found for -lGoogleToolboxForMac
```

Workarounds are to add the platform first and install the plugins later, or to manually run pod install on projectName/platforms/ios.

#### `Module FirebaseInstanceID not found`

If you run into an error like:

```
module FirebaseInstanceID not found
```

You may be running into a bug in cordova-ios. The current workaround is to run `pod install` manually.

```
cd platforms/ios
pod install
```

## Android Setup

As of version `0.2.0`, the plugin has been switched to using pinned versions of `firebase` libraries. You will need to ensure that you have installed the following items through the Android SDK Manager:

- Android Support Repository version 47+

![android support library](https://user-images.githubusercontent.com/353180/33042340-7ea60aaa-ce0f-11e7-99f7-4631e4c3d7be.png)

For more detailed instructions on how to install the Android Support Library visit [Google's documentation](https://developer.android.com/tools/support-library/setup.html).

### `GOOGLE_API_VERSION`

In order to align the version of `firebase` / `play-services` dependencies with *other* plugins, this plugin exposes a `<variable name="GOOGLE_API_VERSION" />` in your `config.xml`.  You can configure the version by providing this `--variable` when installing the plugin:

```bash
$ cordova plugin add cordova-plugin-firebase --variable GOOGLE_API_VERSION=11.6.0
```

### Google Tag Manager

Download your container-config json file from Tag Manager and add a `<resource-file />` node in your config.xml:

```xml
    <platform name="android">
        <resource-file src="GTM-5MFXXXX.json" target="assets/containers/GTM-5MFXXXX.json" />
        .
        .
        .
    </platform>

```

### Changing Notification Icon
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

### Notification Colors

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


## Using the plugin

The plugin creates the object **`window.FirebasePlugin`**.  See [API Documentation](#api-documentation) for details

### Ionic 2+ and Typescript

```javascript
platform.ready().then(() => {
  let FirebasePlugin = (<any>window).FirebasePlugin;
});
```


## API Documentation


### Common Methods

| Method Name      | Arguments       | Notes                                |
|------------------|-----------------|--------------------------------------|
| [`getToken`](#gettokensuccessfn-failurefn) | `successFn`,`failureFn` | Retrieve the device token (id). |
| [`onTokenRefresh`](#ontokenrefreshsuccessfn-failurefn) | `successFn`,`failureFn` | Register for token changes. |
| [`onNotificationOpen`](#onnotificationopensuccessfn-failurefn) | `successFn`,`failureFn` | Register notification callback. |
| [`hasPermission`](#haspermissioncallbackfn) | `callbackFn`| Check permission to recieve push notifications. |
| [`setBadgeNumber`](#setbadgenumbernumber) | `number`| Set a number on the icon badge.|
| [`getBadgeNumber`](#getbadgenumbercallbackfn) | `callbackFn` | Get icon badge number. |
| [`subscribe`](#subscribetopic) | `topic`| Subscribe to a topic. |
| [`unsubscribe`](#unsubscribetopic) | `topic`| Un-subscribe from a topic. |
| [`unregister`](#unregister) | | Unregister from firebase, used to stop receiving push notifications. Call this when you logout user from your app. |
| [`logEvent`](#logeventname-data) | `name`,`data`| Log an event using Analytics. |
| [`setScreenName`](#setscreennamename) | `name` | Set the name of the current screen in Analytics. |
| [`setUserId`](#setuseriduserid) | `userId`| Set a user id for use in Analytics. |
| [`setUserProperty`](#setuserpropertykey-value) | `key`,`value` | Set a user property for use in Analytics. |
| [`fetch`](#fetchsuccessfn-failurefn) | `successFn`,`failureFn` | Fetch Remote Config parameter values for your app. |
| [`activateFetched`](#activatefetchedsuccessfn-failurefn) | `successFn`,`failureFn` | Activate the Remote Config fetched config. |
| [`getValue`](#getvaluesuccessfn-failurefn) | `successFn`,`failureFn` | Retrieve a Remote Config value. |


### iOS Methods

| Method Name      | Arguments       | Notes                                |
|------------------|-----------------|--------------------------------------|
| [`grantPermission`](#grantpermission) |  | Grant permission to recieve push notifications (will trigger prompt).|


### Android Methods

| Method Name      | Arguments       | Notes                                |
|------------------|-----------------|--------------------------------------|
| [`verifyPhoneNumber`](#verifyphonenumbernumber-timeout-successfn-failurefn) | `number`, `timeout`, `successFn`,`failureFn` | Request a verificationId and send a SMS with a verificationCode. Use them to construct a credenial to sign in the user (in your app). |
| [`getByteArray`](#getbytearraykey-successfn-failurefn) | `key`,`successFn`, `failureFn` | Retrieve a Remote Config byte array. |
| [`getInfo`](#getinfosuccessfn-failurefn) | `successFn`,`failureFn` | Get the current state of the FirebaseRemoteConfig singleton object. |
| [`setConfigSettings`](#setconfigsettingssettings) | `settings` | Change the settings for the FirebaseRemoteConfig object's operations. |
| [`setDefaults`](#setdefaultssettings) | `settings` | Set defaults in the Remote Config. |


## Common Methods

#### `getToken(successFn, failureFn)`

Get the device token (id):

```javascript
window.FirebasePlugin.getToken(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet

-------------------------------------------------------------------------------

#### `onTokenRefresh(successFn, failureFn)`

Register for token changes:

```javascript
window.FirebasePlugin.onTokenRefresh(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```

:information:source: This is the best way to get a valid token for the device as soon as the token is established

-------------------------------------------------------------------------------

#### `onNotificationOpen(successFn, failureFn)`

Register notification callback:

```javascript
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

-------------------------------------------------------------------------------

#### `hasPermission(callbackFn)`

Check permission to recieve push notifications:

```javascript
window.FirebasePlugin.hasPermission(function(data){
    console.log(data.isEnabled);
});
```

-------------------------------------------------------------------------------

#### `setBadgeNumber(Number)`

Set a number on the icon badge:

```javascript
window.FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge:

```javascript
window.FirebasePlugin.setBadgeNumber(0);
```

-------------------------------------------------------------------------------

#### `getBadgeNumber(callbackFn)`

Get icon badge number:

```javascript
window.FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

-------------------------------------------------------------------------------

#### `subscribe(topic)`

Subscribe to a topic:

```javascript
window.FirebasePlugin.subscribe("example");
```

-------------------------------------------------------------------------------

#### `unsubscribe(topic)`

Unsubscribe from a topic:

```javascript
window.FirebasePlugin.unsubscribe("example");
```

-------------------------------------------------------------------------------

#### `unregister`

Unregister from firebase, used to stop receiving push notifications. Call this when you logout user from your app:

```javascript
window.FirebasePlugin.unregister();
```

-------------------------------------------------------------------------------

#### `logEvent(name, data)`

Log an event using Analytics:

```javascript
window.FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

-------------------------------------------------------------------------------

#### `setScreenName(name)`

Set the name of the current screen in Analytics:

```javascript
window.FirebasePlugin.setScreenName("Home");
```

-------------------------------------------------------------------------------

#### `setUserId(userId)`

Set a user id for use in Analytics:

```javascript
window.FirebasePlugin.setUserId("user_id");
```

-------------------------------------------------------------------------------

#### `setUserProperty(key, value)`

Set a user property for use in Analytics:

```javascript
window.FirebasePlugin.setUserProperty("name", "value");
```

-------------------------------------------------------------------------------

#### `fetch(successFn, failureFn)`

Fetch Remote Config parameter values for your app:

```javascript
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

-------------------------------------------------------------------------------

#### `activateFetched(successFn, failureFn)`

Activate the Remote Config fetched config:

```javascript
window.FirebasePlugin.activateFetched(function(activated) {
    // activated will be true if there was a fetched config activated,
    // or false if no fetched config was found, or the fetched config was already activated.
    console.log(activated);
}, function(error) {
    console.error(error);
});
```

-------------------------------------------------------------------------------

#### `getValue(successFn, failureFn)`

Retrieve a Remote Config value:

```javascript
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


## iOS Methods

#### `grantPermission`

Grant permission to recieve push notifications (will trigger prompt):

```javascript
window.FirebasePlugin.grantPermission();
```

-------------------------------------------------------------------------------

## Android Methods

#### `verifyPhoneNumber(number, timeout, successFn, failureFn)`

Request a verificationId and send a SMS with a verificationCode.
Use them to construct a credenial to sign in the user (in your app).

See [Firebase docs](https://firebase.google.com/docs/auth/android/phone-auth
https://firebase.google.com/docs/reference/js/firebase.auth.Auth#signInWithCredential)

:warning: NOTE: To use this auth you need to configure your app SHA hash in the android app configuration on firebase console.
See [here](https://developers.google.com/android/guides/client-auth) to learn how to get SHA app hash.

:warning NOTE: This will only works on physical devices.

```javascript
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

-------------------------------------------------------------------------------

#### `getByteArray(key, successFn, failureFn`

:warning: Byte array is only available for SDK 19+

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

-------------------------------------------------------------------------------

#### `getInfo(successFn, failureFn)`

Get the current state of the FirebaseRemoteConfig singleton object:

```javascript
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

-------------------------------------------------------------------------------

#### `setConfigSettings(settings)`

Change the settings for the FirebaseRemoteConfig object's operations:

```javascript
var settings = {
    developerModeEnabled: true
}
window.FirebasePlugin.setConfigSettings(settings);
```

-------------------------------------------------------------------------------

#### `setDefaults(settings)`

Set defaults in the Remote Config:

```javascript
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

-------------------------------------------------------------------------------

## Phone Authentication

**BASED ON THE CONTRIBUTIONS OF**
IOS
https://github.com/silverio/cordova-plugin-firebase

ANDROID
https://github.com/apptum/cordova-plugin-firebase

**((((IOS))): SETUP YOUR PUSH NOTIFICATIONS FIRST, AND VERIFY THAT THEY ARE ARRIVING TO YOUR PHYSICAL DEVICE BEFORE YOU TEST THIS METHOD. USE THE APNS AUTH KEY TO GENERATE THE .P8 FILE AND UPLOAD IT TO FIREBASE.
WHEN YOU CALL THIS METHOD, FCM SENDS A SILENT PUSH TO THE DEVICE TO VERIFY IT.**

This method sends an SMS to the user with the SMS_code and gets the verification id you need to continue the sign in process, with the Firebase JS SDK.

```javascript
window.FirebasePlugin.getVerificationID("+573123456789",function(id) {
    console.log("verificationID: "+id);
}, function(error) {
    console.error(error);
});
```

Using Ionic2?
```javascript
(<any>window).FirebasePlugin.getVerificationID("+573123456789", id => {
    console.log("verificationID: " + id);
    this.verificationId = id;
}, error => {
    console.log("error: " + error);
});
```

Get the intermediate AuthCredential object

```javascript
var credential = firebase.auth.PhoneAuthProvider.credential(verificationId, SMS_code);
```

Then, you can sign in the user with the credential:

```javascript
firebase.auth().signInWithCredential(credential);
```

Or link to an account
```javascript
firebase.auth().currentUser.linkWithCredential(credential)
```

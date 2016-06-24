# cordova-plugin-firebase
Cordova plugin for Google Firebase

This plugin is under development! The primary goal for this plugin is to implement FCM for cross platform push notifications. Other parts of the SDK will follow later.

Angular implementation is maintained in the [angular-cordova](https://github.com/arnesson/angular-cordova) project ([source](https://github.com/arnesson/angular-cordova/blob/master/src/plugins/3rdparty/firebase.js))

## Installation

1. Ensure you have the latest version of the Android Support Repositry installed.
2. Install plugin using the following command:
`cordova plugin add https://github.com/arnesson/cordova-plugin-firebase.git --variable AD_UNIT_ID_FOR_BANNER_TEST="toBeFilledInLater" --variable AD_UNIT_ID_FOR_INTERSTITIAL_TEST="toBeFilledInLater" --variable CLIENT_ID="toBeFilledInLater" --variable REVERSED_CLIENT_ID="toBeFilledInLater" --variable API_KEY="toBeFilledInLater" --variable GCM_SENDER_ID="toBeFilledInLater" --variable BUNDLE_ID="toBeFilledInLater" --variable PROJECT_ID="toBeFilledInLater" --variable STORAGE_BUCKET="toBeFilledInLater" --variable GOOGLE_APP_ID="toBeFilledInLater" --variable DATABASE_URL="toBeFilledInLater" --save`

3. Add and configure the plugin in your app's config.xml, see sample below. You can get the values needed by downloading your project's config file from the Firebase Console, see https://support.google.com/firebase/answer/7015592.
```
<plugin name="cordova-plugin-firebase" spec="https://github.com/arnesson/cordova-plugin-firebase">
    <variable name="AD_UNIT_ID_FOR_BANNER_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="AD_UNIT_ID_FOR_INTERSTITIAL_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="CLIENT_ID" value="123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com" />
    <variable name="REVERSED_CLIENT_ID" value="com.googleusercontent.apps.123456789012-abcdefghijklmnopqrstuvwxyz123456" />
    <variable name="API_KEY" value="abcdefghijklmnopqrstuvwxyz1234-abcdefgh" />
    <variable name="GCM_SENDER_ID" value="123456789012" />
    <variable name="BUNDLE_ID" value="my.bundle.id" />
    <variable name="PROJECT_ID" value="project-id" />
    <variable name="STORAGE_BUCKET" value="project-id.appspot.com" />
    <variable name="IS_ADS_ENABLED" value="true" />
    <variable name="IS_ANALYTICS_ENABLED" value="false" />
    <variable name="IS_APPINVITE_ENABLED" value="false" />
    <variable name="IS_GCM_ENABLED" value="true" />
    <variable name="IS_SIGNIN_ENABLED" value="true" />
    <variable name="GOOGLE_APP_ID" value="1:123456789012:ios:abcdefghijklmnop" />
    <variable name="DATABASE_URL" value="https://project-id.firebaseio.com" />
</plugin>
```

Run cordova prepare

## Methods

### getRegistrationId

Get the device id (token)
```
window.FirebasePlugin.getRegistrationId(function(token) {
    // save this in your backend and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```

### startAnalytics

Starts Firebase Analytics
```
window.FirebasePlugin.startAnalytics({
    console.log("Firebase analytics started");
}, function(error) {
    console.error("Firebase analytics not started.");
});
```

### logEvent

Log an event
```
window.FirebasePlugin.logEvent("pageLoad", "Dashboard");
```

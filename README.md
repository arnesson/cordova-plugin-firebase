# cordova-plugin-firebase
Cordova plugin for Google Firebase

This plugin is under development!

Angular implementation is maintained in the [angular-cordova](https://github.com/arnesson/angular-cordova) project ([source](https://github.com/arnesson/angular-cordova/blob/master/src/plugins/3rdparty/firebase.js))

## Installation

1. Ensure you have the latest version of the Android Support Repositry installed.
2. Install plugin using the following command:
`cordova plugin add https://github.com/arnesson/cordova-plugin-firebase.git --variable ANDROID_AD_UNIT_ID_FOR_BANNER_TEST="toBeFilledInLater" --variable ANDROID_AD_UNIT_ID_FOR_INTERSTITIAL_TEST="toBeFilledInLater" --variable ANDROID_CLIENT_ID="toBeFilledInLater" --variable ANDROID_REVERSED_CLIENT_ID="toBeFilledInLater" --variable ANDROID_API_KEY="toBeFilledInLater" --variable ANDROID_GCM_SENDER_ID="toBeFilledInLater" --variable ANDROID_BUNDLE_ID="toBeFilledInLater" --variable ANDROID_PROJECT_ID="toBeFilledInLater" --variable ANDROID_STORAGE_BUCKET="toBeFilledInLater" --variable ANDROID_GOOGLE_APP_ID="toBeFilledInLater" --variable ANDROID_DATABASE_URL="toBeFilledInLater" --variable IOS_AD_UNIT_ID_FOR_BANNER_TEST="toBeFilledInLater" --variable IOS_AD_UNIT_ID_FOR_INTERSTITIAL_TEST="toBeFilledInLater" --variable IOS_CLIENT_ID="toBeFilledInLater" --variable IOS_REVERSED_CLIENT_ID="toBeFilledInLater" --variable IOS_API_KEY="toBeFilledInLater" --variable IOS_GCM_SENDER_ID="toBeFilledInLater" --variable IOS_BUNDLE_ID="toBeFilledInLater" --variable IOS_PROJECT_ID="toBeFilledInLater" --variable IOS_STORAGE_BUCKET="toBeFilledInLater" --variable IOS_GOOGLE_APP_ID="toBeFilledInLater" --variable IOS_DATABASE_URL="toBeFilledInLater"`

3. Add and configure the plugin in your app's config.xml, see sample below. <b>Please note and Android and iOS have unique values for each app.</b> You can get the values needed by downloading your project's config file from the Firebase Console, see https://support.google.com/firebase/answer/7015592.
```
<plugin name="cordova-plugin-firebase" spec="https://github.com/arnesson/cordova-plugin-firebase">
    <variable name="ANROID_AD_UNIT_ID_FOR_BANNER_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="ANROID_AD_UNIT_ID_FOR_INTERSTITIAL_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="ANROID_CLIENT_ID" value="123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com" />
    <variable name="ANROID_REVERSED_CLIENT_ID" value="com.googleusercontent.apps.123456789012-abcdefghijklmnopqrstuvwxyz123456" />
    <variable name="ANROID_API_KEY" value="abcdefghijklmnopqrstuvwxyz1234-abcdefgh" />
    <variable name="ANROID_GCM_SENDER_ID" value="123456789012" />
    <variable name="ANROID_BUNDLE_ID" value="my.bundle.id" />
    <variable name="ANROID_PROJECT_ID" value="project-id" />
    <variable name="ANROID_STORAGE_BUCKET" value="project-id.appspot.com" />
    <variable name="ANROID_IS_ADS_ENABLED" value="true" />
    <variable name="ANROID_IS_ANALYTICS_ENABLED" value="false" />
    <variable name="ANROID_IS_APPINVITE_ENABLED" value="false" />
    <variable name="ANROID_IS_GCM_ENABLED" value="true" />
    <variable name="ANROID_IS_SIGNIN_ENABLED" value="true" />
    <variable name="ANROID_GOOGLE_APP_ID" value="1:123456789012:android:abcdefghijklmnop" />
    <variable name="ANROID_DATABASE_URL" value="https://project-id.firebaseio.com" />
    <variable name="IOS_AD_UNIT_ID_FOR_BANNER_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="IOS_AD_UNIT_ID_FOR_INTERSTITIAL_TEST" value="ca-app-pub-1234567890123456/1234567890" />
    <variable name="IOS_CLIENT_ID" value="123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com" />
    <variable name="IOS_REVERSED_CLIENT_ID" value="com.googleusercontent.apps.123456789012-abcdefghijklmnopqrstuvwxyz123456" />
    <variable name="IOS_API_KEY" value="abcdefghijklmnopqrstuvwxyz1234-abcdefgh" />
    <variable name="IOS_GCM_SENDER_ID" value="123456789012" />
    <variable name="IOS_BUNDLE_ID" value="my.bundle.id" />
    <variable name="IOS_PROJECT_ID" value="project-id" />
    <variable name="IOS_STORAGE_BUCKET" value="project-id.appspot.com" />
    <variable name="IOS_IS_ADS_ENABLED" value="true" />
    <variable name="IOS_IS_ANALYTICS_ENABLED" value="false" />
    <variable name="IOS_IS_APPINVITE_ENABLED" value="false" />
    <variable name="IOS_IS_GCM_ENABLED" value="true" />
    <variable name="IOS_IS_SIGNIN_ENABLED" value="true" />
    <variable name="IOS_GOOGLE_APP_ID" value="1:123456789012:ios:abcdefghijklmnop" />
    <variable name="IOS_DATABASE_URL" value="https://project-id.firebaseio.com" />
</plugin>
```

After filling in the values in config.xml run `cordova prepare`.

### iOS Steps

Make sure you add the GoogleService-Info.plist to your build target:

1. Go to Build Phases > Copy Bundle Resources
2. Press the "+" button
3. Add Other
4. Go to iOS > 'Your Project Name' and select GoogleService-Info.plist
5. Check the box to 'Copy items if needed' and choose 'Create Folder Resources'


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
window.FirebasePlugin.startAnalytics(function(){
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

# cordova-plugin-firebase
Cordova plugin for Google Firebase

This plugin is under development! The primary goal for this plugin is to implement Analytics and FCM for cross platform push notifications. Other parts of the SDK will follow later.

Angular implementation is maintained in the [angular-cordova](https://github.com/arnesson/angular-cordova) project ([source](https://github.com/arnesson/angular-cordova/blob/master/src/plugins/3rdparty/firebase.js))

## Installation
Install the plugin by adding it your project's config.xml:
```
<plugin name="cordova-plugin-firebase" spec="https://github.com/arnesson/cordova-plugin-firebase" />
```
or by running:
```
cordova plugin add https://github.com/arnesson/cordova-plugin-firebase.git --save
```
Download your Firebase configuration files, GoogleService-Info.plist for ios and google-services.json for android, and place them in the root folder of your cordova project. See https://support.google.com/firebase/answer/7015592 for details.
Whenever cordova prepare is triggered the configuration files are copied to the right place in the ios and android app.


## Methods

### getInstanceId

Get the device id (token):
```
window.FirebasePlugin.getInstanceId(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```

### logEvent

Log an event using Analytics:
```
window.FirebasePlugin.logEvent("pageLoad", "Dashboard");
```

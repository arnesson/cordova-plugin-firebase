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

### grantPermission (iOS only)

Grant permission to recieve push notifications (will trigger prompt):
```
window.FirebasePlugin.grantPermission();
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
window.FirebasePlugin.logEvent("pageLoad", "Dashboard");
```

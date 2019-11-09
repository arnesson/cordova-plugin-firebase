cordova-plugin-firebasex [![Latest Stable Version](https://img.shields.io/npm/v/cordova-plugin-firebasex.svg)](https://www.npmjs.com/package/cordova-plugin-firebasex) [![Total Downloads](https://img.shields.io/npm/dt/cordova-plugin-firebasex.svg)](https://npm-stat.com/charts.html?package=cordova-plugin-firebasex)
========================

This plugin is a fork of [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) which has been rework to fix issues and add new functionality.

It brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project.

Supported platforms: Android and iOS

<!-- DONATE -->
[![donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZRD3W47HQ3EMJ)

I dedicate a considerable amount of my free time to developing and maintaining this Cordova plugin, along with my other Open Source software.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance. Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

  - [Installation](#installation)
    - [Plugin variables](#plugin-variables)
      - [Android & iOS](#android--ios)
      - [Android only](#android-only)
      - [iOS only](#ios-only)
    - [Supported Cordova Versions](#supported-cordova-versions)
    - [Migrating from cordova-plugin-firebase](#migrating-from-cordova-plugin-firebase)
      - [Breaking API changes](#breaking-api-changes)
      - [Ionic 4](#ionic-4)
      - [Ionic 3](#ionic-3)
  - [Build environment notes](#build-environment-notes)
    - [PhoneGap Build](#phonegap-build)
    - [Android-specific](#android-specific)
      - [Specifying Android library versions](#specifying-android-library-versions)
      - [AndroidX](#androidx)
    - [Google Play Services and Firebase libraries](#google-play-services-and-firebase-libraries)
    - [iOS-specific](#ios-specific)
      - [Specifying iOS library versions](#specifying-ios-library-versions)
      - [Cocoapods](#cocoapods)
      - [Out-of-date pods](#out-of-date-pods)
      - [Strip debug symbols](#strip-debug-symbols)
  - [Firebase config setup](#firebase-config-setup)
  - [Disable data collection on startup](#disable-data-collection-on-startup)
  - [Example project](#example-project)
  - [Reporting issues](#reporting-issues)
  - [Cloud messaging](#cloud-messaging)
    - [Background notifications](#background-notifications)
    - [Foreground notifications](#foreground-notifications)
    - [Android notifications](#android-notifications)
      - [Android background notifications](#android-background-notifications)
      - [Android foreground notifications](#android-foreground-notifications)
      - [Android Notification Channels](#android-notification-channels)
      - [Android Notification Icons](#android-notification-icons)
        - [Android Default Notification Icon](#android-default-notification-icon)
        - [Android Large Notification Icon](#android-large-notification-icon)
        - [Android Custom Notification Icons](#android-custom-notification-icons)
      - [Android Notification Color](#android-notification-color)
      - [Android Notification Sound](#android-notification-sound)
    - [iOS notifications](#ios-notifications)
      - [iOS background notifications](#ios-background-notifications)
      - [iOS notification sound](#ios-notification-sound)
      - [iOS badge number](#ios-badge-number)
    - [Data messages](#data-messages)
      - [Data message notifications](#data-message-notifications)
        - [Android data message notifications](#android-data-message-notifications)
        - [iOS data message notifications](#ios-data-message-notifications)
  - [Google Tag Manager](#google-tag-manager)
    - [Android](#android)
    - [iOS](#ios)
  - [API](#api)
    - [Notifications and data messages](#notifications-and-data-messages)
      - [getToken](#gettoken)
      - [onTokenRefresh](#ontokenrefresh)
      - [getAPNSToken](#getapnstoken)
      - [onApnsTokenReceived](#onapnstokenreceived)
      - [onMessageReceived](#onmessagereceived)
      - [grantPermission](#grantpermission)
      - [hasPermission](#haspermission)
      - [unregister](#unregister)
      - [isAutoInitEnabled](#isautoinitenabled)
      - [setAutoInitEnabled](#setautoinitenabled)
      - [setBadgeNumber](#setbadgenumber)
      - [getBadgeNumber](#getbadgenumber)
      - [clearAllNotifications](#clearallnotifications)
      - [subscribe](#subscribe)
      - [unsubscribe](#unsubscribe)
      - [createChannel](#createchannel)
      - [setDefaultChannel](#setdefaultchannel)
      - [Default Android Channel Properties](#default-android-channel-properties)
      - [deleteChannel](#deletechannel)
      - [listChannels](#listchannels)
    - [Analytics](#analytics)
      - [setAnalyticsCollectionEnabled](#setanalyticscollectionenabled)
      - [logEvent](#logevent)
      - [setScreenName](#setscreenname)
      - [setUserId](#setuserid)
      - [setUserProperty](#setuserproperty)
    - [Crashlytics](#crashlytics)
      - [setCrashlyticsCollectionEnabled](#setcrashlyticscollectionenabled)
      - [setCrashlyticsUserId](#setcrashlyticsuserid)
      - [sendCrash](#sendcrash)
      - [logMessage](#logmessage)
      - [logError](#logerror)
    - [Authentication](#authentication)
      - [verifyPhoneNumber](#verifyphonenumber)
        - [Android](#android-1)
        - [iOS](#ios-1)
      - [signInWithCredential](#signinwithcredential)
      - [linkUserWithCredential](#linkuserwithcredential)
    - [Remote Config](#remote-config)
      - [fetch](#fetch)
      - [activateFetched](#activatefetched)
      - [getValue](#getvalue)
      - [getByteArray](#getbytearray)
      - [getInfo](#getinfo)
      - [setConfigSettings](#setconfigsettings)
      - [setDefaults](#setdefaults)
    - [Performance](#performance)
      - [setPerformanceCollectionEnabled](#setperformancecollectionenabled)
      - [startTrace](#starttrace)
      - [incrementCounter](#incrementcounter)
      - [stopTrace](#stoptrace)
- [Credits](#credits)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation
Install the plugin by adding it to your project's config.xml:
```xml
<plugin name="cordova-plugin-firebasex" spec="latest" />
```
or by running:
```
cordova plugin add cordova-plugin-firebasex
```

### Plugin variables
The following Cordova plugin variables are supported by the plugin.
Note that these must be set at plugin installation time. If you wish to change plugin variables, you'll need to uninstall the plugin and reinstall it with the new variable values.

#### Android & iOS
- `FIREBASE_ANALYTICS_COLLECTION_ENABLED` - whether to automatically enable Firebase Analytics data collection on app startup
- `FIREBASE_PERFORMANCE_COLLECTION_ENABLED` - whether to automatically enable Firebase Performance data collection on app startup
- `FIREBASE_CRASHLYTICS_COLLECTION_ENABLED` - whether to automatically enable Firebase Crashlytics data collection on app startup
See [Disable data collection on startup](#disable-data-collection-on-startup) for more info.

#### Android only
The following plugin variables are used to specify the Firebase SDK versions as Gradle dependencies on Android:
- `ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION`
- `ANDROID_FIREBASE_ANALYTICS_VERSION`
- `ANDROID_FIREBASE_MESSAGING_VERSION`
- `ANDROID_FIREBASE_CONFIG_VERSION`
- `ANDROID_FIREBASE_PERF_VERSION`
- `ANDROID_FIREBASE_AUTH_VERSION`
- `ANDROID_CRASHLYTICS_VERSION`
- `ANDROID_CRASHLYTICS_NDK_VERSION`
See [Specifying Android library versions](#specifying-android-library-versions) for more info.

- `ANDROID_ICON_ACCENT` - sets the default accent color for system notifications. See [Android Notification Color](#android-notification-color) for more info.

#### iOS only
- `IOS_STRIP_DEBUG` - prevents symbolification of all libraries included via Cocoapods. See [Strip debug symbols](#strip-debug-symbols) for more info.
- `SETUP_RECAPTCHA_VERIFICATION` - automatically sets up reCAPTCHA verification for phone authentication on iOS. See [verifyPhoneNumber](#verifyphonenumber) for more info. 

### Supported Cordova Versions
- cordova: `>= 9`
- cordova-android: `>= 8`
- cordova-ios: `>= 5`

### Migrating from cordova-plugin-firebase
If you already have [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) installed in your Cordova project, you need to completely remove it before installing this plugin otherwise they will conflict and cause build errors in your project. The safest way of doing this is as follows:

    rm -Rf platforms/android
    cordova plugin rm cordova-plugin-firebase
    rm -Rf plugins/ node_modules/
    npm install
    cordova plugin add cordova-plugin-firebasex
    cordova platform add android

#### Breaking API changes    
**IMPORTANT:** Recent versions of `cordova-plugin-firebasex` have made breaking changes to the plugin API in order to fix bugs or add more functionality.
Therefore you can no longer directly substitute `cordova-plugin-firebasex` in place of `cordova-plugin-firebase` without making code changes.

You should be aware of the following breaking changes compared with `cordova-plugin-firebase`:
* Minimum supported Cordova versions
    * `cordova@9` (CLI)
    * `cordova-android@8` (Android platform)
    * `cordova-ios@5` (iOS platform)
* Migrated to AndroidX from legacy Android Support Library
    * add dependency on [cordova-plugin-androidx](https://github.com/dpa99c/cordova-plugin-androidx) and [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter)
* Migrated to Cocoapods to satisfy Firebase SDK dependencies on iOS
* `onNotificationOpen()` renamed to `onMessageReceived()`
    * `tap` parameter is only set when user taps on a notification (not when a message is received from FCM)
    * `tap=foreground|background` instead of `tap=true|false`
* `hasPermission()` receives argument as a boolean (rather than an object with `isEnabled` key)
    * e.g. `window.FirebasePlugin.hasPermission(function(hasPermission){
               console.log("Permission is " + (hasPermission ? "granted" : "denied"));
           });`
* Adds support for foreground notifications and data notification messages

#### Ionic 4
[This PR](https://github.com/ionic-team/ionic-native/pull/3106) adds an [Ionic Native firebase-x Typescript wrapper](https://github.com/ionic-team/ionic-native/blob/master/src/%40ionic-native/plugins/firebase-x/index.ts) for using `cordova-plugin-firebasex` with Ionic 4. 
The API is similar to the [Ionic Native Firebase](https://ionicframework.com/docs/native/firebase) wrapper.

    ionic cordova plugin add cordova-plugin-firebasex
    npm install @ionic-native/firebase-x

    import { FirebaseX } from "@ionic-native/firebase-x/ngx";
    constructor(private firebase: FirebaseX)
     
    this.firebase.getToken().then(token => console.log(`The token is ${token}`))
    this.firebase.onMessageReceived().subscribe(data => console.log(`FCM message: ${data}`));
     
#### Ionic 3
The above PR does not work for Ionic 3 so you (currently) can't use the [Ionic Native Firebase](https://ionicframework.com/docs/native/firebase) Typescript wrapper with Ionic 3. 
(i.e. `import { Firebase } from "@ionic-native/firebase"` will not work).

To use `cordova-plugin-firebasex` with Ionic 3, you'll need to call its Javascript API directly from your Typescript app code, for example:

    (<any>window).FirebasePlugin.getToken(token => console.log(`token: ${token}`))
    
    (<any>window).FirebasePlugin.onMessageReceived((message) => {
        if (message.tap) { console.log(`Notification was tapped in the ${message.tap}`); }
    })
    
If you want to make the `onMessageReceived()` JS API behave like the Ionic Native wrapper:

    onNotificationOpen() {
          return new Observable(observer => {
                (window as any).FirebasePlugin.onMessageReceived((response) => {
                    observer.next(response);
                });
           });
    }
    ...
    this.onNotificationOpen().subscribe(data => console.log(`FCM message: ${data}`));
    
See the [cordova-plugin-firebasex-ionic3-test](https://github.com/dpa99c/cordova-plugin-firebasex-ionic3-test) example project for a demonstration of how to use the plugin with Ionic 3.    

## Build environment notes

### PhoneGap Build
This plugin will not work with Phonegap Build (and other remote cloud build envs) do not support Cordova hook scripts as they are used by this plugin to configure the native platform projects.
        
### Android-specific

#### Specifying Android library versions
This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Gradle on Android.
By default this plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebase/blob/master/plugin.xml) where you can find the currently pinned versions as `<preference>`'s, for example:

    <preference name="ANDROID_FIREBASE_ANALYTICS_VERSION" default="17.0.0" />

The Android defaults can be overridden at plugin installation time by specifying plugin variables as command-line arguments, for example:

    cordova plugin add cordova-plugin-firebasex --variable ANDROID_FIREBASE_ANALYTICS_VERSION=17.0.0
    
Or you can specify them as plugin variables in your `config.xml`, for example:

    <plugin name="cordova-plugin-firebasex" spec="latest">
        <variable name="ANDROID_FIREBASE_ANALYTICS_VERSION" value="17.0.0" />
    </plugin>
    
The following plugin variables are used to specify the following Gradle dependency versions on Android:

- `ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION` => `com.google.android.gms:play-services-tagmanager`
- `ANDROID_FIREBASE_ANALYTICS_VERSION` => `com.google.firebase:firebase-analytics`
- `ANDROID_FIREBASE_MESSAGING_VERSION` => `com.google.firebase:firebase-messaging`
- `ANDROID_FIREBASE_CONFIG_VERSION` => `com.google.firebase:firebase-config`
- `ANDROID_FIREBASE_PERF_VERSION` => `com.google.firebase:firebase-perf`
- `ANDROID_FIREBASE_AUTH_VERSION` => `com.google.firebase:firebase-auth`
- `ANDROID_CRASHLYTICS_VERSION` => `com.crashlytics.sdk.android:crashlytics`
- `ANDROID_CRASHLYTICS_NDK_VERSION` => `com.crashlytics.sdk.android:crashlytics-ndk`

For example, to explicitly specify all the component versions at plugin install time:

    cordova plugin add cordova-plugin-firebasex \
        --variable ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_ANALYTICS_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_MESSAGING_VERSION=19.0.0 \
        --variable ANDROID_FIREBASE_CONFIG_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_PERF_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_AUTH_VERSION=18.0.0 \
        --variable ANDROID_CRASHLYTICS_VERSION=2.10.1 \
        --variable ANDROID_CRASHLYTICS_NDK_VERSION=2.1.0 \
        
#### AndroidX
This plugin has been migrated to use [AndroidX (Jetpack)](https://developer.android.com/jetpack/androidx/migrate) which is the successor to the [Android Support Library](https://developer.android.com/topic/libraries/support-library/index).
This is implemented by adding a dependency on [cordova-plugin-androidx](https://github.com/dpa99c/cordova-plugin-androidx) which enables AndroidX in the Android platform of a Cordova project.

This is because the [major release of the Firebase and Play Services libraries on 17 June 2019](https://developers.google.com/android/guides/releases#june_17_2019) were migrated to AndroidX.

Therefore if your project includes any plugins which are dependent on the legacy Android Support Library, you should add [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter) to your project.
This plugin will dynamically migrate any plugin code from the Android Support Library to AndroidX equivalents.

### Google Play Services and Firebase libraries
Your Android build may fail if you are installing multiple plugins that use the Google Play Services library.  
This is caused by plugins installing different versions of the Google Play Services library.  
This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release) which enables you to override the versions specified by other plugins in order to align them.

Similarly, if your build is failing because multiple plugins are installing different versions of the Firebase library, 
you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release) to align these.  

### iOS-specific
#### Specifying iOS library versions
This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Cocoapods on iOS.
This plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebase/blob/master/plugin.xml) where you can find the currently pinned iOS versions in the  `<pod>`'s, for example:

    <pod name="Firebase/Core" spec="6.3.0"/>
    
**It is currently not possible to override these at plugin installation time** because `cordova@9`/`cordova-ios@5` does not support the use of plugin variables in the `<pod>`'s `spec` attribute.
Therefore if you need to change the specified versions, you'll currently need to do this by forking the plugin and editing the `plugin.xml` to change the specified `spec` values.     

#### Cocoapods
This plugin relies on `cordova@9`/`cordova-ios@5` support for the [CocoaPods dependency manager]( https://cocoapods.org/) in order to satisfy the iOS Firebase SDK library dependencies.

Therefore please make sure you have Cocoapods installed in your iOS build environment - setup instructions can be found [here](https://cocoapods.org/).

If building your project in Xcode, you need to open `YourProject.xcworkspace` (not `YourProject.xcodeproj`) so both your Cordova app project and the Pods project will be loaded into Xcode.

You can list the pod dependencies in your Cordova iOS project by installing [cocoapods-dependencies](https://github.com/segiddins/cocoapods-dependencies):

    sudo gem install cocoapods-dependencies
    cd platforms/ios/
    pod dependencies
    
#### Out-of-date pods
If you receive a build error such as this:

    None of your spec sources contain a spec satisfying the dependencies: `Firebase/Analytics (~> 6.1.0), Firebase/Analytics (= 6.1.0, ~> 6.1.0)`.

Make sure your local Cocoapods repo is up-to-date by running `pod repo update` then run `pod install` in `/your_project/platforms/ios/`.    

#### Strip debug symbols
If your iOS app build contains too many debug symbols (i.e. because you include lots of libraries via a Cocoapods), you might get an error (e.g. [issue #28](https://github.com/dpa99c/cordova-plugin-firebase/issues/28)) when you upload your binary to App Store Connect, e.g.:

    ITMS-90381: Too many symbol files - These symbols have no corresponding slice in any binary [16EBC8AC-DAA9-39CF-89EA-6A58EB5A5A2F.symbols, 1B105D69-2039-36A4-A04D-96C1C5BAF235.symbols, 476EACDF-583B-3B29-95B9-253CB41097C8.symbols, 9789B03B-6774-3BC9-A8F0-B9D44B08DCCB.symbols, 983BAE60-D245-3291-9F9C-D25E610846AC.symbols].

To prevent this, you can set the `IOS_STRIP_DEBUG` plugin variable which prevents symbolification of all libraries included via Cocoapods (see here)[https://stackoverflow.com/a/48518656/777265]:

    cordova plugin add cordova-plugin-firebasex --variable IOS_STRIP_DEBUG=true

By default this preference is set to `false`.

Note: if you enable this setting, any crashes that occur within libraries included via Cocopods will not be recorded in Crashlytics or other crash reporting services.

## Firebase config setup
There's a handy [installation and setup guide on medium.com](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821).
However, if using this, remember this forked plugin is `cordova-plugin-firebasex` (not `cordova-plugin-firebase`).

Download your Firebase configuration files, `GoogleService-Info.plist` for iOS and `google-services.json` for android, and place them in the root folder of your cordova project.
Check out this [firebase article](https://support.google.com/firebase/answer/7015592) for details on how to download the files.

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
IMPORTANT: The Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

## Disable data collection on startup
By default, analytics, performance and Crashlytics data will begin being collected as soon as the app starts up.
However, for data protection or privacy reasons, you may wish to disable data collection until such time as the user has granted their permission.

To do this, set the following plugin variables to `false` at plugin install time:

* `FIREBASE_ANALYTICS_COLLECTION_ENABLED`
* `FIREBASE_PERFORMANCE_COLLECTION_ENABLED`
* `FIREBASE_CRASHLYTICS_COLLECTION_ENABLED` 


    cordova plugin add cordova-plugin-firebasex \
        --variable FIREBASE_ANALYTICS_COLLECTION_ENABLED=false \ 
        --variable FIREBASE_PERFORMANCE_COLLECTION_ENABLED=false \ 
        --variable FIREBASE_CRASHLYTICS_COLLECTION_ENABLED=false

This will disable data collection (on both Android & iOS) until you call [setAnalyticsCollectionEnabled](#setanalyticscollectionenabled), [setPerformanceCollectionEnabled](#setperformancecollectionenabled) and [setCrashlyticsCollectionEnabled](#setcrashlyticscollectionenabled):

       window.FirebasePlugin.setAnalyticsCollectionEnabled(true);
       window.FirebasePlugin.setPerformanceCollectionEnabled(true);
       window.FirebasePlugin.setCrashlyticsCollectionEnabled();

## Example project
An example project repo exists to demonstrate and validate the functionality of this plugin:
https://github.com/dpa99c/cordova-plugin-firebasex-test

Please use this as a working reference.

## Reporting issues
Before reporting an issue with this plugin, please do the following:
- check a similar issue is not already open (or closed) against this plugin.
- try to reproduce the issue using the example project
	- or if that's not possible, using an isolated test project that you are able to share
	- this will eliminate bugs in your code or conflicts with other code as possible causes of the issue
- any issue which is suspected of being caused by the Ionic Native wrapper should be [reported against Ionic Native](https://github.com/ionic-team/ionic-native/issues/new)
	- Ionic Native Typescript wrappers are maintained by the Ionic Team
	- To verify an if an issue is caused by this plugin or its Typescript wrapper, please re-test using the vanilla Javascript plugin interface (without the Ionic Native wrapper).
- if you are having build problems, ensure you have thoroughly read the [Build environment notes](#build-environment-notes) section and searched existing open/closed issues for a similar problem.
- if you are migrating from `cordova-plugin-firebase` to `cordova-plugin-firebasex` please make sure you have read the [Migrating from cordova-plugin-firebase](#migrating-from-cordova-plugin-firebase) section.

## Cloud messaging
<p align="center">
  <a href="https://youtu.be/qLPhan9YUhQ"><img src="https://media.giphy.com/media/U70vu02o9yCFEffidf/200w_d.gif" /></a>
  <span>&nbsp;</span>
  <a href="https://youtu.be/35feCmGYSR4"><img src="https://media.giphy.com/media/Y4oFG0Awhd3TpnggHz/200w_d.gif" /></a>
</p>

There are 2 distinct types of messages that can be sent by Firebase Cloud Messaging (FCM):

- [Notification messages](https://firebase.google.com/docs/cloud-messaging/concept-options#notifications)
    - automatically displayed to the user by the operating system on behalf of the client app **while your app is not running or is in the background**
        - **if your app is in the foreground when the notification message arrives**, it is passed to the client app and it is the responsibility of the client app to display it.
    - have a predefined set of user-visible keys and an optional data payload of custom key-value pairs.
- [Data messages](https://firebase.google.com/docs/cloud-messaging/concept-options#data_messages)
    - Client app is responsible for processing data messages.
    - Data messages have only custom key-value pairs.
    
Note: only notification messages can be sent via the Firebase Console - data messages must be sent via the [FCM APIs](https://firebase.google.com/docs/cloud-messaging/server).

### Background notifications
If the notification message arrives while the app is in the background/not running, it will be displayed as a system notification.

By default, no callback is made to the plugin when the message arrives while the app is not in the foreground, since the display of the notification is entirely handled by the operating system. 
However, there are platform-specific circumstances where a callback can be made when the message arrives and the app is in the background that don't require user interaction to receive the message payload - see [Android background notifications](#android-background-notifications) and [iOS background notifications](#ios-background-notifications) for details.

If the user taps the system notification, this launches/resumes the app and the notification title, body and optional data payload is passed to the [onMessageReceived](#onMessageReceived) callback.

When the `onMessageReceived` is called in response to a user tapping a system notification while the app is in the background/not running, it will be passed the property `tap: "background"`.


### Foreground notifications
If the notification message arrives while the app is in running in the foreground, by default **it will NOT be displayed as a system notification**.
Instead the notification message payload will be passed to the [onMessageReceived](#onMessageReceived) callback for the plugin to handle (`tap` will not be set).

If you include the `notification_foreground` key in the `data` payload, the plugin will also display a system notification upon receiving the notification messages while the app is running in the foreground.
For example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "data": {
        "notification_foreground": "true",
      }
    }

When the `onMessageReceived` is called in response to a user tapping a system notification while the app is in the foreground, it will be passed the property `tap: "foreground"`.

You can set additional properties of the foreground notification using the same key names as for [Data Message Notifications](#data-message-notification-keys).

### Android notifications
Notifications on Android can be customised to specify the sound, icon, LED colour, etc. that's displayed when the notification arrives.

#### Android background notifications
If the notification message arrives while the app is in the background/not running, it will be displayed as a system notification.

If a notification message arrives while the app is in the background but is still running (i.e. has not been task-killed) and the device is not in power-saving mode, the `onMessageReceived` callback will be invoked without the `tap` property, indicating the message was received without user interaction.

If the user then taps the system notification, the app will be brought to the foreground and `onMessageReceived` will be invoked **again**, this time with `tap: "background"` indicating that the user tapped the system notification while the app was in the background.

In addition to the title and body of the notification message, Android system notifications support specification of the following notification settings:
- [Icon](#android-notification-icons)
- [Sound](#android-notification-sound)
- [Color accent](#android-notification-color)
- [Channel ID](#android-notification-channels) (Android 8.0 (O) and above)
    - This channel configuration enables you to specify:
        - Sound
        - Vibration
        - LED light
        - Badge
        - Importance
        - Visibility
    - See [createChannel](#createchannel) for details.
    
Note: on tapping a background notification, if your app is not running, only the `data` section of the notification message payload will be delivered to [onMessageReceived](#onMessageReceived).
i.e. the notification title, body, etc. will not. Therefore if you need the properties of the notification message itself (e.g. title & body) to be delivered to [onMessageReceived](#onMessageReceived), you must duplicate these in the `data` section, e.g.:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "data": {
        "notification_body": "Notification body",
        "notification_title": "Notification title"
      }
    }  

#### Android foreground notifications
If the notification message arrives while the app is in the foreground, by default a system notification won't be displayed and the data will be passed to [onMessageReceived](#onMessageReceived).

However, if you set the `notification_foreground` key in the `data` section of the notification message payload, this will cause the plugin to display system notification when the message is received while your app is in the foreground. You can customise the notification using the same keys as for [Android data message notifications](#android-data-message-notifications).
    
#### Android Notification Channels
- Android 8 (O) introduced [notification channels](https://developer.android.com/training/notify-user/channels).
- Notification channels are configured by the app and used to determine the sound/lights/vibration settings of system notifications.
- By default, this plugin creates a default channel with [default properties]((#default-android-channel-properties)
    - These can be overridden via the [setDefaultChannel](#setdefaultchannel) function. 
- The plugin  enables the creation of additional custom channels via the [createChannel](#createchannel) function.

On Android 7 and below, the sound setting of system notifications is specified in the notification message itself, for example:

    {
      "name": "my_notification",
        "notification": {
          "body": "Notification body",
          "title": "Notification title"
        },
      "android": {
        "notification": {
          "sound": "my_sound",
          "tag": "default"
      }
    }


#### Android Notification Icons
By default the plugin will use the default app icon for notification messages.

##### Android Default Notification Icon
To define a custom default notification icon, you need to create the images and deploy them to the `<projectroot>/platforms/android/app/src/main/res/<drawable-DPI>` folders.
The easiest way to create the images is using the [Image Asset Studio in Android Studio](https://developer.android.com/studio/write/image-asset-studio#create-notification) or using the [Android Asset Studio webapp](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html#source.type=clipart&source.clipart=ac_unit&source.space.trim=1&source.space.pad=0&name=notification_icon).

The icons should be monochrome transparent PNGs with the following sizes:

- mdpi: 24x24
- hdpi: 36x36
- xhdpi: 48x48
- xxhdpi: 72x72
- xxxhdpi: 96x96

Once you've created the images, you need to deploy them from your Cordova project to the native Android project.
To do this, copy the `drawable-DPI` image directories into your Cordova project and add `<resource-file>` entries to the `<platform name="android">` section of your `config.xml`, where `src` specifies the relative path to the images files within your Cordova project directory. 

For example, copy the`drawable-DPI` image directories to `<projectroot>/res/android/` and add the following to your `config.xml`:

    <platform name="android">
        <resource-file src="res/android/drawable-mdpi/notification_icon.png" target="app/src/main/res/drawable-mdpi/notification_icon.png" />
        <resource-file src="res/android/drawable-hdpi/notification_icon.png" target="app/src/main/res/drawable-hdpi/notification_icon.png" />
        <resource-file src="res/android/drawable-xhdpi/notification_icon.png" target="app/src/main/res/drawable-xhdpi/notification_icon.png" />
        <resource-file src="res/android/drawable-xxhdpi/notification_icon.png" target="app/src/main/res/drawable-xxhdpi/notification_icon.png" />
        <resource-file src="res/android/drawable-xxxhdpi/notification_icon.png" target="app/src/main/res/drawable-xxxhdpi/notification_icon.png" />
    </platform>
    
The default notification icon images **must** be named `notification_icon.png`. 

You then need to add a `<config-file>` block to the `config.xml` which will instruct Firebase to use your icon as the default for notifications:

    <platform name="android">
        <config-file target="AndroidManifest.xml" parent="/manifest/application">
            <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/notification_icon" />
        </config-file>
    </platform>


##### Android Large Notification Icon
The default notification icons above are monochrome, however you can additionally define a larger multi-coloured icon.

**NOTE:** FCM currently does not support large icons in system notifications displayed for notification messages received in the while the app is in the background (or not running).
So the large icon will currently only be used if specified in [data messages](#android-data-messages) or [foreground notifications](#foreground-notifications).

The large icon image should be a PNG-24 that's 256x256 pixels and must be named `notification_icon_large.png` and should be placed in the `drawable-xxxhdpi` resource directory.
As with the small icons, you'll need to add a `<resource-file>` entry to the `<platform name="android">` section of your `config.xml`:

    <platform name="android">
        <resource-file src="res/android/drawable-xxxhdpi/notification_icon_large.png" target="app/src/main/res/drawable-xxxhdpi/notification_icon_large.png" />
    </platform>


##### Android Custom Notification Icons
You can define additional sets of notification icons in the same manner as above.
These can be specified in notification or data messages.

For example:

        <resource-file src="res/android/drawable-mdpi/my_icon.png" target="app/src/main/res/drawable-mdpi/my_icon.png" />
        <resource-file src="res/android/drawable-hdpi/my_icon.png" target="app/src/main/res/drawable-hdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xhdpi/my_icon.png" target="app/src/main/res/drawable-xhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxhdpi/my_icon.png" target="app/src/main/res/drawable-xxhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxxhdpi/my_icon.png" target="app/src/main/res/drawable-xxxhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxxhdpi/my_icon_large.png" target="app/src/main/res/drawable-xxxhdpi/my_icon_large.png" />
        
When sending an FCM notification message, you will then specify the icon name in the `android.notification` section, for example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "android": {
        "notification": {
          "icon": "my_icon",
        }
      },
      "data": {
        "notification_foreground": "true",
      }
    }

You can also reference these icons in [data messages](#android-data-messages), for example:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_android_icon": "my_icon",
      }
    }         


#### Android Notification Color
On Android Lollipop (5.0/API 21) and above you can set the default accent color for the notification by adding a color setting.
This is defined as an [ARGB colour](https://en.wikipedia.org/wiki/RGBA_color_space#ARGB_(word-order)) which the plugin sets by default to `#FF00FFFF` (cyan).
Note: On Android 7 and above, the accent color can only be set for the notification displayed in the system tray area - the icon in the statusbar is always white.

You can override this default by specifying a value using the `ANDROID_ICON_ACCENT` plugin variable during plugin installation, for example:

    cordova plugin add cordova-plugin-firebasex --variable ANDROID_ICON_ACCENT=#FF123456
    
You can override the default color accent by specifying the `colour` key as an RGB value in a notification message, e.g.:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "android": {
        "notification": {
          "color": "#00ff00"
        }
      }
    }
    
And in a data message:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_android_color": "#00ff00"
      }
    }         


#### Android Notification Sound
You can specify custom sounds for notifications or play the device default notification sound.

Custom sound files must be in `.mp3` format and deployed to the `/res/raw` directory in the Android project.
To do this, you can add `<resource-file>` tags to your `config.xml` to deploy the files, for example:

    <platform name="android">
        <resource-file src="res/android/raw/my_sound.mp3" target="app/src/main/res/raw/my_sound.mp3" />
    </platform>

In a notification message, you specify the sound file name in the `android.notification` section, for example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "android": {
        "notification": {
          "sound": "my_sound"
        }
      }
    }
    
And in a data message by specifying it in the `data` section:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_android_sound": "my_sound"
      }
    } 
    
- To play the default notification sound, set `"sound": "default"`.
- To display a silent notification (no sound), omit the `sound` key from the message.

### iOS notifications
Notifications on iOS can be customised to specify the sound and badge number that's displayed when the notification arrives.

Notification settings are specified in the `apns.payload.aps` key of the notification message payload.
For example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "apns": {
          "payload": {
            "aps": {
              "sound": "default",
              "badge": 1,
              "content-available": 1
            }
          }
        }
    }

#### iOS background notifications
If the app is in the background but is still running (i.e. has not been task-killed) and the device is not in power-saving mode, the `onMessageReceived` callback can be invoked when the message arrives without requiring user interaction (i.e. tapping the system notification).
To do this you must specify `"content-available": 1` in the `apns.payload.aps` section of the message payload - see the [Apple documentation](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW8) for more information.
When the message arrives, the `onMessageReceived` callback will be invoked without the `tap` property, indicating the message was received without user interaction.
If the user then taps the system notification, the app will be brought to the foreground and `onMessageReceived` will be invoked **again**, this time with `tap: "background"` indicating that the user tapped the system notification while the app was in the background.

#### iOS notification sound
You can specify custom sounds for notifications or play the device default notification sound.

Custom sound files must be in a supported audio format (see [this Apple documentation](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SupportingNotificationsinYourApp.html#//apple_ref/doc/uid/TP40008194-CH4-SW10) for supported formats).
For example to convert an `.mp3` file to the supported `.caf` format run:

    afconvert my_sound.mp3 my_sound.caf -d ima4 -f caff -v

Sound files must be deployed with the iOS application bundle. 
To do this, you can add `<resource-file>` tags to your `config.xml` to deploy the files, for example:

    <platform name="ios">
        <resource-file src="res/ios/sound/my_sound.caf" />
    </platform>

In a notification message, specify the `sound` key in the `apns.payload.aps` section, for example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "apns": {
          "payload": {
            "aps": {
              "sound": "my_sound.caf"
            }
          }
        }
    }
    
- To play the default notification sound, set `"sound": "default"`.
- To display a silent notification (no sound), omit the `sound` key from the message.
    
In a data message, specify the `notification_ios_sound` key in the `data` section:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_ios_sound": "my_sound.caf"
      }
    } 
    
#### iOS badge number
In a notification message, specify the `badge` key in the `apns.payload.aps` section, for example:

    {
      "name": "my_notification",
      "notification": {
        "body": "Notification body",
        "title": "Notification title"
      },
      "apns": {
          "payload": {
            "aps": {
              "badge": 1
            }
          }
        }
    }
    
In a data message, specify the `notification_ios_badge` key in the `data` section:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_ios_badge": 1
      }
    } 


### Data messages
FCM data messages are sent as an arbitrary k/v structure and by default are passed to the app for it to handle them.

**NOTE:** FCM data messages **cannot** be sent from the Firebase Console - they can only be sent via the FCM APIs.

#### Data message notifications
This plugin enables a data message to be displayed as a system notification.
To have the app display a notification when the data message arrives, you need to set the `notification_foreground` key in the `data` section.
You can then set a `notification_title` and `notification_body`, for example:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "foo" : "bar"
      }
    }
    
Additional platform-specific notification options can be set using the additional keys below (which are only relevant if the `notification_foreground` key is set).

Note: [foreground notification messages](#foreground-notifications) can also make use of these keys.

##### Android data message notifications
On Android:
- Data messages that arrive while your app is running in the foreground or running in the background will be immediately passed to the `onMessageReceived()` Javascript handler in the Webview. 
- Data messages (not containing notification keys) that arrive while your app is **not running** will be passed to the `onMessageReceived()` Javascript handler when the app is next launched.
- Data messages containing notification keys that arrive while your app is running or **not running** will be displayed as a system notification.

The following Android-specific keys are supported and should be placed inside the `data` section:

- `notification_android_icon` - name of a [custom notification icon](#android-custom-notification-icons) in the drawable resources
    - if not specified, the plugin will use the default `notification_icon` if it exists; otherwise the default app icon will be displayed
    - if a [large icon](#android-large-notification-icon) has been defined, it will also be displayed in the system notification.
- `notification_android_color` - the [color accent](#android-notification-color) to use for the small notification icon
    - if not specified, the default color accent will be used
- `notification_android_channel_id` - ID of the [notification channel](#android-notification-channels) to use to display the notification
    - Only applies to Android 8.0 and above   
    - If not specified, the [default notification channel](#default-android-channel-properties) will be used.
        - You can override the default configuration for the default notification channel using [setDefaultChannel](#setdefaultchannel). 
    - You can create additional channels using [createChannel](#createchannel).
- `notification_android_priority` - Specifies the notification priority
    - Possible values:
        - `2` - Highest notification priority for your application's most important items that require the user's prompt attention or input.
        - `1` - Higher notification priority for more important notifications or alerts.
        - `0` - Default notification priority.
        - `-1` - Lower notification priority for items that are less important.
        - `-2` - Lowest notification priority. These items might not be shown to the user except under special circumstances, such as detailed notification logs.
    - Defaults to `2` if not specified.
- `notification_android_visibility` - Specifies the notification visibility
    - Possible values:
        - `1` - Show this notification in its entirety on all lockscreens.
        - `0` - Show this notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.
        - `-1` - Do not reveal any part of this notification on a secure lockscreen.
    - Defaults to `1` if not specified.

The following keys only apply to Android 7 and below. 
On Android 8 and above they will be ignored - the `notification_android_channel_id` property should be used to specify a [notification channel](#android-notification-channels) with equivalent settings.

- `notification_android_sound` - name of a sound resource to play as the [notification sound](#android-notification-sound)
    - if not specified, no sound is played
    - `default` plays the default device notification sound
    - otherwise should be the name of an `.mp3` file in the `/res/raw` directory, e.g. `my_sound.mp3` => `"sounds": "my_sound"`
- `notification_android_lights` - color and pattern to use to blink the LED light
    - if not defined, LED will not blink
    - in the format `ARGB, time_on_ms, time_off_ms` where
        - `ARGB` is an ARGB color definition e.g. `#ffff0000`
        - `time_on_ms` is the time in milliseconds to turn the LED on for
        - `time_off_ms` is the time in milliseconds to turn the LED off for
    - e.g. `"lights": "#ffff0000, 250, 250"`
- `notification_android_vibrate` - pattern of vibrations to use when the message arrives
    - if not specified, device will not vibrate
    - an array of numbers specifying the time in milliseconds to vibrate
    - e.g. `"vibrate": "500, 200, 500"`

Example data message with Android notification keys:

    {
      "name": "my_data_message",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_android_channel_id": "my_channel",
        "notification_android_priority": "2",
        "notification_android_visibility": "1",
        "notification_android_color": "#ff0000",
        "notification_android_icon": "coffee",
        "notification_android_sound": "my_sound",
        "notification_android_vibrate": "500, 200, 500",
        "notification_android_lights": "#ffff0000, 250, 250"
      }
    }

##### iOS data message notifications
On iOS:
- Data messages that arrive while your app is running in the foreground or running in the background will be immediately passed to the `onMessageReceived()` Javascript handler in the Webview. 
- Data messages that arrive while your app is **not running** will **NOT be received by your app!**

The following iOS-specific keys are supported and should be placed inside the `data` section:

- `notification_ios_sound` - Sound to play when the notification is displayed
    - To play a custom sound, set the name of the sound file bundled with your app, e.g.  `"sound": "my_sound.caf"` - see [iOS notification sound](#ios-notification-sound) for more info.
    - To play the default notification sound, set `"sound": "default"`.
    - To display a silent notification (no sound), omit the `sound` key from the message.
- `notification_ios_badge` - Badge number to display on app icon on home screen.

For example:

    {
      "name": "my_data",
      "data" : {
        "notification_foreground": "true",
        "notification_body" : "Notification body",
        "notification_title": "Notification title",
        "notification_ios_sound": "my_sound.caf",
        "notification_ios_badge": 1
      }
    } 


## Google Tag Manager
Download your container-config json file from Tag Manager and add a resource-file node in your `config.xml`.

### Android
```
<platform name="android">
    <resource-file src="GTM-XXXXXXX.json" target="assets/containers/GTM-XXXXXXX.json" />
    ...
```

### iOS
```
<platform name="ios">
    <resource-file src="GTM-YYYYYYY.json" />
    ...
```

## API
The list of available methods for this plugin is described below.

### Notifications and data messages
The plugin is capable of receiving push notifications and FCM data messages.

See [Cloud messaging](#cloud-messaging) section for more.

#### getToken
Get the current FCM token.
Null if the token has not been allocated yet by the Firebase SDK.

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.getToken(function(fcmToken) {
    console.log(fcmToken);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet.

#### onTokenRefresh
Registers a handler to call when the FCM token changes.
This is the best way to get the token as soon as it has been allocated.
This will be called on the first run after app install when a token is first allocated.
It may also be called again under other circumstances, e.g. if `unregister()` is called or Firebase allocates a new token for other reasons.
You can use this callback to return the token to you server to keep the FCM token associated with a given user up-to-date. 

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.onTokenRefresh(function(fcmToken) {
    console.log(fcmToken);
}, function(error) {
    console.error(error);
});
```

#### getAPNSToken
iOS only.
Get the APNS token allocated for this app install.
Note that token will be null if it has not been allocated yet.

**Parameters**:
- {function} success - callback function which will be passed the {string} APNS token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.getAPNSToken(function(apnsToken) {
    console.log(apnsToken);
}, function(error) {
    console.error(error);
});
```

#### onApnsTokenReceived
iOS only.
Registers a handler to call when the APNS token is allocated.
This will be called once when remote notifications permission has been granted by the user at runtime. 

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.onApnsTokenReceived(function(apnsToken) {
    console.log(apnsToken);
}, function(error) {
    console.error(error);
});
```

#### onMessageReceived
Registers a callback function to invoke when: 
- a notification or data message is received by the app
- a system notification is tapped by the user

**Parameters**:
- {function} success - callback function which will be passed the {object} message as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.onMessageReceived(function(message) {
    console.log("Message type: " + message.messageType);
    if(message.messageType === "notification"){
        console.log("Notification message received");
        if(message.tap){
            console.log("Tapped in " + message.tap);
        }
    }
    console.dir(message);
}, function(error) {
    console.error(error);
});
```

The `message` object passed to the callback function will contain the platform-specific FCM message payload along with the following keys:
- `messageType=notification|data` - indicates if received message is a notification or data message
- `tap=foreground|background` - set if the call to `onMessageReceived()` was initiated by user tapping on a system notification. 
    - indicates if the system notification was tapped while the app was in the foreground or background.
    - not set if no system notification was tapped (i.e. message was received directly from FCM rather than via a user tap on a system notification).

Notification message flow:

1. App is in foreground:
    a. By default, when a notification message arrives the app receives the notification message payload in the `onMessageReceived` JavaScript callback without any system notification on the device itself.
    b. If the `data` section contains the `notification_foreground` key, the plugin will display a system notification while in the foreground.
2. App is in background:
    a. User receives the notification message as a system notification in the device notification bar
    b. User taps the system notification which launches the app
    b. User receives the notification message payload in the `onMessageReceived` JavaScript callback

Data message flow:

1. App is in foreground:
    a. By default, when a data message arrives the app receives the data message payload in the `onMessageReceived` JavaScript callback without any system notification on the device itself.
    b. If the `data` section contains the `notification_foreground` key, the plugin will display a system notification while in the foreground.
2. App is in background:
    a. The app receives the data message in the `onMessageReceived` JavaScript callback while in the background
    b. If the data message contains the [data message notification keys](#data-message-notifications), the plugin will display a system notification for the data message while in the background.

#### grantPermission
Grant permission to receive push notifications (will trigger prompt) and return `hasPermission: true`.
iOS only (Android will always return true).

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.grantPermission(function(hasPermission){
    console.log("Permission was " + (hasPermission ? "granted" : "denied"));
});
```
#### hasPermission
Check permission to receive push notifications and return the result to a callback function as boolean.
On iOS, returns true is runtime permission for remote notifications is granted and enabled in Settings.
On Android, returns true if remote notifications are enabled.

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.hasPermission(function(hasPermission){
    console.log("Permission is " + (hasPermission ? "granted" : "denied"));
});
```

#### unregister
Unregisters from Firebase by deleting the current device token.
Use this to stop receiving push notifications associated with the current token. 
e.g. call this when you logout user from your app.
By default, a new token will be generated as soon as the old one is removed.
To prevent a new token being generated, by sure to disable autoinit using [`setAutoInitEnabled()`](#setautoinitenabled) before calling [`unregister()`](#unregister).

**Parameters**: None

```javascript
window.FirebasePlugin.unregister();
```

#### isAutoInitEnabled
Indicates whether autoinit is currently enabled.
If so, new FCM tokens will be automatically generated.

**Parameters**:
- {function} success - callback function which will be passed the {boolean} result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument


```javascript
window.FirebasePlugin.isAutoInitEnabled(function(enabled){
    console.log("Auto init is " + (enabled ? "enabled" : "disabled"));    
});

```

#### setAutoInitEnabled
Sets whether to autoinit new FCM tokens.
By default, a new token will be generated as soon as the old one is removed.
To prevent a new token being generated, by sure to disable autoinit using [`setAutoInitEnabled()`](#setautoinitenabled) before calling [`unregister()`](#unregister).

**Parameters**:
- {boolean} enabled - set true to enable, false to disable
- {function} success - callback function to call on successful execution of operation.
- {function} error - callback function which will be passed a {string} error message as an argument


```javascript
window.FirebasePlugin.setAutoInitEnabled(false, function(){
    console.log("Auto init has been disabled ");
    window.FirebasePlugin.unregister();
});

```

#### setBadgeNumber
iOS only.
Set a number on the icon badge:

**Parameters**:
- {integer} badgeNumber - number to set for the app badge

```javascript
window.FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge
```javascript
window.FirebasePlugin.setBadgeNumber(0);
```

Note: this function is no longer available on Android (see [#124](https://github.com/dpa99c/cordova-plugin-firebasex/issues/124))

#### getBadgeNumber
iOS only.
Get icon badge number:

**Parameters**:
- {function} success - callback function which will be passed the {integer} current badge number as an argument

```javascript
window.FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

Note: this function is no longer available on Android (see [#124](https://github.com/dpa99c/cordova-plugin-firebasex/issues/124))

#### clearAllNotifications
Clear all pending notifications from the drawer:

**Parameters**: None

```javascript
window.FirebasePlugin.clearAllNotifications();
```

#### subscribe
Subscribe to a topic.

Topic messaging allows you to send a message to multiple devices that have opted in to a particular topic.

**Parameters**:
- {string} topicName - name of topic to subscribe to

```javascript
window.FirebasePlugin.subscribe("latest_news");
```

#### unsubscribe
Unsubscribe from a topic.

This will stop you receiving messages for that topic

**Parameters**:
- {string} topicName - name of topic to unsubscribe from

```javascript
window.FirebasePlugin.unsubscribe("latest_news");
```

#### createChannel
Android 8+ only.
Creates a custom channel to be used by notification messages which have the channel property set in the message payload to the `id` of the created channel:
- For background (system) notifications: `android.notification.channel_id`
- For foreground/data notifications:  `data.notification_android_channel_id`

For each channel you may set the sound to be played, the color of the phone LED (if supported by the device), whether to vibrate and set vibration pattern (if supported by the device), importance and visibility. 
Channels should be created as soon as possible (on program start) so notifications can work as expected.
A default channel is created by the plugin at app startup; the properties of this can be overridden see [setDefaultChannel](#setdefaultchannel) 

Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {object} - channel configuration object (see below for object keys/values)
- {function} success - callback function which will be call on successful channel creation
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
// Define custom  channel - all keys are except 'id' are optional.
var channel  = {
    // channel ID - must be unique per app package
    id: "my_channel_id",

    // Channel description. Default: empty string
    description: "Channel description",
    
    // Channel name. Default: empty string
    name: "Channel name",
    
    //The sound to play once a push comes. Default value: 'default'
    //Values allowed:
    //'default' - plays the default notification sound
    //'ringtone' - plays the currently set ringtone
    //'false' - silent; don't play any sound
    //filename - the filename of the sound file located in '/res/raw' without file extension (mysound.mp3 -> mysound) 
    sound: "mysound",
    
    //Vibrate on new notification. Default value: true
    //Possible values:
    //Boolean - vibrate or not
    //Array - vibration pattern - e.g. [500, 200, 500] - milliseconds vibrate, milliseconds pause, vibrate, pause, etc.
    vibration: true,
    
    // Whether to blink the LED
    light: true,
    
    //LED color in ARGB format - this example BLUE color. If set to -1, light color will be default. Default value: -1.
    lightColor: "0xFF0000FF",
    
    //Importance - integer from 0 to 4. Default value: 4
    //0 - none - no sound, does not show in the shade
    //1 - min - no sound, only shows in the shade, below the fold
    //2 - low - no sound, shows in the shade, and potentially in the status bar
    //3 - default - shows everywhere, makes noise, but does not visually intrude
    //4 - high - shows everywhere, makes noise and peeks
    importance: 4,
    
    //Show badge over app icon when non handled pushes are present. Default value: true
    badge: true,
    
    //Show message on locked screen. Default value: 1
    //Possible values (default 1):
    //-1 - secret - Do not reveal any part of the notification on a secure lockscreen.
    //0 - private - Show the notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.
    //1 - public - Show the notification in its entirety on all lockscreens.
    visibility: 1
};

// Create the channel
window.FirebasePlugin.createChannel(channel,
function(){
    console.log('Channel created: ' + channel.id);
},
function(error){
   console.log('Create channel error: ' + error);
});
```

Example FCM v1 API notification message payload for invoking the above example channel:

```json

{
 "notification":
 {
      "title":"Notification title",
      "body":"Notification body"
 },
 "android": {
     "notification": {
       "channel_id": "my_channel_id"
     }
   }
}

```

#### setDefaultChannel
Android 8+ only.
Overrides the properties for the default channel.
The default channel is used if no other channel exists or is specified in the notification.
Any options not specified will not be overridden.
Should be called as soon as possible (on app start) so default notifications will work as expected. 
Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {object} - channel configuration object
- {function} success - callback function which will be call on successfully setting default channel
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
var channel = {
  id: "my_default_channel",
  name: "My Default Name",
  description: "My Default Description",
  sound: "ringtone",
  vibration: [500, 200, 500],
  light: true,
  lightColor: "0xFF0000FF",
  importance: 4,
  badge: false,
  visibility: -1
};

window.FirebasePlugin.setDefaultChannel(channel,
function(){
    console.log('Default channel set');
},
function(error){
   console.log('Set default channel error: ' + error);
});
```

#### Default Android Channel Properties
The default channel is initialised at app startup with the following default settings:

```
{
    id: "fcm_default_channel",
    name: "Default",
    description: "",
    sound: "default",
    vibration: true,
    light: true,
    lightColor: -1,
    importance: 4,
    badge: true,
    visibility: 1
}
```

#### deleteChannel
Android 8+ only.
Removes a previously defined channel.
Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {string} - id of channel to delete
- {function} success - callback function which will be call on successfully deleting channel
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.deleteChannel("my_channel_id",
function(){
    console.log('Channel deleted');
},
function(error){
   console.log('Delete channel error: ' + error);
});

```

#### listChannels 
Android 8+ only.
Gets a list of all channels.
Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {function} success - callback function which will be passed the {array} of channel objects as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.listChannels(
function(channels){
     if(typeof channels == "undefined")
          return;

     for(var i=0;i<channels.length;i++)
     {
          console.log("ID: " + channels[i].id + ", Name: " + channels[i].name);
     }
},
function(error){
   alert('List channels error: ' + error);
});

```

### Analytics
Firebase Analytics enables you to log events in order to track use and behaviour of your apps.

By default, Firebase does not store fine-grain analytics data - only a sample is taken and detailed event data is then discarded.
The Firebase Analytics console is designed to give you a coarse overview of analytics data.

If you want to analyse detailed, event-level analytics you should consider [exporting Firebase Analytics data to BigQuery](https://firebase.google.com/docs/projects/bigquery-export).
The easiest way to set this up is by [streaming Firebase Analytics data into BigQuery](https://cloud.google.com/bigquery/streaming-data-into-bigquery).
Note that until you set this up, all fine-grain event-level data is discarded by Firebase.

#### setAnalyticsCollectionEnabled
Manually enable/disable analytics data collection, e.g. if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**:
- {boolean} setEnabled - whether to enable or disable analytics data collection 

```javascript
window.FirebasePlugin.setAnalyticsCollectionEnabled(true); // Enables analytics data collection

window.FirebasePlugin.setAnalyticsCollectionEnabled(false); // Disables analytics data collection
```

#### logEvent
Log an event using Analytics:

**Parameters**:
- {string} eventName - name of event to log to Firebase Analytics
- {object} eventProperties - key/value object of event properties (must be serializable)

```javascript
window.FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

#### setScreenName
Set the name of the current screen in Analytics:

**Parameters**:
- {string} screenName - name of screen to log to Firebase Analytics

```javascript
window.FirebasePlugin.setScreenName("Home");
```

#### setUserId
Set a user id for use in Analytics:

**Parameters**:
- {string} userName - name of user to set in Firebase Analytics

```javascript
window.FirebasePlugin.setUserId("user_id");
```

#### setUserProperty
Set a user property for use in Analytics:

**Parameters**:
- {string} userName - name of user property to set in Firebase Analytics
- {string} userName - value of user property to set in Firebase Analytics

```javascript
window.FirebasePlugin.setUserProperty("name", "value");
```

### Crashlytics
By default this plugin will ensure fatal native crashes in your apps are reported via Firebase Crashlytics. 

Note that for iOS you may need to [upload the dSYM](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports?authuser=0) for you build before crashes are displayed in the Firebase console.

#### setCrashlyticsCollectionEnabled
Manually enable Crashlytics data collection if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**: None

```javascript
window.FirebasePlugin.setCrashlyticsCollectionEnabled();
```

Note: once enabled, Crashlytics data collection cannot be disabled during the app session.

#### setCrashlyticsUserId
Set Crashlytics user identifier.

To diagnose an issue, it’s often helpful to know which of your users experienced a given crash. Crashlytics includes a way to anonymously identify users in your crash reports.
To add user IDs to your reports, assign each user a unique identifier in the form of an ID number, token, or hashed value.

See [the Firebase docs for more](https://firebase.google.com/docs/crashlytics/customize-crash-reports?authuser=0#set_user_ids).

**Parameters**:
- {string} userId - User ID to associate with Crashlytics reports

```javascript
window.FirebasePlugin.setCrashlyticsUserId("user_id");
```


#### sendCrash
Simulates (causes) a fatal native crash which causes a crash event to be sent to Crashlytics (useful for testing).
See [the Firebase documentation](https://firebase.google.com/docs/crashlytics/force-a-crash?authuser=0#force_a_crash_to_test_your_implementation) regarding crash testing.
Crashes will appear under `Event type = "Crashes"` in the Crashlytics console.

**Parameters**: None

```javascript
window.FirebasePlugin.sendCrash();
```

#### logMessage
Sends a crash-related log message that will appear in the `Logs` section of the next native crash event.
Note: if you don't then crash, the message won't be sent!
Also logs the message to the native device console.

**Parameters**:
- {string} message - message to associate with next native crash event

```javascript
window.FirebasePlugin.logMessage("about to send a crash for testing!");
window.FirebasePlugin.sendCrash();
```

#### logError
Sends a non-fatal error event to Crashlytics.
In a Cordova app, you may use this to log unhandled Javascript exceptions, for example.

The event will appear under `Event type = "Non-fatals"` in the Crashlytics console.
The error message will appear in the `Logs` section of the non-fatal error event.
Also logs the error message to the native device console.

**Parameters**:
- {string} errorMessage - non-fatal error message to log to Crashlytics
- {object} stackTrace - (optional) a stack trace generated by [stacktrace.js](http://www.stacktracejs.com/)
- {function} success - (optional) callback function which will be invoked on success
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
    // Send an unhandled JS exception
    var appRootURL = window.location.href.replace("index.html",'');
    window.onerror = function(errorMsg, url, line, col, error) {
        var logMessage = errorMsg;
        var stackTrace = null;

        var sendError = function(){
            FirebasePlugin.logError(logMessage, stackTrace, function(){
                console.log("Sent JS exception");
            },function(error){
                console.error("Failed to send JS exception", error);
            });
        };

        logMessage += ': url='+url.replace(appRootURL, '')+'; line='+line+'; col='+col;

        if(typeof error === 'object'){
            StackTrace.fromError(error).then(function(trace){
                stackTrace = trace;
                sendError()
            });
        }else{
            sendError();
        }
    };
    
    // Send a non-fatal error
    FirebasePlugin.logError("A non-fatal error", function(){
        console.log("Sent non-fatal error");
    },function(error){
        console.error("Failed to send non-fatal error", error);
    });
```

An example of how the error entry will appear in the Crashlytics console:

<br/>
<b>Android</b>
<br/>
<img src="https://user-images.githubusercontent.com/2345062/68016874-5e0cdb80-fc8d-11e9-9a26-97b448039cf5.png"/>

<br/><br/>
<b>iOS</b>
<br/>
<img src="https://user-images.githubusercontent.com/2345062/68041597-d1800e80-fcc8-11e9-90e1-eeeedf9cc43f.png"/>



### Authentication

#### verifyPhoneNumber
Requests verification of a phone number in order to authenticate a user and sign then into Firebase in your app.

**NOTE: This will only work on physical devices with a SIM card (not iOS Simulator or Android Emulator)**

In response to your request, you'll receive a verification ID which you can use in conjunction with the verification code to sign the user in.

On iOS and some Android devices, the user will receive and SMS containing the verification code which they must manually enter into your app.

Some Android devices support "instant verfication", in which case an SMS will not be send and you will be returned the verification code along with the verification ID.
In this case, the user doesn't need to do anything in order for you to sign them in.  

**Parameters**:
- {function} success - callback function to pass {object} credentials to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument
- {string} phoneNumber - phone number to verify
- {integer} timeOutDuration - (optional) time to wait in seconds before timing out
- {string} fakeVerificationCode - (optional) to test instant verification on Android ,specify a fake verification code to return for whitelisted phone numbers.
    - See [Firebase SDK Phone Auth Android Integration Testing](https://firebase.google.com/docs/auth/android/phone-auth#integration-testing) for more info.

The success callback will be passed a credential object with the following properties:
- instantVerification {boolean} - true if the Android device supports instant verification, in which case the verification code will be included in the credential object.
If this is false, the device will be sent an SMS containing the verification code for the user to manually enter into your app.
Always false on iOS.
- verificationId {string} - the verification ID you'll need to pass along with the verification code to sign the user in.
Always returned on both Android & iOS.
- code {string} - verification code. Will only be present if `instantVerification` is true. Always undefined on iOS.

Example usage:

```javascript
var number = '+441234567890';
var timeOutDuration = 60;
var fakeVerificationCode = '123456';
var verificationId;
window.FirebasePlugin.verifyPhoneNumber(function(credential) {

    verificationId = credential.verificationId;
    if(credential.instantVerification){
        signInWithCredential(credential.code);
    }else{
        promptUserToInputCode() // you need to implement this
            .then(function(userEnteredCode){
               signInWithCredential(userEnteredCode); 
            });
    }
}, function(error) {
    console.error("Failed to verify phone number: " + JSON.stringify(error));
}, number, timeOutDuration, fakeVerificationCode);

function signInWithCredential(code){
    FirebasePlugin.signInWithCredential(verificationId, code, function() {
        console.log("Successfully signed in");
    }, function(error) {
        console.error("Failed to sign in", error);
    });
}
```

##### Android
To use phone auth with your Android app, you need to configure your app SHA-1 hash in the android app configuration in the Firebase console.
See [this guide](https://developers.google.com/android/guides/client-auth) to find how to your SHA-1 app hash.
See the [Firebase phone auth integration guide for native Android](https://firebase.google.com/docs/auth/android/phone-auth) for more information.

##### iOS
When you call this method on iOS, FCM sends a silent push notification to the iOS device to verify it.
So to use phone auth with your Android app, you need to:
- [setup your iOS app for push notifications](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- Verify that push notifications are arriving on your physical device
- [Upload your APNs auth key to the Firebase console](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_authentication_key).

You can [set up reCAPTCHA verification for iOS](https://firebase.google.com/docs/auth/ios/phone-auth#set-up-recaptcha-verification) automatically by specifying the `SETUP_RECAPTCHA_VERIFICATION` plugin variable at plugin install time:
  
    cordova plugin add cordova-plugin-firebasex --variable SETUP_RECAPTCHA_VERIFICATION=true

This adds the `REVERSED_CLIENT_ID` from the `GoogleService-Info.plist` to the list of custom URL schemes in your Xcode project, so you don't need to do this manually.

#### signInWithCredential
Signs the user into Firebase with credentials obtained using `verifyPhoneNumber()`.
See the [Android-](https://firebase.google.com/docs/auth/android/phone-auth#sign-in-the-user) and [iOS](https://firebase.google.com/docs/auth/ios/phone-auth#sign-in-the-user-with-the-verification-code)-specific Firebase documentation for more info.

**Parameters**:
- {string} verificationId - the verification ID returned in the credentials object to the `verifyPhoneNumber()` success callback.
- {string} code - the activation code, either returned in the credentials object to the `verifyPhoneNumber()` success callback if using Instant Verification on Android, or the activation code as entered by the user from the received SMS message. 
- {function} success - callback function to call on successful sign-in using credentials
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
var number = '+441234567890';
var timeOutDuration = 60;
var fakeVerificationCode = '123456';
var verificationId;
window.FirebasePlugin.verifyPhoneNumber(function(credential) {

    verificationId = credential.verificationId;
    if(credential.instantVerification){
        signInWithCredential(credential.code);
    }else{
        promptUserToInputCode() // you need to implement this
            .then(function(userEnteredCode){
               signInWithCredential(userEnteredCode); 
            });
    }
}, function(error) {
    console.error("Failed to verify phone number: " + JSON.stringify(error));
}, number, timeOutDuration, fakeVerificationCode);

function signInWithCredential(code){
    FirebasePlugin.signInWithCredential(verificationId, code, function() {
        console.log("Successfully signed in");
    }, function(error) {
        console.error("Failed to sign in", error);
    });
}
```

#### linkUserWithCredential
Links the user account to an existing Firebase user account with credentials obtained using `verifyPhoneNumber()`.
See the [Android-](https://firebase.google.com/docs/auth/android/account-linking) and [iOS](https://firebase.google.com/docs/auth/ios/account-linking)-specific Firebase documentation for more info.

**Parameters**:
- {string} verificationId - the verification ID returned in the credentials object to the `verifyPhoneNumber()` success callback.
- {string} code - the activation code, either returned in the credentials object to the `verifyPhoneNumber()` success callback if using Instant Verification on Android, or the activation code as entered by the user from the received SMS message. 
- {function} success - callback function to call on successful linking using credentials
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
var number = '+441234567890';
var timeOutDuration = 60;
var fakeVerificationCode = '123456';
var verificationId;
window.FirebasePlugin.verifyPhoneNumber(function(credential) {

    verificationId = credential.verificationId;
    if(credential.instantVerification){
        linkUserWithCredential(credential.code);
    }else{
        promptUserToInputCode() // you need to implement this
            .then(function(userEnteredCode){
               linkUserWithCredential(userEnteredCode); 
            });
    }
}, function(error) {
    console.error("Failed to verify phone number: " + JSON.stringify(error));
}, number, timeOutDuration, fakeVerificationCode);

function linkUserWithCredential(code){
    FirebasePlugin.linkUserWithCredential(verificationId, code, function() {
        console.log("Successfully linked");
    }, function(error) {
        console.error("Failed to link", error);
    });
}
```


### Remote Config

#### fetch
Fetch Remote Config parameter values for your app:

**Parameters**:
- {integer} cacheExpirationSeconds (optional) - cache expiration in seconds
- {function} success - callback function on successfully fetching remote config
- {function} error - callback function which will be passed a {string} error message as an argument

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

#### activateFetched
Activate the Remote Config fetched config:

**Parameters**:
- {function} success - callback function which will be passed a {boolean} argument indicating whether fetched config was successfully activated
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.activateFetched(function(activated) {
    // activated will be true if there was a fetched config activated,
    // or false if no fetched config was found, or the fetched config was already activated.
    console.log(activated);
}, function(error) {
    console.error(error);
});
```

#### getValue
Retrieve a Remote Config value:

**Parameters**:
- {string} key - key for which to fetch associated value
- {function} success - callback function which will be passed a {any} argument containing the value stored against the specified key.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.getValue("key", function(value) {
    console.log(value);
}, function(error) {
    console.error(error);
});
```

#### getByteArray
Android only.
Retrieve a Remote Config byte array:

**Parameters**:
- {string} key - key for which to fetch associated value
- {function} success - callback function which will be passed a {string} argument containing the Base64 encoded string that represents the value stored against the specified key.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
window.FirebasePlugin.getByteArray("key", function(bytes) {
    // a Base64 encoded string that represents the value for "key"
    console.log(bytes.base64);
    // a numeric array containing the values of the byte array (i.e. [0xFF, 0x00])
    console.log(bytes.array);
}, function(error) {
    console.error(error);
});
```

#### getInfo
Android only.
Get the current state of the FirebaseRemoteConfig singleton object:

**Parameters**:
- {function} success - callback function which will be passed an {object} argument containing the state info
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
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

#### setConfigSettings
Android only.
Change the settings for the FirebaseRemoteConfig object's operations:

**Parameters**:
- {object} configSettings - object specifying the remote config settings
- {function} success - callback function to be call on successfully setting the remote config settings
- {function} error - callback function which will be passed a {string} error message as an argument

```
var settings = {
    developerModeEnabled: true
}
window.FirebasePlugin.setConfigSettings(settings);
```

#### setDefaults
Android only.
Set defaults in the Remote Config:

**Parameters**:
- {object} defaultSettings - object specifying the default remote config settings
- {function} success - callback function to be call on successfully setting the remote config setting defaults
- {function} error - callback function which will be passed a {string} error message as an argument

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

### Performance

#### setPerformanceCollectionEnabled
Manually enable/disable performance data collection, e.g. if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**:
- {boolean} setEnabled - whether to enable or disable performance data collection

```
window.FirebasePlugin.setPerformanceCollectionEnabled(true); // Enables performance data collection

window.FirebasePlugin.setPerformanceCollectionEnabled(false); // Disables performance data collection
```

#### startTrace

Start a trace.

**Parameters**:
- {string} name - name of trace to start 
- {function} success - callback function to call on successfully starting trace
- {function} error - callback function which will be passed a {string} error message as an argument

```
window.FirebasePlugin.startTrace("test trace", success, error);
```

#### incrementCounter

To count the performance-related events that occur in your app (such as cache hits or retries), add a line of code similar to the following whenever the event occurs, using a string other than retry to name that event if you are counting a different type of event:

**Parameters**:
- {string} name - name of trace
- {string} counterName - name of counter to increment 
- {function} success - callback function to call on successfully incrementing counter
- {function} error - callback function which will be passed a {string} error message as an argument

```
window.FirebasePlugin.incrementCounter("test trace", "retry", success, error);
```

#### stopTrace

Stop the trace

**Parameters**:
- {string} name - name of trace to stop 
- {function} success - callback function to call on successfully stopping trace
- {function} error - callback function which will be passed a {string} error message as an argument

```
window.FirebasePlugin.stopTrace("test trace");
```


# Credits
- [@robertarnesson](https://github.com/robertarnesson) for the original [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) from which this plugin is forked.
- [@sagrawal31](https://github.com/sagrawal31) and [Wiz Panda](https://github.com/wizpanda) for contributions via [cordova-plugin-firebase-lib](https://github.com/wizpanda/cordova-plugin-firebase-lib).
- [Full list of contributors](https://github.com/dpa99c/cordova-plugin-firebasex/graphs/contributors)

cordova-plugin-firebasex [![Latest Stable Version](https://img.shields.io/npm/v/cordova-plugin-firebasex.svg)](https://www.npmjs.com/package/cordova-plugin-firebasex) [![Total Downloads](https://img.shields.io/npm/dt/cordova-plugin-firebasex.svg)](https://npm-stat.com/charts.html?package=cordova-plugin-firebasex)
========================

Brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project.

Supported platforms: Android and iOS

**IMPORTANT:** Before opening an issue against this plugin, please read [Reporting issues](#reporting-issues).

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
  - [Supported Mobile Platform Versions](#supported-mobile-platform-versions)
  - [Migrating from cordova-plugin-firebase](#migrating-from-cordova-plugin-firebase)
    - [Breaking API changes](#breaking-api-changes)
    - [Ionic 4+](#ionic-4)
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
    - [Cordova CLI builds](#cordova-cli-builds)
- [Firebase config setup](#firebase-config-setup)
- [Disable data collection on startup](#disable-data-collection-on-startup)
- [Example project](#example-project)
- [Reporting issues](#reporting-issues)
  - [Reporting a bug or problem](#reporting-a-bug-or-problem)
  - [Requesting a new feature](#requesting-a-new-feature)
- [Cloud messaging](#cloud-messaging)
  - [Background notifications](#background-notifications)
  - [Foreground notifications](#foreground-notifications)
  - [Android notifications](#android-notifications)
    - [Android background notifications](#android-background-notifications)
    - [Android foreground notifications](#android-foreground-notifications)
    - [Android Notification Channels](#android-notification-channels)
    - [Android Notification Icons](#android-notification-icons)
    - [Android Notification Color](#android-notification-color)
    - [Android Notification Sound](#android-notification-sound)
    - [Android cloud message types](#android-cloud-message-types)
  - [iOS notifications](#ios-notifications)
    - [iOS background notifications](#ios-background-notifications)
    - [iOS notification sound](#ios-notification-sound)
    - [iOS critical notifications](#ios-critical-notifications)
    - [iOS badge number](#ios-badge-number)
    - [iOS actionable notifications](#ios-actionable-notifications)
    - [iOS notification settings button](#ios-notification-settings-button)
  - [Data messages](#data-messages)
    - [Data message notifications](#data-message-notifications)
  - [Custom FCM message handling](#custom-fcm-message-handling)
    - [Android](#android)
    - [iOS](#ios)
    - [Example](#example)
- [InApp Messaging](#inapp-messaging)
- [Google Tag Manager](#google-tag-manager)
  - [Android](#android-1)
  - [iOS](#ios-1)
- [Performance Monitoring](#performance-monitoring)
  - [Android Performance Monitoring Gradle plugin](#android-performance-monitoring-gradle-plugin)
- [API](#api)
  - [Notifications and data messages](#notifications-and-data-messages)
    - [getToken](#gettoken)
    - [getId](#getid)
    - [onTokenRefresh](#ontokenrefresh)
    - [getAPNSToken](#getapnstoken)
    - [onApnsTokenReceived](#onapnstokenreceived)
    - [onOpenSettings](#onopensettings)
    - [onMessageReceived](#onmessagereceived)
    - [grantPermission](#grantpermission)
    - [grantCriticalPermission](#grantcriticalpermission)
    - [hasPermission](#haspermission)
    - [hasCriticalPermission](#hascriticalpermission)
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
    - [isAnalyticsCollectionEnabled](#isanalyticscollectionenabled)
    - [logEvent](#logevent)
    - [setScreenName](#setscreenname)
    - [setUserId](#setuserid)
    - [setUserProperty](#setuserproperty)
  - [Crashlytics](#crashlytics)
    - [setCrashlyticsCollectionEnabled](#setcrashlyticscollectionenabled)
    - [didCrashOnPreviousExecution](#didcrashonpreviousexecution)
    - [isCrashlyticsCollectionEnabled](#iscrashlyticscollectionenabled)
    - [setCrashlyticsUserId](#setcrashlyticsuserid)
    - [sendCrash](#sendcrash)
    - [setCrashlyticsCustomKey](#setcrashlyticscustomkey)
    - [logMessage](#logmessage)
    - [logError](#logerror)
  - [Authentication](#authentication)
    - [isUserSignedIn](#isusersignedin)
    - [signOutUser](#signoutuser)
    - [getCurrentUser](#getcurrentuser)
    - [reloadCurrentUser](#reloadcurrentuser)
    - [updateUserProfile](#updateuserprofile)
    - [updateUserEmail](#updateuseremail)
    - [sendUserEmailVerification](#senduseremailverification)
    - [updateUserPassword](#updateuserpassword)
    - [sendUserPasswordResetEmail](#senduserpasswordresetemail)
    - [deleteUser](#deleteuser)
    - [createUserWithEmailAndPassword](#createuserwithemailandpassword)
    - [signInUserWithEmailAndPassword](#signinuserwithemailandpassword)
    - [signInUserWithCustomToken](#signinuserwithcustomtoken)
    - [signInUserAnonymously](#signinuseranonymously)
    - [verifyPhoneNumber](#verifyphonenumber)
    - [setLanguageCode](#setlanguagecode)
    - [authenticateUserWithEmailAndPassword](#authenticateuserwithemailandpassword)
    - [authenticateUserWithGoogle](#authenticateuserwithgoogle)
    - [authenticateUserWithApple](#authenticateuserwithapple)
    - [authenticateUserWithMicrosoft](#authenticateuserwithmicrosoft)
    - [signInWithCredential](#signinwithcredential)
    - [linkUserWithCredential](#linkuserwithcredential)
    - [reauthenticateWithCredential](#reauthenticatewithcredential)
    - [registerAuthStateChangeListener](#registerauthstatechangelistener)
    - [useAuthEmulator](#useauthemulator)
    - [getClaims](#getclaims)
  - [Remote Config](#remote-config)
    - [fetch](#fetch)
    - [activateFetched](#activatefetched)
    - [fetchAndActivate](#fetchandactivate)
    - [resetRemoteConfig](#resetremoteconfig)
    - [getValue](#getvalue)
    - [getInfo](#getinfo)
    - [getAll](#getall)
    - [setConfigSettings](#setconfigsettings)
    - [setDefaults](#setdefaults)
  - [Performance](#performance)
    - [setPerformanceCollectionEnabled](#setperformancecollectionenabled)
    - [isPerformanceCollectionEnabled](#isperformancecollectionenabled)
    - [startTrace](#starttrace)
    - [incrementCounter](#incrementcounter)
    - [stopTrace](#stoptrace)
  - [Firestore](#firestore)
    - [addDocumentToFirestoreCollection](#adddocumenttofirestorecollection)
    - [setDocumentInFirestoreCollection](#setdocumentinfirestorecollection)
    - [updateDocumentInFirestoreCollection](#updatedocumentinfirestorecollection)
    - [deleteDocumentFromFirestoreCollection](#deletedocumentfromfirestorecollection)
    - [documentExistsInFirestoreCollection](#documentexistsinfirestorecollection)
    - [fetchDocumentInFirestoreCollection](#fetchdocumentinfirestorecollection)
    - [fetchFirestoreCollection](#fetchfirestorecollection)
    - [listenToDocumentInFirestoreCollection](#listentodocumentinfirestorecollection)
    - [listenToFirestoreCollection](#listentofirestorecollection)
    - [removeFirestoreListener](#removefirestorelistener)
  - [Functions](#functions)
    - [functionsHttpsCallable](#functionshttpscallable)
  - [Installations](#installations)
    - [getInstallationId](#getinstallationid)
    - [getInstallationToken](#getinstallationtoken)
    - [getInstallationId](#getinstallationid-1)
    - [registerInstallationIdChangeListener](#registerinstallationidchangelistener)
- [Credits](#credits)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Installation
Install the plugin by adding it to your project's config.xml:
```xml
<plugin name="cordova-plugin-firebasex" spec="latest" />
```
or by running:
```
cordova plugin add cordova-plugin-firebasex
```

## Plugin variables
The following Cordova plugin variables are supported by the plugin.
Note that these must be set at plugin installation time. If you wish to change plugin variables, you'll need to uninstall the plugin and reinstall it with the new variable values.

### Android & iOS
- `FIREBASE_ANALYTICS_COLLECTION_ENABLED` - whether to automatically enable Firebase Analytics data collection on app startup
- `FIREBASE_PERFORMANCE_COLLECTION_ENABLED` - whether to automatically enable Firebase Performance data collection on app startup
- `FIREBASE_CRASHLYTICS_COLLECTION_ENABLED` - whether to automatically enable Firebase Crashlytics data collection on app startup
- `FIREBASE_FCM_AUTOINIT_ENABLED` - whether to automatically enable FCM registration on app startup
See [Disable data collection on startup](#disable-data-collection-on-startup) for more info.

### Android only
The following plugin variables are used to specify the Firebase SDK versions as Gradle dependencies on Android:
- `ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION`
- `ANDROID_PLAY_SERVICES_AUTH_VERSION`
- `ANDROID_FIREBASE_ANALYTICS_VERSION`
- `ANDROID_FIREBASE_MESSAGING_VERSION`
- `ANDROID_FIREBASE_CONFIG_VERSION`
- `ANDROID_FIREBASE_PERF_VERSION`
- `ANDROID_FIREBASE_AUTH_VERSION`
- `$ANDROID_FIREBASE_INAPPMESSAGING_VERSION`
- `ANDROID_FIREBASE_FIRESTORE_VERSION`
- `ANDROID_FIREBASE_FUNCTIONS_VERSION`
- `ANDROID_FIREBASE_INSTALLATIONS_VERSION`
- `ANDROID_FIREBASE_CRASHLYTICS_VERSION`
- `ANDROID_FIREBASE_CRASHLYTICS_NDK_VERSION`
- `ANDROID_GSON_VERSION`
- `ANDROID_FIREBASE_PERF_GRADLE_PLUGIN_VERSION`
- `ANDROID_FIREBASE_PERFORMANCE_MONITORING`
See [Specifying Android library versions](#specifying-android-library-versions) for more info.

- `ANDROID_ICON_ACCENT` - sets the default accent color for system notifications. See [Android Notification Color](#android-notification-color) for more info.
- `ANDROID_FIREBASE_CONFIG_FILEPATH` - sets a custom filepath to `google-services.json` file as a path relative to the project root
    - e.g. `--variable ANDROID_FIREBASE_CONFIG_FILEPATH="resources/android/google-services.json"`
- `ANDROID_FIREBASE_PERFORMANCE_MONITORING` - sets whether to add the [Firebase Performance Monitoring Gradle plugin for Android](https://firebase.google.com/docs/perf-mon/get-started-android?authuser=0#add-perfmon-plugin) to the build.
    - e.g.  `--variable ANDROID_FIREBASE_PERFORMANCE_MONITORING=true`
    - Defaults to `false` if not specified.
- `ANDROID_FIREBASE_PERF_GRADLE_PLUGIN_VERSION` - overrides the default version of the [Firebase Performance Monitoring Gradle plugin for Android](https://firebase.google.com/docs/perf-mon/get-started-android?authuser=0#add-perfmon-plugin)
- `ANDROID_GRPC_OKHTTP` - sets version of GRPC OKHTTP library.

### iOS only
- `IOS_FIREBASE_SDK_VERSION` - a specific version of the Firebase iOS SDK to set in the Podfile
  - If not specified, the default version defined in `<pod>` elements in the `plugin.xml` will be used.
- `IOS_GOOGLE_SIGIN_VERSION` - a specific version of the Google Sign In library to set in the Podfile
  - If not specified, the default version defined in the `<pod>` element in the `plugin.xml` will be used.
- `IOS_GOOGLE_TAG_MANAGER_VERSION` - a specific version of the Google Tag Manager library to set in the Podfile
  - If not specified, the default version defined in the `<pod>` element in the `plugin.xml` will be used.
- `IOS_USE_PRECOMPILED_FIRESTORE_POD` - if `true`, switches Podfile to use a [pre-compiled version of the Firestore pod](https://github.com/invertase/firestore-ios-sdk-frameworks.git) to reduce build time
  - Since some users experienced long build times due to the Firestore pod (see [#407](https://github.com/dpa99c/cordova-plugin-firebasex/issues/407))
  - However other users have experienced build issues with the pre-compiled version (see [#735](https://github.com/dpa99c/cordova-plugin-firebasex/issues/735))
  - Defaults to `false` if not specified.
- `IOS_STRIP_DEBUG` - prevents symbolification of all libraries included via Cocoapods. See [Strip debug symbols](#strip-debug-symbols) for more info.
    - e.g.  `--variable IOS_STRIP_DEBUG=true`
    - Defaults to `false` if not specified.
- `SETUP_RECAPTCHA_VERIFICATION` - automatically sets up reCAPTCHA verification for phone authentication on iOS. See [verifyPhoneNumber](#verifyphonenumber) for more info.
    - e.g.  `--variable IOS_STRIP_DEBUG=true`
    - Defaults to `false` if not specified.
- `IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL` - If `true` Firebase Messaging will automatically establish a socket-based, direct channel to the FCM server.
   - e.g.  `--variable IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL=true`
   - Defaults to `false` if not specified.
   - See [`shouldEstablishDirectChannel`](https://firebase.google.com/docs/reference/ios/firebasemessaging/api/reference/Classes/FIRMessaging#/c:objc(cs)FIRMessaging(py)shouldEstablishDirectChannel)
   - Note: Firebase Messaging iOS SDK version 7.0 will be a breaking change where the SDK will no longer support iOS Direct Channel API.
- `IOS_FIREBASE_CONFIG_FILEPATH` - sets a custom filepath to `GoogleService-Info.plist` file as a path relative to the project root
    - e.g. `--variable IOS_FIREBASE_CONFIG_FILEPATH="resources/ios/GoogleService-Info.plist"`
- `IOS_ENABLE_APPLE_SIGNIN` - enables the Sign In with Apple capability in Xcode.
    - `--variable IOS_ENABLE_APPLE_SIGNIN=true`
    - Ensure the associated app provisioning profile also has this capability enabled.
- `IOS_ENABLE_CRITICAL_ALERTS_ENABLED` - enables the critical alerts capability
  - `--variable IOS_ENABLE_CRITICAL_ALERTS_ENABLED=true`
  - See [iOS critical notifications](#ios-critical-notifications)
  - Ensure the associated app provisioning profile also has this capability enabled.

## Supported Cordova Versions
- cordova: `>= 9`
- cordova-android: `>= 9`
- cordova-ios: `>= 6`

## Supported Mobile Platform Versions
- Android `>= 4.1`
- iOS `>= 10.0`

## Migrating from cordova-plugin-firebase
This plugin is a fork of [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) which has been reworked to fix issues and add new functionality.
If you already have [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) installed in your Cordova project, you need to completely remove it before installing this plugin otherwise they will conflict and cause build errors in your project. The safest way of doing this is as follows:

    rm -Rf platforms/android
    cordova plugin rm cordova-plugin-firebase
    rm -Rf plugins/ node_modules/
    npm install
    cordova plugin add cordova-plugin-firebasex
    cordova platform add android

### Breaking API changes
**IMPORTANT:** Recent versions of `cordova-plugin-firebasex` have made breaking changes to the plugin API in order to fix bugs or add more functionality.
Therefore you can no longer directly substitute `cordova-plugin-firebasex` in place of `cordova-plugin-firebase` without making code changes.

You should be aware of the following breaking changes compared with `cordova-plugin-firebase`:
* Minimum supported Cordova versions
    * `cordova@10` (CLI)
    * `cordova-android@10` (Android platform)
    * `cordova-ios@6` (iOS platform)
* Migrated to AndroidX from legacy Android Support Library
* Migrated to Cocoapods to satisfy Firebase SDK dependencies on iOS
* `onNotificationOpen()` renamed to `onMessageReceived()`
    * `tap` parameter is only set when user taps on a notification (not when a message is received from FCM)
    * `tap=foreground|background` instead of `tap=true|false`
* `hasPermission()` receives argument as a boolean (rather than an object with `isEnabled` key)
    * e.g. `FirebasePlugin.hasPermission(function(hasPermission){
               console.log("Permission is " + (hasPermission ? "granted" : "denied"));
           });`
* Adds support for foreground notifications and data notification messages

### Ionic 4+
Ionic Native provides a [FirebaseX Typescript wrapper](https://ionicframework.com/docs/native/firebase-x) for using `cordova-plugin-firebasex` with Ionic v4, v5 and above.
Please see their documentation for usage.

First install the package.

```
ionic cordova plugin add cordova-plugin-firebasex
npm install @ionic-native/firebase-x
```

If you're using Angular, register it in your component/service's `NgModule` (for example, app.module.ts) as a provider.

```typescript
import { FirebaseX } from "@ionic-native/firebase-x/ngx";

@NgModule({
    //declarations, imports...
    providers: [
        FirebaseX,
        //other providers...
    ]
})
```

Then you're good to go.
```typescript
import { FirebaseX } from "@ionic-native/firebase-x/ngx";

//...

constructor(private firebase: FirebaseX)

this.firebase.getToken().then(token => console.log(`The token is ${token}`))
this.firebase.onMessageReceived().subscribe(data => console.log(`FCM message: ${data}`));
```

**NOTE:**
- This plugin provides only the Javascript API as documented below.
- The Typescript wrapper is owned and maintain by Ionic.
- Please [report any issues](https://github.com/ionic-team/ionic-native/issues) against the [Ionic Native repo](https://github.com/ionic-team/ionic-native/), not this one.
- Any issues opened against this repo which relate to the Typescript wrapper **will be closed immediately**.


### Ionic 3
The above PR does not work for Ionic 3 so you (currently) can't use the [Ionic Native Firebase](https://ionicframework.com/docs/native/firebase) Typescript wrapper with Ionic 3.
(i.e. `import { Firebase } from "@ionic-native/firebase"` will not work).

To use `cordova-plugin-firebasex` with Ionic 3, you'll need to call its Javascript API directly from your Typescript app code, for example:

```typescript
(<any>window).FirebasePlugin.getToken(token => console.log(`token: ${token}`))

(<any>window).FirebasePlugin.onMessageReceived((message) => {
    if (message.tap) { console.log(`Notification was tapped in the ${message.tap}`); }
})
```

If you want to make the `onMessageReceived()` JS API behave like the Ionic Native wrapper:

```javascript
onNotificationOpen() {
      return new Observable(observer => {
            (window as any).FirebasePlugin.onMessageReceived((response) => {
                observer.next(response);
            });
       });
}
...
this.onNotificationOpen().subscribe(data => console.log(`FCM message: ${data}`));
```

See the [cordova-plugin-firebasex-ionic3-test](https://github.com/dpa99c/cordova-plugin-firebasex-ionic3-test) example project for a demonstration of how to use the plugin with Ionic 3.

# Build environment notes

## PhoneGap Build
This plugin will not work with Phonegap Build (and other remote cloud build envs) do not support Cordova hook scripts as they are used by this plugin to configure the native platform projects.

## Android-specific

### Specifying Android library versions
This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Gradle on Android.
By default this plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebase/blob/master/plugin.xml) where you can find the currently pinned versions as `<preference>`'s, for example:

```xml
<preference name="ANDROID_FIREBASE_ANALYTICS_VERSION" default="17.0.0" />
```

The Android defaults can be overridden at plugin installation time by specifying plugin variables as command-line arguments, for example:

    cordova plugin add cordova-plugin-firebasex --variable ANDROID_FIREBASE_ANALYTICS_VERSION=17.0.0

Or you can specify them as plugin variables in your `config.xml`, for example:

```xml
<plugin name="cordova-plugin-firebasex" spec="latest">
    <variable name="ANDROID_FIREBASE_ANALYTICS_VERSION" value="17.0.0" />
</plugin>
```

The following plugin variables are used to specify the following Gradle dependency versions on Android:

- `ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION` => `com.google.android.gms:play-services-tagmanager`
- `ANDROID_PLAY_SERVICES_AUTH_VERSION` => `com.google.android.gms:play-services-auth`
- `ANDROID_FIREBASE_ANALYTICS_VERSION` => `com.google.firebase:firebase-analytics`
- `ANDROID_FIREBASE_MESSAGING_VERSION` => `com.google.firebase:firebase-messaging`
- `ANDROID_FIREBASE_CONFIG_VERSION` => `com.google.firebase:firebase-config`
- `ANDROID_FIREBASE_PERF_VERSION` => `com.google.firebase:firebase-perf`
- `ANDROID_FIREBASE_AUTH_VERSION` => `com.google.firebase:firebase-auth`
- `ANDROID_FIREBASE_FIRESTORE_VERSION` => `com.google.firebase:firebase-firestore`
- `$ANDROID_FIREBASE_FUNCTIONS_VERSION` => `com.google.firebase:firebase-functions`
- `$ANDROID_FIREBASE_INSTALLATIONS_VERSION` => `com.google.firebase:firebase-installations`
- `$ANDROID_FIREBASE_INAPPMESSAGING_VERSION` => `com.google.firebase:firebase-inappmessaging-display`
- `ANDROID_FIREBASE_CRASHLYTICS_VERSION` => `com.google.firebase:firebase-crashlytics`
- `ANDROID_FIREBASE_CRASHLYTICS_NDK_VERSION` => `com.google.firebase:firebase-crashlytics-ndk`
- `ANDROID_GSON_VERSION` => `com.google.code.gson:gson`

For example:

    cordova plugin add cordova-plugin-firebasex \
        --variable ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION=17.0.0 \
        --variable ANDROID_PLAY_SERVICES_AUTH_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_ANALYTICS_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_MESSAGING_VERSION=19.0.0 \
        --variable ANDROID_FIREBASE_CONFIG_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_PERF_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_AUTH_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_CRASHLYTICS_VERSION=17.0.1 \
        --variable ANDROID_FIREBASE_CRASHLYTICS_NDK_VERSION=17.0.1 \

### AndroidX
This plugin has been migrated to use [AndroidX (Jetpack)](https://developer.android.com/jetpack/androidx/migrate) which is the successor to the [Android Support Library](https://developer.android.com/topic/libraries/support-library/index).
This is because the [major release of the Firebase and Play Services libraries on 17 June 2019](https://developers.google.com/android/guides/releases#june_17_2019) were migrated to AndroidX.

The `cordova-android@9` platform adds implicit support for AndroidX so (if you haven't already done so) you should update to this platform version:

    cordova platform rm android && cordova platform add android@latest

and enable AndroidX by setting the following preference in your `config.xml`:

    <preference name="AndroidXEnabled" value="true" />

If you are unable to update from `cordova-android@8`, you can add [cordova-plugin-androidx](https://github.com/dpa99c/cordova-plugin-androidx) to your project which enables AndroidX in the Android platform project:

    cordova plugin add cordova-plugin-androidx

If your project includes any plugins which are dependent on the legacy Android Support Library (to which AndroidX is the successor), you should add [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter) to your project which will dynamically migrate any plugin code from the Android Support Library to AndroidX equivalents:

    cordova plugin add cordova-plugin-androidx-adapter

## Google Play Services and Firebase libraries
Your Android build may fail if you are installing multiple plugins that use the Google Play Services library.
This is caused by plugins installing different versions of the Google Play Services library.
This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release) which enables you to override the versions specified by other plugins in order to align them.

Similarly, if your build is failing because multiple plugins are installing different versions of the Firebase library,
you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release) to align these.

## iOS-specific
Please ensure you have the latest Xcode release version installed to build your app - direct download links can be [found here](https://stackoverflow.com/a/10335943/777265).

### Specifying iOS library versions
This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Cocoapods on iOS.
This plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebase/blob/master/plugin.xml) where you can find the currently pinned iOS versions in the  `<pod>`'s, for example:

    <pod name="Firebase/Core" spec="6.3.0"/>

Cordova does not natively support the use of plugin variables in the `<pod>`'s `spec` attribute, however this plugin uses a hook script to enable this behaviour by overriding the version specified in `plugin.xml` directly within the `Podfile`.
Therefore to override the version of the Firebase iOS SDK components set in the `plugin.xml`, you should define it using the `IOS_FIREBASE_SDK_VERSION` plugin variable when installing the plugin into your project.
For example:

    cordova plugin add cordova-plugin-firebasex --variable IOS_FIREBASE_SDK_VERSION=9.1.0

### Cocoapods
This plugin relies on Cordova support for the [CocoaPods dependency manager]( https://cocoapods.org/) in order to satisfy the iOS Firebase SDK library dependencies.

Please make sure you have `cocoapods@>=1.11.2` installed in your iOS build environment - setup instructions can be found [here](https://cocoapods.org/).

If building your project in Xcode, you need to open `YourProject.xcworkspace` (not `YourProject.xcodeproj`) so both your Cordova app project and the Pods project will be loaded into Xcode.

You can list the pod dependencies in your Cordova iOS project by installing [cocoapods-dependencies](https://github.com/segiddins/cocoapods-dependencies):

    sudo gem install cocoapods-dependencies
    cd platforms/ios/
    pod dependencies

### Out-of-date pods
If you receive a build error such as this:

    None of your spec sources contain a spec satisfying the dependencies: `Firebase/Analytics (~> 6.1.0), Firebase/Analytics (= 6.1.0, ~> 6.1.0)`.

Make sure your local Cocoapods repo is up-to-date by running `pod repo update` then run `pod install` in `/your_project/platforms/ios/`.

### Strip debug symbols
If your iOS app build contains too many debug symbols (i.e. because you include lots of libraries via a Cocoapods), you might get an error (e.g. [issue #28](https://github.com/dpa99c/cordova-plugin-firebase/issues/28)) when you upload your binary to App Store Connect, e.g.:

    ITMS-90381: Too many symbol files - These symbols have no corresponding slice in any binary [16EBC8AC-DAA9-39CF-89EA-6A58EB5A5A2F.symbols, 1B105D69-2039-36A4-A04D-96C1C5BAF235.symbols, 476EACDF-583B-3B29-95B9-253CB41097C8.symbols, 9789B03B-6774-3BC9-A8F0-B9D44B08DCCB.symbols, 983BAE60-D245-3291-9F9C-D25E610846AC.symbols].

To prevent this, you can set the `IOS_STRIP_DEBUG` plugin variable which prevents symbolification of all libraries included via Cocoapods ([see here for more information](https://stackoverflow.com/a/48518656/777265)):

    cordova plugin add cordova-plugin-firebasex --variable IOS_STRIP_DEBUG=true

By default this preference is set to `false`.

Note: if you enable this setting, any crashes that occur within libraries included via Cocopods will not be recorded in Crashlytics or other crash reporting services.

### Cordova CLI builds
If you are building (directly or indirectly) via the Cordova CLI and a build failures on iOS such as the one below:

    error: Resource "/Build/Products/Debug-iphonesimulator/FirebaseInAppMessaging/InAppMessagingDisplayResources.bundle" not found. Run 'pod install' to update the copy resources script.


This is likely due to [an issue with Cordova CLI builds for iOS](https://github.com/apache/cordova-ios/issues/659) when including certain pods into the build (see [#326](https://github.com/dpa99c/cordova-plugin-firebasex/issues/326)):

Note that building from Xcode works fine, so if you are able then do this.

Otherwise (e.g. if building via a CI) then you'll need to switch to using the [cli_build branch](https://github.com/dpa99c/cordova-plugin-firebasex/tree/cli_build) of this plugin:

    cordova plugin rm cordova-plugin-firebasex && cordova plugin add cordova-plugin-firebasex@latest-cli

This removes the Firebase Inapp Messaging and Google Tag Manager SDK components that are causing the build issues.
The `cli_build` branch is kept in sync with `master` but without the above components.

You can validate your CLI build environment using [this publicly-available `GoogleService-Info.plist`](https://github.coventry.ac.uk/301CEM-1920OCTJAN/301CEM-6957713/raw/master/CanaryApparel/GoogleService-Info.plist):

	cordova create test com.canary.CanaryApparel && cd test
	curl https://github.coventry.ac.uk/raw/301CEM-1920OCTJAN/301CEM-6957713/master/CanaryApparel/GoogleService-Info.plist -o GoogleService-Info.plist
	cordova plugin add cordova-plugin-firebasex@latest-cli
	cordova platform add ios
	cordova build ios --emulator
	#build succeeds

Following the installation steps above, modify the `package.json` file to pin the `cli` variant of this package by removing the `^` or `~` prefix from the package declaration. Failure to do this will result in build issues the next time the `cordova prepare` steps are performed as the non-cli version of the package will replace the cli variant.
```
  "dependencies": {
    "cordova-android": "~8.1.0",
    "cordova-ios": "^6.1.0",
    "cordova-plugin-androidx": "^2.0.0",
    "cordova-plugin-androidx-adapter": "^1.1.1",
    "cordova-plugin-firebasex": "^10.1.2-cli" --> Change to "10.1.2-cli"
  },
```

# Firebase config setup
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

Or you can set custom location for your platform configuration files using plugin variables in your `config.xml`:

```
<plugin name="cordova-plugin-firebasex">
    <variable name="ANDROID_FIREBASE_CONFIG_FILEPATH" value="resources/android/google-services.json" />
    <variable name="IOS_FIREBASE_CONFIG_FILEPATH" value="resources/ios/GoogleService-Info.plist" />
</plugin>
```

IMPORTANT: The Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

# Disable data collection on startup
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

       FirebasePlugin.setAnalyticsCollectionEnabled(true);
       FirebasePlugin.setPerformanceCollectionEnabled(true);
       FirebasePlugin.setCrashlyticsCollectionEnabled(true);

Notes:
- Calling `setXCollectionEnabled()` will have no effect if the corresponding `FIREBASE_X_COLLECTION_ENABLED` variable is set to `true`.
- Calling `setXCollectionEnabled(true|false)` will enable/disable data collection during the current app session and across subsequent app sessions until such time as the same method is called again with a different value.

# Example project
An example project repo exists to demonstrate and validate the functionality of this plugin:
https://github.com/dpa99c/cordova-plugin-firebasex-test

Please use this as a working reference.

Before reporting any issues, please (if possible) test against the example project to rule out causes external to this plugin.

# Reporting issues
**IMPORTANT:** Please read the following carefully.
Failure to follow the issue template guidelines below will result in the issue being immediately closed.

## Reporting a bug or problem
Before [opening a bug issue](https://github.com/dpa99c/cordova-plugin-firebasex/issues/new?assignees=&labels=&template=bug_report.md&title=), please do the following:
- *DO NOT* open issues asking for support in using/integrating the plugin into your project
    - Only open issues for suspected bugs/issues with the plugin that are generic and will affect other users
    - I don't have time to offer free technical support: this is free open-source software
    - Ask for help on StackOverflow, Ionic Forums, etc.
    - Use the [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test) as a known working reference
    - Any issues requesting support will be closed immediately.
- *DO NOT* open issues related to the  [Ionic Typescript wrapper for this plugin](https://github.com/ionic-team/ionic-native/blob/master/src/%40ionic-native/plugins/firebase-x/index.ts)
    - This is owned/maintained by [Ionic](https://github.com/ionic-team) and is not part of this plugin
    - Please raise such issues/PRs against [Ionic Native](https://github.com/ionic-team/ionic-native/) instead.
	- To verify an if an issue is caused by this plugin or its Typescript wrapper, please re-test using the vanilla Javascript plugin interface (without the Ionic Native wrapper).
	- Any issue opened here which is obviously an Ionic Typescript wrapper issue will be closed immediately.
- If you are migrating from [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) to `cordova-plugin-firebasex` please make sure you have read the [Migrating from cordova-plugin-firebase](#migrating-from-cordova-plugin-firebase) section.
- Read the above documentation thoroughly
    - For example, if you're having a build issue ensure you've read through the [build environment notes](#build-environment-notes)
    - If an iOS CLI build is failing, ensure you've read the [Cordova CLI builds](#cordova-cli-builds) section
- Check the [CHANGELOG](https://github.com/dpa99c/cordova-plugin-firebasex/blob/master/CHANGELOG.md) for any breaking changes that may be causing your issue.
- Check a similar issue (open or closed) does not already exist against this plugin.
	- Duplicates or near-duplicates will be closed immediately.
- When [creating a new issue](https://github.com/dpa99c/cordova-plugin-firebasex/issues/new/choose)
    - Choose the "Bug report" template
    - Fill out the relevant sections of the template and delete irrelevant sections
    - *WARNING:* Failure to complete the issue template will result in the issue being closed immediately.
- Reproduce the issue using the [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test)
	- This will eliminate bugs in your code or conflicts with other code as possible causes of the issue
	- This will also validate your development environment using a known working codebase
	- If reproducing the issue using the example project is not possible, create an isolated test project that you are able to share
- Include full verbose console output when reporting build issues
    - If the full console output is too large to insert directly into the Github issue, then post it on an external site such as [Pastebin](https://pastebin.com/) and link to it from the issue
    - Often the details of an error causing a build failure is hidden away when building with the CLI
        - To get the full detailed console output, append the `--verbose` flag to CLI build commands
        - e.g. `cordova build ios --verbose`
    - Failure to include the full console output will result in the issue being closed immediately
- If the issue relates to the plugin documentation (and not the code), please of a [documentation issue](https://github.com/dpa99c/cordova-plugin-firebasex/issues/new?assignees=&labels=&template=documentation-issue.md&title=)

## Requesting a new feature
Before [opening a feature request issue](https://github.com/dpa99c/cordova-plugin-firebasex/issues/new?assignees=&labels=&template=feature_request.md&title=), please do the following:
- Check the above documentation to ensure the feature you are requesting doesn't already exist
- Check the list if open/closed issues to check if there's a reason that feature hasn't been included already
- Ensure the feature you are requesting is actually possible to implement and generically useful to other users than yourself
- Where possible, post a link to the documentation related to the feature you are requesting
- Include other relevant links, e.g.
    - Stack Overflow post illustrating a solution
    - Code within another Github repo that illustrates a solution

# Cloud messaging

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

## Background notifications
If the notification message arrives while the app is in the background/not running, it will be displayed as a system notification.

By default, no callback is made to the plugin when the message arrives while the app is not in the foreground, since the display of the notification is entirely handled by the operating system.
However, there are platform-specific circumstances where a callback can be made when the message arrives and the app is in the background that don't require user interaction to receive the message payload - see [Android background notifications](#android-background-notifications) and [iOS background notifications](#ios-background-notifications) for details.

If the user taps the system notification, this launches/resumes the app and the notification title, body and optional data payload is passed to the [onMessageReceived](#onMessageReceived) callback.

When the `onMessageReceived` is called in response to a user tapping a system notification while the app is in the background/not running, it will be passed the property `tap: "background"`.


## Foreground notifications
If the notification message arrives while the app is in running in the foreground, by default **it will NOT be displayed as a system notification**.
Instead the notification message payload will be passed to the [onMessageReceived](#onMessageReceived) callback for the plugin to handle (`tap` will not be set).

If you include the `notification_foreground` key in the `data` payload, the plugin will also display a system notification upon receiving the notification messages while the app is running in the foreground.
For example:

```json
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
```

When the `onMessageReceived` is called in response to a user tapping a system notification while the app is in the foreground, it will be passed the property `tap: "foreground"`.

You can set additional properties of the foreground notification using the same key names as for [Data Message Notifications](#data-message-notification-keys).

## Android notifications
Notifications on Android can be customised to specify the sound, icon, LED colour, etc. that's displayed when the notification arrives.

### Android background notifications
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

```json
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
```

### Android foreground notifications
If the notification message arrives while the app is in the foreground, by default a system notification won't be displayed and the data will be passed to [onMessageReceived](#onMessageReceived).

However, if you set the `notification_foreground` key in the `data` section of the notification message payload, this will cause the plugin to display system notification when the message is received while your app is in the foreground. You can customise the notification using the same keys as for [Android data message notifications](#android-data-message-notifications).

### Android Notification Channels
- Android 8 (O) introduced [notification channels](https://developer.android.com/training/notify-user/channels).
- Notification channels are configured by the app and used to determine the **sound/lights/vibration** settings of system notifications.
- By default, this plugin creates a default channel with [default properties](#default-android-channel-properties)
    - These can be overridden via the [setDefaultChannel](#setdefaultchannel) function.
- The plugin enables the creation of additional custom channels via the [createChannel](#createchannel) function.

First you need to create a custom channel with the desired settings, for example:

```javascript
var channel  = {
    id: "my_channel_id",
    sound: "mysound",
    vibration: true,
    light: true,
    lightColor: parseInt("FF0000FF", 16).toString(),
    importance: 4,
    badge: true,
    visibility: 1
};

FirebasePlugin.createChannel(channel,
function(){
    console.log('Channel created: ' + channel.id);
},
function(error){
   console.log('Create channel error: ' + error);
});
```

Then reference it from your message payload:

```json
{
  "name": "my_notification",
  "notification": {
    "body": "Notification body",
    "title": "Notification title"
  },
  "android": {
    "notification": {
      "channel_id": "my_channel_id"
    }
  }
}
```

#### Android 7 and below
- the channel referenced in the message payload will be ignored
- the sound setting of system notifications is specified in the notification message itself - see [Android Notification Sound](#android-notification-sound).


### Android Notification Icons
By default the plugin will use the default app icon for notification messages.

#### Android Default Notification Icon
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

```xml
<platform name="android">
    <resource-file src="res/android/drawable-mdpi/notification_icon.png" target="app/src/main/res/drawable-mdpi/notification_icon.png" />
    <resource-file src="res/android/drawable-hdpi/notification_icon.png" target="app/src/main/res/drawable-hdpi/notification_icon.png" />
    <resource-file src="res/android/drawable-xhdpi/notification_icon.png" target="app/src/main/res/drawable-xhdpi/notification_icon.png" />
    <resource-file src="res/android/drawable-xxhdpi/notification_icon.png" target="app/src/main/res/drawable-xxhdpi/notification_icon.png" />
    <resource-file src="res/android/drawable-xxxhdpi/notification_icon.png" target="app/src/main/res/drawable-xxxhdpi/notification_icon.png" />
</platform>
```

The default notification icon images **must** be named `notification_icon.png`.

You then need to add a `<config-file>` block to the `config.xml` which will instruct Firebase to use your icon as the default for notifications:

```xml
<platform name="android">
    <config-file target="AndroidManifest.xml" parent="/manifest/application">
        <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/notification_icon" />
    </config-file>
</platform>
```


#### Android Large Notification Icon
The default notification icons above are monochrome, however you can additionally define a larger multi-coloured icon.

**NOTE:** FCM currently does not support large icons in system notifications displayed for notification messages received in the while the app is in the background (or not running).
So the large icon will currently only be used if specified in [data messages](#android-data-messages) or [foreground notifications](#foreground-notifications).

The large icon image should be a PNG-24 that's 256x256 pixels and must be named `notification_icon_large.png` and should be placed in the `drawable-xxxhdpi` resource directory.
As with the small icons, you'll need to add a `<resource-file>` entry to the `<platform name="android">` section of your `config.xml`:

```xml
<platform name="android">
    <resource-file src="res/android/drawable-xxxhdpi/notification_icon_large.png" target="app/src/main/res/drawable-xxxhdpi/notification_icon_large.png" />
</platform>
```


#### Android Custom Notification Icons
You can define additional sets of notification icons in the same manner as above.
These can be specified in notification or data messages.

For example:

```xml
        <resource-file src="res/android/drawable-mdpi/my_icon.png" target="app/src/main/res/drawable-mdpi/my_icon.png" />
        <resource-file src="res/android/drawable-hdpi/my_icon.png" target="app/src/main/res/drawable-hdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xhdpi/my_icon.png" target="app/src/main/res/drawable-xhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxhdpi/my_icon.png" target="app/src/main/res/drawable-xxhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxxhdpi/my_icon.png" target="app/src/main/res/drawable-xxxhdpi/my_icon.png" />
        <resource-file src="res/android/drawable-xxxhdpi/my_icon_large.png" target="app/src/main/res/drawable-xxxhdpi/my_icon_large.png" />
```

When sending an FCM notification message, you will then specify the icon name in the `android.notification` section, for example:

```json
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
```

You can also reference these icons in [data messages](#android-data-messages), for example:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "notification_android_icon": "my_icon",
  }
}
```


### Android Notification Color
On Android Lollipop (5.0/API 21) and above you can set the default accent color for the notification by adding a color setting.
This is defined as an [ARGB colour](https://en.wikipedia.org/wiki/RGBA_color_space#ARGB_(word-order)) which the plugin sets by default to `#FF00FFFF` (cyan).
Note: On Android 7 and above, the accent color can only be set for the notification displayed in the system tray area - the icon in the statusbar is always white.

You can override this default by specifying a value using the `ANDROID_ICON_ACCENT` plugin variable during plugin installation, for example:

    cordova plugin add cordova-plugin-firebasex --variable ANDROID_ICON_ACCENT=#FF123456

You can override the default color accent by specifying the `colour` key as an RGB value in a notification message, e.g.:

```json
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
```

And in a data message:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "notification_android_color": "#00ff00"
  }
}
```

### Android Notification Sound
You can specify custom sounds for notifications or play the device default notification sound.

Custom sound files must be in `.mp3` format and deployed to the `/res/raw` directory in the Android project.
To do this, you can add `<resource-file>` tags to your `config.xml` to deploy the files, for example:

```xml
<platform name="android">
    <resource-file src="res/android/raw/my_sound.mp3" target="app/src/main/res/raw/my_sound.mp3" />
</platform>
```

To ensure your custom sounds works on all versions of Android, be sure to include both the channel name and sound name in your message payload (see below for details), for example:

```json
{
  "name": "my_notification",
  "notification": {
    "body": "Notification body",
    "title": "Notification title"
  },
  "android": {
    "notification": {
      "channel_id": "my_channel_id",
      "sound": "my_sound"
    }
  }
}
```

#### Android 8.0 and above
On Android 8.0 and above, the notification sound is specified by which [Android notification channel](#android-notification-channels) is referenced in the notification message payload.
First create a channel that references your sound, for example:

```javascript
var channel  = {
    id: "my_channel_id",
    sound: "my_sound"
};

FirebasePlugin.createChannel(channel,
function(){
    console.log('Channel created: ' + channel.id);
},
function(error){
   console.log('Create channel error: ' + error);
});
```

Then reference that channel in your message payload:

```json
{
  "name": "my_notification",
  "notification": {
    "body": "Notification body",
    "title": "Notification title"
  },
  "android": {
    "notification": {
      "channel_id": "my_channel_id"
    }
  }
}
```

#### On Android 7 and below
On Android 7 and below, you need to specify the sound file name in the `android.notification` section of the message payload.
For example:

```json
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
```

And in a data message by specifying it in the `data` section:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "notification_android_sound": "my_sound"
  }
}
```

- To play the default notification sound, set `"sound": "default"`.
- To display a silent notification (no sound), omit the `sound` key from the message.

### Android cloud message types
The type of payload data in an FCM message influences how the message will be delivered to the app dependent on its run state, as outlined in [this Firebase documentation](https://firebase.google.com/docs/cloud-messaging/android/receive).

|App run state | Notification payload | Data payload | Notification+Data payload |
|----------|----------------------|--------------|---------------------------|
| Foreground | `onMessageReceived` | `onMessageReceived` | `onMessageReceived` |
| Background | System tray<sup>[[1]](#messagetypefootnote1)</sup>| `onMessageReceived` | Notification payload: System tray<sup>[[1]](#messagetypefootnote1)</sup> <br/> Data payload: `onMessageReceived` via extras of New Intent<sup>[[2]](#messagetypefootnote2)</sup> |
| Not running | System tray<sup>[[1]](#messagetypefootnote1)</sup> | **Never received**<sup>[[3]](#messagetypefootnote3)</sup> | Notification payload: System tray<sup>[[1]](#messagetypefootnote1)</sup> <br/> Data payload: `onMessageReceived` via extras of Launch Intent<sup>[[2]](#messagetypefootnote2)</sup> |

<a name="messagetypefootnote1">1</a>: If user taps the system notification, its payload is delivered to `onMessageReceived`

<a name="messagetypefootnote2">2</a>: The data payload is only delivered as an extras Bundle Intent if the user taps the system notification.
Otherwise it will not be delivered as outlined in [this Firebase documentation](https://firebase.google.com/docs/cloud-messaging/concept-options#notification-messages-with-optional-data-payload).

<a name="messagetypefootnote3">3</a>: If the app is not running/has been task-killed when the data message arrives, it will never be received by the app.

## iOS notifications
Notifications on iOS can be customised to specify the sound and badge number that's displayed when the notification arrives.

Notification settings are specified in the `apns.payload.aps` key of the notification message payload.
For example:

```json
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
```

### iOS background notifications
If the app is in the background but is still running (i.e. has not been task-killed) and the device is not in power-saving mode, the `onMessageReceived` callback can be invoked when the message arrives without requiring user interaction (i.e. tapping the system notification).
To do this you must specify `"content-available": 1` in the `apns.payload.aps` section of the message payload - see the [Apple documentation](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW8) for more information.
When the message arrives, the `onMessageReceived` callback will be invoked without the `tap` property, indicating the message was received without user interaction.
If the user then taps the system notification, the app will be brought to the foreground and `onMessageReceived` will be invoked **again**, this time with `tap: "background"` indicating that the user tapped the system notification while the app was in the background.

### iOS notification sound
You can specify custom sounds for notifications or play the device default notification sound.

Custom sound files must be in a supported audio format (see [this Apple documentation](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SupportingNotificationsinYourApp.html#//apple_ref/doc/uid/TP40008194-CH4-SW10) for supported formats).
For example to convert an `.mp3` file to the supported `.caf` format run:

    afconvert my_sound.mp3 my_sound.caf -d ima4 -f caff -v

Sound files must be deployed with the iOS application bundle.
To do this, you can add `<resource-file>` tags to your `config.xml` to deploy the files, for example:

```xml
<platform name="ios">
    <resource-file src="res/ios/sound/my_sound.caf" />
</platform>
```

In a notification message, specify the `sound` key in the `apns.payload.aps` section, for example:

```json
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
```

- To play the default notification sound, set `"sound": "default"`.
- To display a silent notification (no sound), omit the `sound` key from the message.

In a data message, specify the `notification_ios_sound` key in the `data` section:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "notification_ios_sound": "my_sound.caf"
  }
}
```

### iOS critical notifications
iOS offers the option to send critical push notifications. These kind of notifications appear even when your iPhone or iPad is in Do Not Disturb mode or silenced. Sending critical notifications requires a special entitlement that needs to be issued by Apple.
Use the pugin setting `IOS_ENABLE_CRITICAL_ALERTS_ENABLED=true` to enable the critical push notifications capability.
A user also needs to explicitly [grant permission](#grantcriticalpermission) to receive critical alerts.

### iOS badge number
In a notification message, specify the `badge` key in the `apns.payload.aps` section, for example:

```json
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
```

In a data message, specify the `notification_ios_badge` key in the `data` section:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "notification_ios_badge": 1
  }
}
```

### iOS actionable notifications
[Actionable notifications](https://developer.apple.com/documentation/usernotifications/declaring_your_actionable_notification_types) are supported on iOS:

<img width="300" src="https://user-images.githubusercontent.com/2345062/90025071-88c0a180-dcad-11ea-86f7-033f84601a56.png"/>
<img width="300" src="https://user-images.githubusercontent.com/2345062/90028234-531db780-dcb1-11ea-9df3-6bfcf8f2e9d8.png"/>

To use them in your app you must do the following:

1. Add a `pn-actions.json` file to your Cordova project which defines categories and actions, for example:

```json
    {
      "PushNotificationActions": [
        {
          "category": "news",
          "actions": [
            {
              "id": "read", "title": "Read", "foreground": true
            },
            {
              "id": "skip", "title": "Skip"
            },
            {
              "id": "delete", "title": "Delete", "destructive": true
            }
          ]
        }
      ]
    }
```

Note the `foreground` and `destructive` options correspond to the equivalent [UNNotificationActionOptions](https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions?language=objc).

2. Reference it as a resource file in your `config.xml`:

```xml
    <platform name="ios">
        ...
        <resource-file src="relative/path/to/pn-actions.json" />
    </platform>
```

3. Add a category entry to your FCM message payload which references one of your categories:

```json
{
  "notification": {
      "title": "iOS Actionable Notification",
      "body": "With custom buttons"
  },
  "apns": {
    "payload": {
      "aps": {
        "category": "news"
      }
    }
  }
}
```

When the notification arrives, if the user presses an action button the [`onMessageReceived()`](#onmessagereceived) function is invoked with the notification message payload, including the corresponding action ID.
For example:

```json
{
    "action": "read",
    "google.c.a.e": "1",
    "notification_foreground": "true",
    "aps": {
        "alert": {
            "title": "iOS Actionable Notification",
            "body": "With custom buttons"
        },
        "category": "news"
    },
    "gcm.message_id": "1597240847657854",
    "tap": "background",
    "messageType": "notification"
}
```

So you can obtain the category with `message.aps.category` and the action with `message.action` and handle this appropriately in your app code.

Notes:
- Actionable notifications are currently only available for iOS - not Android
- To reveal the notification action buttons, the user must drag downwards on the notification dialog
- Actionable notifications work with both foreground and background (system) notifications
- If your app is in the background/not running when the notification message arrives and a system notification is displayed, if the user chooses an action (instead of tapping the notification dialog body), your app will not be launched/foregrounded but [`onMessageReceived()`](#onmessagereceived) will be invoked, enabling your app code to handle the user's action selection silently in the background.
- You can test out actionable notifications by building and running [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test) app and sending the [ios_notification_actionable.json](https://github.com/dpa99c/cordova-plugin-firebasex-test/blob/master/messages/ios_notification_actionable.json) FCM message using the [built-in FCM v1 HTTP API client](https://github.com/dpa99c/cordova-plugin-firebasex-test#messaging-client) which contains a category defined in the example [pn-actions.json](https://github.com/dpa99c/cordova-plugin-firebasex-test/blob/master/res/ios/pn-actions.json).

### iOS notification settings button

<img width="300" src="https://i.stack.imgur.com/84LDU.jpg">

Adding such a Button is possible with this Plugin.
To enable this Feature, you need to pass `true` for **requestWithProvidesAppNotificationSettings** when you [request the Permission](#grantpermission).

You then need to subscribe to `onOpenSettings` and open your apps notification settings page.

## Data messages
FCM data messages are sent as an arbitrary k/v structure and by default are passed to the app for it to handle them.

**NOTE:** FCM data messages **cannot** be sent from the Firebase Console - they can only be sent via the FCM APIs.

### Data message notifications
This plugin enables a data message to be displayed as a system notification.
To have the app display a notification when the data message arrives, you need to set the `notification_foreground` key in the `data` section.
You can then set a `notification_title` and `notification_body`, for example:

```json
{
  "name": "my_data",
  "data" : {
    "notification_foreground": "true",
    "notification_body" : "Notification body",
    "notification_title": "Notification title",
    "foo" : "bar"
  }
}
```

Additional platform-specific notification options can be set using the additional keys below (which are only relevant if the `notification_foreground` key is set).

Note: [foreground notification messages](#foreground-notifications) can also make use of these keys.

#### Android data message notifications
On Android:
- Data messages that arrive while your app is running in the foreground or running in the background will be immediately passed to the `onMessageReceived()` Javascript handler in the Webview.
- Data messages (not containing notification keys) that arrive while your app is **not running** will be passed to the `onMessageReceived()` Javascript handler when the app is next launched.
- Data messages containing notification keys that arrive while your app is running or **not running** will be displayed as a system notification.

The following Android-specific keys are supported and should be placed inside the `data` section:

- `notification_android_id` - Identifier used to replace existing notifications in the notification drawer
    - If not specified, each request creates a new notification.
    - If specified and a notification with the same tag is already being shown, the new notification replaces the existing one in the notification drawer.
- `notification_android_body_html` - If is passed, the body of a notification is processed as if it were html, you can use `<b>, <i> or <s>`
    - If not specified, the body of the notification will be processed as plain text.
- `notification_android_icon` - name of a [custom notification icon](#android-custom-notification-icons) in the drawable resources
    - if not specified, the plugin will use the default `notification_icon` if it exists; otherwise the default app icon will be displayed
    - if a [large icon](#android-large-notification-icon) has been defined, it will also be displayed in the system notification.
- `notification_android_color` - the [color accent](#android-notification-color) to use for the small notification icon
    - if not specified, the default color accent will be used
- `notification_android_image` - Specifies the image notification
    - if not specified, the notification will not show any image
- `notification_android_image_type` - Specifies the image notification type
    - Possible values:
        - `square` - The image is displayed in the default format.
        - `circle` - This notification displays the image in circular format.
        - `big_picture` - Displays the image like `square` type, but the notification can be expanded and show the image in a big picture, example: https://developer.android.com/training/notify-user/expanded#image-style
    - Defaults to `square` if not specified.
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

```json
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
    "notification_android_image": "https://example.com/avatar.jpg",
    "notification_android_image_type": "circle",
    "notification_android_sound": "my_sound",
    "notification_android_vibrate": "500, 200, 500",
    "notification_android_lights": "#ffff0000, 250, 250"
  }
}
```

#### iOS data message notifications
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
```json
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
```

## Custom FCM message handling
In some cases you may want to handle certain incoming FCM messages differently rather than with the default behaviour of this plugin.
Therefore this plugin provides a mechanism by which you can implement your own custom FCM message handling for specific FCM messages which bypasses handling of those messages by this plugin.
To do this requires you to write native handlers for Android & iOS which hook into the native code of this plugin.

### Android
You'll need to add a native class which extends the [`FirebasePluginMessageReceiver` abstract class](src/android/FirebasePluginMessageReceiver.java) and implements the `onMessageReceived()` and `sendMessage()` abstract methods.

### iOS
You'll need to add a native class which extends the [`FirebasePluginMessageReceiver` abstract class](src/ios/FirebasePluginMessageReceiver.h) and implements the `sendNotification()` abstract method.

### Example
The [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test) contains an [example plugin](https://github.com/dpa99c/cordova-plugin-firebasex-test/tree/master/plugins/cordova-plugin-customfcmreceiver) which implements a custom receiver class for both platforms.
You can test this by building and running the example project app, and sending the [notification_custom_receiver](https://github.com/dpa99c/cordova-plugin-firebasex-test/blob/master/messages/notification_custom_receiver.json) and [data_custom_receiver](https://github.com/dpa99c/cordova-plugin-firebasex-test/blob/master/messages/data_custom_receiver.json) test messages using the [built-in FCM client](https://github.com/dpa99c/cordova-plugin-firebasex-test#messaging-client).

# InApp Messaging
Engage active app users with contextual messages.
The SDK component is included in the plugin but no explicit plugin API calls are required to use inapp messaging.

See the [iOS](https://firebase.google.com/docs/in-app-messaging/get-started?platform=ios#send_a_test_message) and [Android](https://firebase.google.com/docs/in-app-messaging/get-started?platform=android#send_a_test_message) guides for how to send a test message.

# Google Tag Manager
Download your container-config json file from Tag Manager and add a `<resource-file>` node in your `config.xml`.

## Android
```xml
<platform name="android">
    <resource-file src="GTM-XXXXXXX.json" target="assets/containers/GTM-XXXXXXX.json" />
    ...
```

## iOS
```xml
<platform name="ios">
    <resource-file src="GTM-YYYYYYY.json" />
    ...
```

# Performance Monitoring
The [Firebase Performance Monitoring SDK](https://firebase.google.com/docs/perf-mon) enables you to measure, monitor and analyze the performance of your app in the Firebase console.
It enables you to measure metrics such as app startup, screen rendering and network requests.

## Android Performance Monitoring Gradle plugin
- The [Firebase Performance Monitoring Gradle plugin for Android](https://firebase.google.com/docs/perf-mon/get-started-android?authuser=0#add-perfmon-plugin) is required to enable automatic monitoring of network requests in Android apps.
- However, as [outlined here](https://proandroiddev.com/hidden-costs-of-firebase-performance-and-how-to-avoid-them-a54f96bafcb1), adding this Gradle plugin to your Android builds can significantly increase Android build times and memory usage.
- For this reason, the Gradle plugin is not added to your Android app builds by default.
- If you want to add it to make use of automatic network request monitoring on Android, set the `ANDROID_FIREBASE_PERFORMANCE_MONITORING` [plugin variable](#plugin-variables) flag at plugin install time:
    - `--variable ANDROID_FIREBASE_PERFORMANCE_MONITORING=true`
- If you choose to add it, the Gradle plugin currently requires Gradle v6.1.1 and Android Studio v4.0 or above.
- Note: on iOS when this plugin is installed, automatic network request monitoring takes place with requiring any extra configuration.

# API
The list of available methods for this plugin is described below.

## Notifications and data messages
The plugin is capable of receiving push notifications and FCM data messages.

See [Cloud messaging](#cloud-messaging) section for more.

### getToken
Get the current FCM token.
Null if the token has not been allocated yet by the Firebase SDK.

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getToken(function(fcmToken) {
    console.log(fcmToken);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet.

### getId
Get the app instance ID (an constant ID which persists as long as the app is not uninstalled/reinstalled).
Null if the ID has not been allocated yet by the Firebase SDK.

**Parameters**:
- {function} success - callback function which will be passed the {string} ID as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getId(function(appInstanceId) {
    console.log(appInstanceId);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet.

### onTokenRefresh
Registers a handler to call when the FCM token changes.
This is the best way to get the token as soon as it has been allocated.
This will be called on the first run after app install when a token is first allocated.
It may also be called again under other circumstances, e.g. if `unregister()` is called or Firebase allocates a new token for other reasons.
You can use this callback to return the token to you server to keep the FCM token associated with a given user up-to-date.

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.onTokenRefresh(function(fcmToken) {
    console.log(fcmToken);
}, function(error) {
    console.error(error);
});
```

### getAPNSToken
iOS only.
Get the APNS token allocated for this app install.
Note that token will be null if it has not been allocated yet.

**Parameters**:
- {function} success - callback function which will be passed the {string} APNS token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getAPNSToken(function(apnsToken) {
    console.log(apnsToken);
}, function(error) {
    console.error(error);
});
```

### onApnsTokenReceived
iOS only.
Registers a handler to call when the APNS token is allocated.
This will be called once when remote notifications permission has been granted by the user at runtime.

**Parameters**:
- {function} success - callback function which will be passed the {string} token as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.onApnsTokenReceived(function(apnsToken) {
    console.log(apnsToken);
}, function(error) {
    console.error(error);
});
```

### onOpenSettings
iOS only
Registers a callback function to invoke when the AppNotificationSettingsButton is tapped by the user

**Parameters**:
- {function} success - callback function which will be invoked without any argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.onOpenSettings(function() {
    console.log("Redirect to App Notification Settings Page here");
}, function(error) {
    console.error(error);
});
```

### onMessageReceived
Registers a callback function to invoke when:
- a notification or data message is received by the app
- a system notification is tapped by the user

**Parameters**:
- {function} success - callback function which will be passed the {object} message as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.onMessageReceived(function(message) {
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

### grantPermission
Grant run-time permission to receive push notifications (will trigger user permission prompt).
iOS & Android 13+ (Android <= 12 will always return true).

On Android, the `POST_NOTIFICATIONS` permission must be added to the `AndroidManifest.xml` file by inserting the following into your `config.xml` file:

```xml
<config-file target="AndroidManifest.xml" parent="/*">
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
</config-file>
```

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument
- {boolean} requestWithProvidesAppNotificationSettings - (**iOS12+ only**) indicates if app provides AppNotificationSettingsButton

```javascript
FirebasePlugin.grantPermission(function(hasPermission){
    console.log("Notifications permission was " + (hasPermission ? "granted" : "denied"));
});
```

### grantCriticalPermission
Grant critical permission to receive critical push notifications (will trigger additional prompt).
iOS 12.0+ only (Android will always return true).

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

**Critical push notifications require a special entitlement that needs to be issued by Apple.**

```javascript
FirebasePlugin.grantCriticalPermission(function(hasPermission){
    console.log("Critical notifications permission was " + (hasPermission ? "granted" : "denied"));
});
```

### hasPermission
Check permission to receive push notifications and return the result to a callback function as boolean.
On iOS, returns true if runtime permission for remote notifications is granted and enabled in Settings.
On Android, returns true if global remote notifications are enabled in the device settings and (on Android 13+) runtime permission for remote notifications is granted.

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.hasPermission(function(hasPermission){
    console.log("Permission is " + (hasPermission ? "granted" : "denied"));
});
```

### hasCriticalPermission
Check permission to receive critical push notifications and return the result to a callback function as boolean.
iOS 12.0+ only (Android will always return true).

**Critical push notifications require a special entitlement that needs to be issued by Apple.**

**Parameters**:
- {function} success - callback function which will be passed the {boolean} permission result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.hasCriticalPermission(function(hasPermission){
    console.log("Permission to send critical push notifications is " + (hasPermission ? "granted" : "denied"));
});
```

### unregister
Unregisters from Firebase Cloud Messaging by deleting the current FCM device token.
Use this to stop receiving push notifications associated with the current token.
e.g. call this when you logout user from your app.
By default, a new token will be generated as soon as the old one is removed.
To prevent a new token being generated, be sure to disable autoinit using [`setAutoInitEnabled()`](#setautoinitenabled) before calling [`unregister()`](#unregister).

You can disable autoinit on first run and therefore prevent an FCM token being allocated by default (allowing user opt-in) by setting the `FIREBASE_FCM_AUTOINIT_ENABLED` plugin variable at plugin installation time:

    cordova plugin add cordova-plugin-firebasex --variable FIREBASE_FCM_AUTOINIT_ENABLED=false

**Parameters**: None

```javascript
FirebasePlugin.unregister();
```

### isAutoInitEnabled
Indicates whether autoinit is currently enabled.
If so, new FCM tokens will be automatically generated.

**Parameters**:
- {function} success - callback function which will be passed the {boolean} result as an argument
- {function} error - callback function which will be passed a {string} error message as an argument


```javascript
FirebasePlugin.isAutoInitEnabled(function(enabled){
    console.log("Auto init is " + (enabled ? "enabled" : "disabled"));
});

```

### setAutoInitEnabled
Sets whether to autoinit new FCM tokens.
By default, a new token will be generated as soon as the old one is removed.
To prevent a new token being generated, by sure to disable autoinit using [`setAutoInitEnabled()`](#setautoinitenabled) before calling [`unregister()`](#unregister).

**Parameters**:
- {boolean} enabled - set true to enable, false to disable
- {function} success - callback function to call on successful execution of operation.
- {function} error - callback function which will be passed a {string} error message as an argument


```javascript
FirebasePlugin.setAutoInitEnabled(false, function(){
    console.log("Auto init has been disabled ");
    FirebasePlugin.unregister();
});

```

### setBadgeNumber
iOS only.
Set a number on the icon badge:

**Parameters**:
- {integer} badgeNumber - number to set for the app badge

```javascript
FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge
```javascript
FirebasePlugin.setBadgeNumber(0);
```

Note: this function is no longer available on Android (see [#124](https://github.com/dpa99c/cordova-plugin-firebasex/issues/124))

### getBadgeNumber
iOS only.
Get icon badge number:

**Parameters**:
- {function} success - callback function which will be passed the {integer} current badge number as an argument

```javascript
FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

Note: this function is no longer available on Android (see [#124](https://github.com/dpa99c/cordova-plugin-firebasex/issues/124))

### clearAllNotifications
Clear all pending notifications from the drawer:

**Parameters**: None

```javascript
FirebasePlugin.clearAllNotifications();
```

### subscribe
Subscribe to a topic.

Topic messaging allows you to send a message to multiple devices that have opted in to a particular topic.

**Parameters**:
- {string} topicName - name of topic to subscribe to
- {function} success - callback function which will be call on successful subscription
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.subscribe("latest_news", function(){
    console.log("Subscribed to topic");
}, function(error){
     console.error("Error subscribing to topic: " + error);
});
```

### unsubscribe
Unsubscribe from a topic.

This will stop you receiving messages for that topic

**Parameters**:
- {string} topicName - name of topic to unsubscribe from
- {function} success - callback function which will be call on successful unsubscription
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.unsubscribe("latest_news", function(){
    console.log("Unsubscribed from topic");
}, function(error){
     console.error("Error unsubscribing from topic: " + error);
});
```

### createChannel
Android 8+ only.
Creates a custom channel to be used by notification messages which have the channel property set in the message payload to the `id` of the created channel:
- For background (system) notifications: `android.notification.channel_id`
- For foreground/data notifications:  `data.notification_android_channel_id`

For each channel you may set the sound to be played, the color of the phone LED (if supported by the device), whether to vibrate and set vibration pattern (if supported by the device), importance and visibility.
Channels should be created as soon as possible (on program start) so notifications can work as expected.
A default channel is created by the plugin at app startup; the properties of this can be overridden see [setDefaultChannel](#setdefaultchannel)

Calling on Android 7 or below or another platform will have no effect.

Note: Each time you want to play a different sound, you need to create a new channel with a new unique ID - do not re-use the same channel ID even if you have called `deleteChannel()` ([see this comment](https://github.com/dpa99c/cordova-plugin-firebasex/issues/560#issuecomment-798407467)).

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
    lightColor: parseInt("FF0000FF", 16).toString(),

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
    visibility: 1,

    // Optionally specify the usage type of the notification. Defaults to USAGE_NOTIFICATION_RINGTONE ( =6)
    // For a list of all possible usages, see https://developer.android.com/reference/android/media/AudioAttributes.Builder#setUsage(int)

    usage: 6,
    // Optionally specify the stream type of the notification channel.
    // For a list of all possible values, see https://developer.android.com/reference/android/media/AudioAttributes.Builder#setLegacyStreamType(int)
    streamType: 5,
};

// Create the channel
FirebasePlugin.createChannel(channel,
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

If your Android app plays multiple sounds or effects, it's a good idea to create a channel for each likely combination. This is because once a channel is created you cannot override sounds/effects.
IE, expanding on the createChannel example:
```javascript
let soundList = ["train","woop","clock","radar","sonar"];
for (let key of soundList) {
    let name = "yourchannelprefix_" + key;
    channel.id = name;
    channel.sound = key;
    channel.name = "Your description " + key;

    // Create the channel
    window.FirebasePlugin.createChannel(channel,
        function(){
            console.log('Notification Channel created: ' + channel.id + " " + JSON.stringify(channel));
        },
        function(error){
            console.log('Create notification channel error: ' + error);
        });
}
```

Note, if you just have one sound / effect combination that the user can customise, just use setDefaultChannel when any changes are made.


### setDefaultChannel
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
  lightColor: parseInt("FF0000FF", 16).toString(),
  importance: 4,
  badge: false,
  visibility: -1
};

FirebasePlugin.setDefaultChannel(channel,
function(){
    console.log('Default channel set');
},
function(error){
   console.log('Set default channel error: ' + error);
});
```

### Default Android Channel Properties
The default channel is initialised at app startup with the following default settings:

```json
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

### deleteChannel
Android 8+ only.
Removes a previously defined channel.
Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {string} - id of channel to delete
- {function} success - callback function which will be call on successfully deleting channel
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.deleteChannel("my_channel_id",
function(){
    console.log('Channel deleted');
},
function(error){
   console.log('Delete channel error: ' + error);
});

```

### listChannels
Android 8+ only.
Gets a list of all channels.
Calling on Android 7 or below or another platform will have no effect.

**Parameters**:
- {function} success - callback function which will be passed the {array} of channel objects as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.listChannels(
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

## Analytics
Firebase Analytics enables you to log events in order to track use and behaviour of your apps.

By default, Firebase does not store fine-grain analytics data - only a sample is taken and detailed event data is then discarded.
The Firebase Analytics console is designed to give you a coarse overview of analytics data.

If you want to analyse detailed, event-level analytics you should consider [exporting Firebase Analytics data to BigQuery](https://firebase.google.com/docs/projects/bigquery-export).
The easiest way to set this up is by [streaming Firebase Analytics data into BigQuery](https://cloud.google.com/bigquery/streaming-data-into-bigquery).
Note that until you set this up, all fine-grain event-level data is discarded by Firebase.

### setAnalyticsCollectionEnabled
Manually enable/disable analytics data collection, e.g. if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**:
- {boolean} setEnabled - whether to enable or disable analytics data collection

```javascript
FirebasePlugin.setAnalyticsCollectionEnabled(true); // Enables analytics data collection

FirebasePlugin.setAnalyticsCollectionEnabled(false); // Disables analytics data collection
```

### isAnalyticsCollectionEnabled
Indicates whether analytics data collection is enabled.

Notes:
- This value applies both to the current app session and subsequent app sessions until such time as it is changed.
- It returns the value set by [setAnalyticsCollectionEnabled()](#setanalyticscollectionenabled).
- If automatic data collection was not [disabled on app startup](#disable-data-collection-on-startup), this will always return `true`.

**Parameters**:
- {function} success - callback function which will be invoked on success.
Will be passed a {boolean} indicating if the setting is enabled.
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.isAnalyticsCollectionEnabled(function(enabled){
    console.log("Analytics data collection is "+(enabled ? "enabled" : "disabled"));
}, function(error){
    console.error("Error getting Analytics data collection setting: "+error);
});
```

### logEvent
Log an event using Analytics:

**Parameters**:
- {string} eventName - name of event to log to Firebase Analytics
    - [Limit](https://support.google.com/firebase/answer/9237506?hl=en) of 40 characters.
    - Dots are not allowed in eventName.
- {object} eventProperties - key/value object of custom event properties.
    - This must be a flat (non-nested) object.
    - The value must be a primitive type such as string/number/etc. (not a complex object such as array or nested object).
    - [Limit](https://support.google.com/firebase/answer/9237506?hl=en) of 40 characters for parameter name and 100 characters for parameter value.

```javascript
FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

### setScreenName
Set the name of the current screen in Analytics:

**Parameters**:
- {string} screenName - name of screen to log to Firebase Analytics

```javascript
FirebasePlugin.setScreenName("Home");
```

### setUserId
Set a user id for use in Analytics:

**Parameters**:
- {string} userName - name of user to set in Firebase Analytics

```javascript
FirebasePlugin.setUserId("user_id");
```

### setUserProperty
Set a user property for use in Analytics:

**Parameters**:
- {string} name - name of user property to set in Firebase Analytics
- {string} value - value of user property to set in Firebase Analytics

```javascript
FirebasePlugin.setUserProperty("name", "value");
```

## Crashlytics
By default this plugin will ensure fatal native crashes in your apps are reported to Firebase via the Firebase (not Fabric) Crashlytics SDK.

### setCrashlyticsCollectionEnabled
Manually enable/disable Crashlytics data collection, e.g. if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**:
- {boolean} setEnabled - whether to enable or disable Crashlytics data collection.
- {function} success - (optional) callback function which will be invoked on success
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
var shouldSetEnabled = true;
FirebasePlugin.setCrashlyticsCollectionEnabled(shouldSetEnabled, function(){
    console.log("Crashlytics data collection is enabled");
}, function(error){
    console.error("Crashlytics data collection couldn't be enabled: "+error);
});
```

### didCrashOnPreviousExecution
Checks whether the app crashed on its previous run.

**Parameters**:
- {function} success - callback function which will be invoked on success.
Will be passed a {boolean} indicating whether the app crashed on its previous run.
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.didCrashOnPreviousExecution(function(didCrashOnPreviousExecution){
    console.log(`Did crash on previous execution: ${didCrashOnPreviousExecution}`));
}, function(error){
    console.error(`Error getting Crashlytics did crash on previous execution: ${error}`);
});
```

### isCrashlyticsCollectionEnabled
Indicates whether Crashlytics collection setting is currently enabled.

**Parameters**:
- {function} success - callback function which will be invoked on success.
Will be passed a {boolean} indicating if the setting is enabled.
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.isCrashlyticsCollectionEnabled(function(enabled){
    console.log("Crashlytics data collection is "+(enabled ? "enabled" : "disabled"));
}, function(error){
    console.error("Error getting Crashlytics data collection setting: "+error);
});
```

### setCrashlyticsUserId
Set Crashlytics user identifier.

To diagnose an issue, it’s often helpful to know which of your users experienced a given crash. Crashlytics includes a way to anonymously identify users in your crash reports.
To add user IDs to your reports, assign each user a unique identifier in the form of an ID number, token, or hashed value.

See [the Firebase docs for more](https://firebase.google.com/docs/crashlytics/customize-crash-reports?authuser=0#set_user_ids).

**Parameters**:
- {string} userId - User ID to associate with Crashlytics reports

```javascript
FirebasePlugin.setCrashlyticsUserId("user_id");
```

### sendCrash
Simulates (causes) a fatal native crash which causes a crash event to be sent to Crashlytics (useful for testing).
See [the Firebase documentation](https://firebase.google.com/docs/crashlytics/force-a-crash?authuser=0#force_a_crash_to_test_your_implementation) regarding crash testing.
Crashes will appear under `Event type = "Crashes"` in the Crashlytics console.

**Parameters**: None

```javascript
FirebasePlugin.sendCrash();
```

### setCrashlyticsCustomKey
Records a custom key and value to be associated with subsequent fatal and non-fatal reports.

Multiple calls to this method with the same key will update the value for that key.

The value of any key at the time of a fatal or non-fatal event will be associated with that event.

Keys and associated values are visible in the session view on the Firebase Crashlytics console.

A maximum of 64 key/value pairs can be written, and new keys added beyond that limit will be ignored. Keys or values that exceed 1024 characters will be truncated.

**Parameters**:
- {string} key - A unique key
- {string | number | boolean} value - 	A value to be associated with the given key
- {function} success - (optional) callback function which will be invoked on success
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.setCrashlyticsCustomKey('number', 3.5, function(){
        console.log("set custom key: number, with value: 3.5");
    },function(error){
        console.error("Failed to set-custom key", error);
    });
FirebasePlugin.setCrashlyticsCustomKey('bool', true);
FirebasePlugin.setCrashlyticsCustomKey('string', 'Ipsum lorem');
// Following is just used to trigger report for Firebase
FirebasePlugin.logMessage("about to send a crash for testing!");
FirebasePlugin.sendCrash();
```

### logMessage
Sends a crash-related log message that will appear in the `Logs` section of the next native crash event.
Note: if you don't then crash, the message won't be sent!
Also logs the message to the native device console.

**Parameters**:
- {string} message - message to associate with next native crash event

```javascript
FirebasePlugin.logMessage("about to send a crash for testing!");
FirebasePlugin.sendCrash();
```

### logError
Sends a non-fatal error event to Crashlytics.
In a Cordova app, you may use this to log unhandled Javascript exceptions, for example.

The event will appear under `Event type = "Non-fatals"` in the Crashlytics console.
The error message will appear in the `Logs` section of the non-fatal error event.
Note that logged errors will only be sent to the Crashlytics server on the next full app restart.
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



## Authentication

### isUserSignedIn
Checks if there is a current Firebase user signed into the app.

**Parameters**:
- {function} success - callback function to pass {boolean} result to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.isUserSignedIn(function(isSignedIn) {
        console.log("User "+(isSignedIn ? "is" : "is not") + " signed in");
    }, function(error) {
        console.error("Failed to check if user is signed in: " + error);
    });
```

### signOutUser
Signs current Firebase user out of the app.

**Parameters**:
- {function} success - callback function to pass {boolean} result to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.signOutUser(function() {
        console.log("User signed out");
    }, function(error) {
        console.error("Failed to sign out user: " + error);
    });
```

### getCurrentUser
Returns details of the currently logged in user from local Firebase SDK.
Note that some user properties will be empty is they are not defined in Firebase for the current user.

**Parameters**:
- {function} success - callback function to pass user {object} to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.getCurrentUser(function(user) {
        console.log("Name: "+user.name);
        console.log("Email: "+user.email);
        console.log("Is email verified?: "+user.emailIsVerified);
        console.log("Phone number: "+user.phoneNumber);
        console.log("Photo URL: "+user.photoUrl);
        console.log("UID: "+user.uid);
        console.log("Provider ID: "+user.providerId);
        console.log("ID token: "+user.idToken);
    }, function(error) {
        console.error("Failed to get current user data: " + error);
    });
```

### reloadCurrentUser
Loads details of the currently logged in user from remote Firebase server.
This differs from `getCurrentUser()` which loads the locally cached details which may be stale.
For example, if you want to check if a user has verified their email address, this method will guarantee the reported verified state is up-to-date.

**Parameters**:
- {function} success - callback function to pass user {object} to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.reloadCurrentUser(function(user) {
        console.log("Name: "+user.name);
        console.log("Email: "+user.email);
        console.log("Is email verified?: "+user.emailIsVerified);
        console.log("Phone number: "+user.phoneNumber);
        console.log("Photo URL: "+user.photoUrl);
        console.log("UID: "+user.uid);
        console.log("Provider ID: "+user.providerId);
        console.log("ID token: "+user.idToken);
    }, function(error) {
        console.error("Failed to reload current user data: " + error);
    });
```

### updateUserProfile
Updates the display name and/or photo URL of the current Firebase user signed into the app.

**Parameters**:
- {object} profile - new profile details:
    - {string} name - display name of user
    - {string} photoUri - URL of user profile photo
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.updateUserProfile({
        name: "Homer Simpson",
        photoUri: "http://homer.simpson.com/photo.png"
    },function() {
        console.log("User profile successfully updated");
    }, function(error) {
        console.error("Failed to update user profile: " + error);
    });
```

### updateUserEmail
Updates/sets the email address of the current Firebase user signed into the app.

**Parameters**:
- {string} email - email address of user
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.updateUserEmail("user@somewhere.com",function() {
        console.log("User email successfully updated");
    }, function(error) {
        console.error("Failed to update user email: " + error);
    });
```

### sendUserEmailVerification
Sends a verification email to the currently configured email address of the current Firebase user signed into the app.
When the user opens the contained link, their email address will have been verified.

**Parameters**:
- {object} actionCodeSettings - action code settings based on [Passing State in Email Actions Parameters](https://firebase.google.com/docs/auth/web/passing-state-in-email-actions#passing_statecontinue_url_in_email_actions) :
    - {boolean} handleCodeInApp - Whether the email action link will be opened in a mobile app or a web link first
    - {string} url - Continue URL after email has been verified
    - {string} dynamicLinkDomain - Sets the dynamic link domain to use for the current link if it is to be opened using Firebase Dynamic Links
    - {string} iosBundleId - Sets the iOS bundle ID. This will try to open the link in an iOS app if it is installed
    - {string} androidPackageName - Sets the Android package name. This will try to open the link in an android app if it is installed
    - {boolean} installIfNotAvailable - Install if the provided app package name is not already installed on the users device (Android only)
    - {string} minimumVersion - minimum app version required (Android Only)
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.sendUserEmailVerification({
    handleCodeInApp: true,
    url: "http://www.example.com",
    dynamicLinkDomain: "example.page.link",
    iosBundleId: "com.example.ios",
    androidPackageName: "com.example.android",
    installIfNotAvailable: true,
    minimumVersion: "12",
}, function() {
    console.log("User verification email successfully sent");
}, function(error) {
    console.error("Failed to send user verification email: " + error);
});
```

### updateUserPassword
Updates/sets the account password for the current Firebase user signed into the app.

**Parameters**:
- {string} password - user-defined password
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.updateUserPassword("mypassword",function() {
        console.log("User password successfully updated");
    }, function(error) {
        console.error("Failed to update user password: " + error);
    });
```

### sendUserPasswordResetEmail
Sends a password reset email to the specified user email address.
Note: doesn't require the Firebase user to be signed in to the app.

**Parameters**:
- {string} email - email address of user
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.sendUserPasswordResetEmail("user@somewhere.com",function() {
        console.log("User password reset email sent successfully");
    }, function(error) {
        console.error("Failed to send user password reset email: " + error);
    });
```

### deleteUser
Deletes the account of the current Firebase user signed into the app.

**Parameters**:
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
    FirebasePlugin.deleteUser(function() {
        console.log("User account deleted");
    }, function(error) {
        console.error("Failed to delete current user account: " + error);
    });
```

### createUserWithEmailAndPassword
Creates a new email/password-based user account.
If account creation is successful, user will be automatically signed in.

**Parameters**:
- {string} email - user email address. It is the responsibility of the app to ensure this is a valid email address.
- {string} password - user password. It is the responsibility of the app to ensure the password is suitable.
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.createUserWithEmailAndPassword(email, password, function() {
        console.log("Successfully created email/password-based user account");
        // User is now signed in
    }, function(error) {
        console.error("Failed to create email/password-based user account", error);
    });
```

### signInUserWithEmailAndPassword
Signs in to an email/password-based user account.

**Parameters**:
- {string} email - user email address
- {string} password - user password
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.signInUserWithEmailAndPassword(email, password, function() {
        console.log("Successfully signed in");
        // User is now signed in
    }, function(error) {
        console.error("Failed to sign in", error);
    });
```

### signInUserWithCustomToken
Signs in user with custom token.

**Parameters**:
- {string} customToken - the custom token
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.signInUserWithCustomToken(customToken, function() {
        console.log("Successfully signed in");
        // User is now signed in
    }, function(error) {
        console.error("Failed to sign in", error);
    });
```

### signInUserAnonymously
Signs in user anonymously.

**Parameters**:
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.signInUserAnonymously(function() {
        console.log("Successfully signed in");
        // User is now signed in
    }, function(error) {
        console.error("Failed to sign in", error);
    });
```

### verifyPhoneNumber
Requests verification of a phone number.
The resulting credential can be used to create/sign in to a phone number-based user account in your app or to link the phone number to an existing user account

**NOTE: This will only work on physical devices with a SIM card (not iOS Simulator or Android Emulator)**

In response to your request, you'll receive a verification ID which you can use in conjunction with the verification code to sign the user in.

There are 3 verification scenarios:
- Some Android devices support "instant verification" where the phone number can be instantly verified without sending or receiving an SMS.
    - In this case, the user doesn't need to do anything in order for you to sign them in and you don't need to provide any additional credentials in order to sign the user in or link the user account to an existing Firebase user account.
- Some Android devices support "auto-retrieval" where Google Play services is able to detect the incoming verification SMS and perform verification with no user action required.
    - As above, the user doesn't need to do anything in order for you to sign them in.
- For other Android devices and all iOS devices, the user must manually enter the verification code received in the SMS into your app.
    - This code be used, along with the accompanying verification ID, to sign the user in or link phone number to an existing Firebase user account.

**Parameters**:
- {function} success - callback function to pass {object} credentials to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument
- {string} phoneNumber - phone number to verify
- {integer} timeOutDuration - (optional) time to wait in seconds before timing out
- {string} fakeVerificationCode - (optional) to test instant verification on Android ,specify a fake verification code to return for whitelisted phone numbers.
    - See [Firebase SDK Phone Auth Android Integration Testing](https://firebase.google.com/docs/auth/android/phone-auth#integration-testing) for more info.

The success callback will be passed a credential object with the following possible properties:
- {boolean} instantVerification - `true` if the Android device used instant verification to instantly verify the user without sending an SMS
or used auto-retrieval to automatically read an incoming SMS.
If this is `false`, the device will be sent an SMS containing the verification code.
If the Android device supports auto-retrieval, on the device receiving the SMS, this success callback will be immediately invoked again with `instantVerification: true` and no user action will be required for verification since Google Play services will extract and submit the verification code.
Otherwise the user must manually enter the verification code from the SMS into your app.
Always `false` on iOS.
- {string} id - the identifier of a native credential object which can be used for signing in the user.
Will only be present if `instantVerification` is `true`.
- {string} verificationId - the verification ID to be passed along with the verification code sent via SMS to sign the user in.
Will only be present if `instantVerification` is `false`.

Example usage:

```javascript
var number = '+441234567890';
var timeOutDuration = 60;
var fakeVerificationCode = '123456';
var awaitingSms = false;

FirebasePlugin.verifyPhoneNumber(function(credential) {

    if(credential.instantVerification){
        if(awaitingSms){
            awaitingSms = false;
            // the Android device used auto-retrieval to extract and submit the verification code in the SMS so dismiss user input UI
            dismissUserPromptToInputCode();
        }
        signInWithCredential(credential);
    }else{
        awaitingSms = true;
        promptUserToInputCode() // you need to implement this
            .then(function(userEnteredCode){
                awaitingSms = false;
                credential.code = userEnteredCode; // set the user-entered verification code on the credential object
                signInWithCredential(credential);
            });
    }
}, function(error) {
    console.error("Failed to verify phone number: " + JSON.stringify(error));
}, number, timeOutDuration, fakeVerificationCode);

function signInWithCredential(credential){
    FirebasePlugin.signInWithCredential(credential, function() {
        console.log("Successfully signed in");
    }, function(error) {
        console.error("Failed to sign in", error);
    });
}
```

#### Android
To use phone auth with your Android app, you need to configure your app SHA-1 hash in the android app configuration in the Firebase console.
See [this guide](https://developers.google.com/android/guides/client-auth) to find how to your SHA-1 app hash.
See the [Firebase phone auth integration guide for native Android](https://firebase.google.com/docs/auth/android/phone-auth) for more information.

#### iOS
When you call this method on iOS, FCM sends a silent push notification to the iOS device to verify it.
So to use phone auth with your iOS app, you need to:
- [setup your iOS app for push notifications](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- Verify that push notifications are arriving on your physical device
- [Upload your APNs auth key to the Firebase console](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_authentication_key).

You can [set up reCAPTCHA verification for iOS](https://firebase.google.com/docs/auth/ios/phone-auth#set-up-recaptcha-verification) automatically by specifying the `SETUP_RECAPTCHA_VERIFICATION` plugin variable at plugin install time:

    cordova plugin add cordova-plugin-firebasex --variable SETUP_RECAPTCHA_VERIFICATION=true

This adds the `REVERSED_CLIENT_ID` from the `GoogleService-Info.plist` to the list of custom URL schemes in your Xcode project, so you don't need to do this manually.

### setLanguageCode
Sets the user-facing language code for auth operations that can be internationalized, such as sendEmailVerification() or verifyPhoneNumber(). This language code should follow the conventions defined by the IETF in BCP47.

**Parameters**:
- {string} lang - language to change, ex: 'fr' for french

Example usage:

```javascript
    FirebasePlugin.setLanguageCode('fr'); // will switch to french
```

### authenticateUserWithEmailAndPassword
Authenticates the user with email/password-based user account to obtain a credential that can be used to sign the user in/link to an existing user account/reauthenticate the user.

**Parameters**:
- {string} email - user email address
- {string} password - user password
- {function} success - callback function to pass {object} credentials to as an argument. The credential object has the following properties:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.authenticateUserWithEmailAndPassword(email, password, function(credential) {
        console.log("Successfully authenticated with email/password");
        FirebasePlugin.reauthenticateWithCredential(credential, function() {
            console.log("Successfully re-authenticated");
        }, function(error) {
            console.error("Failed to re-authenticate", error);
        });
        // User is now signed in
    }, function(error) {
        console.error("Failed to authenticate with email/password", error);
    });
```

### authenticateUserWithGoogle
Authenticates the user with a Google account to obtain a credential that can be used to sign the user in/link to an existing user account/reauthenticate the user.

**Parameters**:
- {string} clientId - your OAuth 2.0 client ID - [see here](https://developers.google.com/identity/sign-in/android/start-integrating#get_your_backend_servers_oauth_20_client_id) how to obtain it.
- {function} success - callback function to pass {object} credentials to as an argument. The credential object has the following properties:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
    - {string} idToken - the identiy token from Google account. Could be useful if you want to sign-in with on JS layer.
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
FirebasePlugin.authenticateUserWithGoogle(clientId, function(credential) {
    FirebasePlugin.signInWithCredential(credential, function() {
            console.log("Successfully signed in");
        }, function(error) {
            console.error("Failed to sign in", error);
        });
}, function(error) {
    console.error("Failed to authenticate with Google: " + error);
});
```

#### Android
To use Google Sign-in in your Android app you need to do the following:
- Add the SHA-1 fingerprint of your app's signing key to your Firebase project
- Enable Google Sign-in in the Firebase console

For details how to do the above, see the [Google Sign-In on Android page](https://firebase.google.com/docs/auth/android/google-signin) in the Firebase documentation.

### authenticateUserWithApple
Authenticates the user with an Apple account using Sign In with Apple to obtain a credential that can be used to sign the user in/link to an existing user account/reauthenticate the user.

To use Sign In with Apple you must ensure your app's provisioning profile has this capability and it is enabled in your Xcode project.
You can enable the capability in Xcode by setting the `IOS_ENABLE_APPLE_SIGNIN` plugin variable at plugin installation time:

    cordova plugin add cordova-plugin-firebasex --variable IOS_ENABLE_APPLE_SIGNIN=true

**Parameters**:
- {function} success - callback function to pass {object} credentials to as an argument. The credential object has the following properties:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
- {function} error - callback function which will be passed a {string} error message as an argument
 - {string} locale - (Android only) the language to display Apple's Sign-in screen in.
    - Defaults to "en" (English) if not specified.
    - See [the Apple documentation](https://developer.apple.com/documentation/signinwithapplejs/incorporating_sign_in_with_apple_into_other_platforms###2112) for a list of supported locales.
    - The value is ignored on iOS which uses the locale of the device to determine the display language.

Example usage:

```javascript

FirebasePlugin.authenticateUserWithApple(function(credential) {
    FirebasePlugin.signInWithCredential(credential, function() {
            console.log("Successfully signed in");
        }, function(error) {
            console.error("Failed to sign in", error);
        });
}, function(error) {
    console.error("Failed to authenticate with Apple: " + error);
}, 'en_GB');
```
#### iOS
To use Sign In with Apple in your iOS app you need to do the following:
- Configure your app for Sign In with Apple as outlined in the [Firebase documentation's "Before you begin" section](https://firebase.google.com/docs/auth/ios/apple#before-you-begin)
- After adding the `cordova-ios` platform, open the project workspace in Xcode (`platforms/ios/YourApp.xcworkspace`) and add the "Sign In with Apple" capability in the "Signing & Capabilities section"
    - Note: AFAIK there is currently no way to automate the addition of this capability

#### Android
To use Sign In with Apple in your Android app you need to do the following:
- Configure your app for Sign In with Apple as outlined in the [Firebase documentation's "Before you begin" section](https://firebase.google.com/docs/auth/android/apple#before-you-begin)

### authenticateUserWithMicrosoft
Authenticates the user with a Microsoft account using Sign In with Oauth to obtain a credential that can be used to sign the user in/link to an existing user account/reauthenticate the user.
- Follow [Firebase documentation's "Authenticate Using Microsoft" section](https://firebase.google.com/docs/auth/web/microsoft-oauth)

**Parameters**:
- {function} success - callback function to pass {object} credentials to as an argument. The credential object has the following properties:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript

FirebasePlugin.authenticateUserWithMicrosoft(function(credential) {
    FirebasePlugin.signInWithCredential(credential, function() {
            console.log("Successfully signed in");
        }, function(error) {
            console.error("Failed to sign in", error);
        });
}, function(error) {
    console.error("Failed to authenticate with Microsoft: " + error);
});
```

### signInWithCredential
Signs the user into Firebase with credentials obtained via an authentication method such as `verifyPhoneNumber()` or `authenticateUserWithGoogle()`.
See the [Android-](https://firebase.google.com/docs/auth/android/phone-auth#sign-in-the-user) and [iOS](https://firebase.google.com/docs/auth/ios/phone-auth#sign-in-the-user-with-the-verification-code)-specific Firebase documentation for more info.

**Parameters**:
- {object} credential - a credential object returned by the success callback of an authentication method; may have the following keys:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
        Present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `true`, or if another authentication method was used such as `authenticateUserWithGoogle()`.
    - {boolean} instantVerification - true if an Android device and instant verification or auto-retrieval was used to verify the user.
    If true, you do not need to provide a user-entered verification.
        - Only present if the credential was obtained via `verifyPhoneNumber()`
    - {string} verificationId - the verification ID to accompany the user-entered verification code from the SMS.
        - Only present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`.
    - {string} code - if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`, you must set this to the activation code value as entered by the user from the received SMS message.
- {function} success - callback function to call on successful sign-in using credentials
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
function signInWithCredential(credential){
    FirebasePlugin.signInWithCredential(credential, function() {
        console.log("Successfully signed in");
    }, function(error) {
        console.error("Failed to sign in", error);
    });
}

```

### linkUserWithCredential
Links an existing Firebase user account with credentials obtained via an authentication method such as `verifyPhoneNumber()` or `authenticateUserWithGoogle()`.
See the [Android-](https://firebase.google.com/docs/auth/android/account-linking) and [iOS](https://firebase.google.com/docs/auth/ios/account-linking)-specific Firebase documentation for more info.

**Parameters**:
- {object} credential - a credential object returned by the success callback of an authentication method; may have the following keys:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
        Present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `true`, or if another authentication method was used such as `authenticateUserWithGoogle()`.
    - {boolean} instantVerification - true if an Android device and instant verification or auto-retrieval was used to verify the user.
    If true, you do not need to provide a user-entered verification.
        - Only present if the credential was obtained via `verifyPhoneNumber()`
    - {string} verificationId - the verification ID to accompany the user-entered verification code from the SMS.
        - Only present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`.
    - {string} code - if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`, you must set this to the activation code value as entered by the user from the received SMS message.
- {function} success - callback function to call on successful linking using credentials
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
function linkUserWithCredential(credential){
    FirebasePlugin.linkUserWithCredential(credential, function() {
        console.log("Successfully linked");
    }, function(error) {
        console.error("Failed to link", error);
    });
}

```

### reauthenticateWithCredential
Reauthenticates the currently signed in user with credentials obtained via an authentication method such as `verifyPhoneNumber()` or `authenticateUserWithGoogle()`.

**Parameters**:
- {object} credential - a credential object returned by the success callback of an authentication method; may have the following keys:
    - {string} id - the identifier of a native credential object which can be used for signing in the user.
        Present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `true`, or if another authentication method was used such as `authenticateUserWithGoogle()`.
    - {boolean} instantVerification - true if an Android device and instant verification or auto-retrieval was used to verify the user.
    If true, you do not need to provide a user-entered verification.
        - Only present if the credential was obtained via `verifyPhoneNumber()`
    - {string} verificationId - the verification ID to accompany the user-entered verification code from the SMS.
        - Only present if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`.
    - {string} code - if the credential was obtained via `verifyPhoneNumber()` and `instantVerification` is `false`, you must set this to the activation code value as entered by the user from the received SMS message.
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
    FirebasePlugin.reauthenticateWithCredential(credential, function() {
        console.log("Successfully reauthenticated");
    }, function(error) {
        console.error("Failed to reauthenticate", error);
    });
```

### registerAuthStateChangeListener
Registers a Javascript function to invoke when Firebase Authentication state changes between user signed in/signed out.

**Parameters**:
- {function} fn - callback function to invoke when authentication state changes
    - Will be a passed a single boolean argument which is `true` if user just signed in and `false` if user just signed out.

Example usage:

```javascript
    FirebasePlugin.registerAuthStateChangeListener(function(userSignedIn){
        console.log("Auth state changed: User signed " + (userSignedIn ? "in" : "out"));
    });
```

### useAuthEmulator
Instruments your app to talk to the [Firebase Authentication emulator](https://firebase.google.com/docs/emulator-suite/connect_auth).


**Parameters**:
- {string} host - hostname or IP address of the Authentication emulator.
- {integer} port - port of the Authentication emulator.
- {function} success - callback function to call on success
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
FirebasePlugin.useAuthEmulator('localhost', 9099, function() {
    console.log("Using Firebase Authentication emulator");
}, function(error) {
    console.error("Failed to enable the Firebase Authentication emulator", error);
});
```

### getClaims
Returns the entire payload claims of the ID token including the standard reserved claims as well as the custom claims (set by developer via Admin SDK).


**Parameters**:
- {function} success - callback function to pass claims {object} to as an argument
- {function} error - callback function which will be passed a {string} error message as an argument

Example usage:

```javascript
FirebasePlugin.getClaims(function(claims) {
    // reserved claims
    console.log("email", claims.email);
    console.log("email_verified", claims.email_verified);
    console.log("name", claims.name);
    console.log("user_id", claims.user_id);

    //custom claims
    console.log("exampleClaimA", claims.exampleClaimA);
    console.log("exampleClaimB", claims.exampleClaimB);
}, function(error) {
    console.error("Failed to enable the Firebase Authentication emulator", error);
});
```

## Remote Config

### fetch
Fetch Remote Config parameter values for your app:

**Parameters**:
- {integer} cacheExpirationSeconds (optional) - cache expiration in seconds.
According to [the documentation](https://firebase.google.com/docs/remote-config/use-config-web#throttling) the default behavior is to cache for 12 hours, so if you want to quickly detect changes make sure you set this value.
- {function} success - callback function on successfully fetching remote config
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.fetch(function () {
    // success callback
}, function () {
    // error callback
});
// or, specify the cacheExpirationSeconds
FirebasePlugin.fetch(600, function () {
    // success callback
}, function () {
    // error callback
});
```

### activateFetched
Activate the Remote Config fetched config:

**Parameters**:
- {function} success - callback function which will be passed a {boolean} argument indicating whether result the current call activated the fetched config.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.activateFetched(function(activated) {
    // activated will be true if there was a fetched config activated,
    // or false if no fetched config was found, or the fetched config was already activated.
    console.log(activated);
}, function(error) {
    console.error(error);
});
```

### fetchAndActivate
Fetches and activates the Remote Config in a single operation.

**Parameters**:
- {function} success - callback function which will be passed a {boolean} argument indicating whether result the current call activated the fetched config.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.fetchAndActivate(function(activated) {
    // activated will be true if there was a fetched config activated,
    // or false if no fetched config was found, or the fetched config was already activated.
    console.log(activated);
}, function(error) {
    console.error(error);
});
```

### resetRemoteConfig
Deletes all activated, fetched and defaults configs and resets all Firebase Remote Config settings.

Android only.

**Parameters**:
- {function} success - callback function to call on successful reset.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.resetRemoteConfig(function() {
    console.log("Successfully reset remote config");
}, function(error) {
    console.error("Error resetting remote config: " + error);
});
```

### getValue
Retrieve a Remote Config value:

**Parameters**:
- {string} key - key for which to fetch associated value
- {function} success - callback function which will be passed a {string} argument containing the value stored against the specified key.
If the expected value is of a different primitive type (e.g. `boolean`, `integer`) you should cast the value to the appropriate type.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getValue("key", function(value) {
    console.log(value);
}, function(error) {
    console.error(error);
});
```

### getInfo
Get the current state of the FirebaseRemoteConfig singleton object:

**Parameters**:
- {function} success - callback function which will be passed an {object} argument containing the state info
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getInfo(function(info) {
    // how many (secs) fetch cache is valid and data will not be refetched
    console.log(info.configSettings.minimumFetchInterval);
    // value in seconds to abandon a pending fetch request made to the backend
    console.log(info.configSettings.fetchTimeout);
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

### getAll
Returns all Remote Config as key/value pairs

**Parameters**:
- {function} success - callback function which will be passed an {object} argument where key is the remote config key and value is the value as a string. If the expected key value is a different primitive type then cast it to the appropriate type.
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.getAll(function(values) {
    for(var key in values){
        console.log(key + "=" + values[key]);
    }
}, function(error) {
    console.error(error);
});
```

### setConfigSettings
Changes the default Remote Config settings:
- Fetch timeout sets how long your app should wait for new Remote Config values before timing out.
    - Useful when you don’t want your application to wait longer than X seconds to fetch new Remote Config values
- Minimum fetch interval sets the minimum interval for which you want to check for any new Remote Config parameter values.
    - Keep in mind that setting too short an interval in production might cause your app to run into rate limits.

**Parameters**:
- {integer} fetchTimeout - fetch timeout in seconds.
    - Default is 60 seconds.
    - Specify as `null` value to omit setting this value.
- {integer} minimumFetchInterval - minimum fetch inteval in seconds.
    - Default is 12 hours.
    - Specify as `null` value to omit setting this value.
    - Set to `0` to disable minimum interval entirely (**DO NOT** do this in production)
- {function} success - callback function to be call on successfully setting the remote config settings
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
var fetchTimeout = 60;
var minimumFetchInterval = 3600;
FirebasePlugin.setConfigSettings(fetchTimeout, minimumFetchInterval, function(){
    console.log("Successfully set Remote Config settings");
}, function(error){
   console.error("Error setting Remote Config settings: " + error);
});
```

### setDefaults
Sets in-app default values for your Remote Config parameters until such time as values are populated from the remote service via a fetch/activate operation.

**Parameters**:
- {object} defaults - object specifying the default remote config settings
    - key is the name of your Remote Config parameter
    - value is the default value
- {function} success - callback function to be call on successfully setting the remote config parameter defaults
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
// define defaults
var defaults = {
    my_int: 1,
    my_double: 3.14,
    my_boolean: true,
    my_string: 'hello world',
    my_json: {"foo": "bar"}
}
// set defaults
FirebasePlugin.setDefaults(defaults);

```

## Performance

### setPerformanceCollectionEnabled
Manually enable/disable performance data collection, e.g. if [disabled on app startup](#disable-data-collection-on-startup).

**Parameters**:
- {boolean} setEnabled - whether to enable or disable performance data collection

```javascript
FirebasePlugin.setPerformanceCollectionEnabled(true); // Enables performance data collection

FirebasePlugin.setPerformanceCollectionEnabled(false); // Disables performance data collection
```

### isPerformanceCollectionEnabled
Indicates whether performance data collection is enabled.

Notes:
- This value applies both to the current app session and subsequent app sessions until such time as it is changed.
- It returns the value set by [setPerformanceCollectionEnabled()](#setperformancecollectionenabled).
- If automatic data collection was not [disabled on app startup](#disable-data-collection-on-startup), this will always return `true`.

**Parameters**:
- {function} success - callback function which will be invoked on success.
Will be passed a {boolean} indicating if the setting is enabled.
- {function} error - (optional) callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.isPerformanceCollectionEnabled(function(enabled){
    console.log("Performance data collection is "+(enabled ? "enabled" : "disabled"));
}, function(error){
    console.error("Error getting Performance data collection setting: "+error);
});
```

### startTrace

Start a trace.

**Parameters**:
- {string} name - name of trace to start
- {function} success - callback function to call on successfully starting trace
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.startTrace("test trace", success, error);
```

### incrementCounter

To count the performance-related events that occur in your app (such as cache hits or retries), add a line of code similar to the following whenever the event occurs, using a string other than retry to name that event if you are counting a different type of event:

**Parameters**:
- {string} name - name of trace
- {string} counterName - name of counter to increment
- {function} success - callback function to call on successfully incrementing counter
- {function} error - callback function which will be passed a {string} error message as an argument


```javascript
FirebasePlugin.incrementCounter("test trace", "retry", success, error);
```

### stopTrace

Stop the trace

**Parameters**:
- {string} name - name of trace to stop
- {function} success - callback function to call on successfully stopping trace
- {function} error - callback function which will be passed a {string} error message as an argument

```javascript
FirebasePlugin.stopTrace("test trace");
```

## Firestore
These plugin API functions provide CRUD operations for working with documents in Firestore collections.

Notes:
- Only top-level Firestore collections are currently supported - [subcollections](https://firebase.google.com/docs/firestore/manage-data/structure-data#subcollections) (nested collections within documents) are currently not supported due to the complexity of mapping the native objects into the plugin's JS API layer.
- A document object may contain values of primitive Javascript types `string`, `number`, `boolean`, `array` or `object`.
Arrays and objects may contain nested structures of these types.
- If a collection name referenced in a document write operation does not already exist, it will be created by the first write operation referencing it.

### addDocumentToFirestoreCollection
Adds a new document to a Firestore collection, which will be allocated an auto-generated document ID.

**Parameters**:
- {object} document - document object to add to collection
- {string} collection - name of top-level collection to add document to.
- {boolean} timestamp (optional) - Add 'created' and 'lastUpdate' variables in the document. Default ```false```.
- {function} success (optional) - callback function to call on successfully adding the document.
Will be passed a {string} argument containing the auto-generated document ID that the document was stored against.
- {function} error (optional) - callback function which will be passed a {string} error message as an argument.

```javascript
var document = {
    "a_string": "foo",
    "a_list": [1, 2, 3],
    "an_object": {
        "an_integer": 1,
    }
};
var collection = "my_collection";

// with timestamp
FirebasePlugin.addDocumentToFirestoreCollection(document, collection, true, function(documentId){
    console.log("Successfully added document with id="+documentId);
}, function(error){
    console.error("Error adding document: "+error);
});

// without timestamp
FirebasePlugin.addDocumentToFirestoreCollection(document, collection, function(documentId){
    console.log("Successfully added document with id="+documentId);
}, function(error){
    console.error("Error adding document: "+error);
});
```

### setDocumentInFirestoreCollection
Sets (adds/replaces) a document with the given ID in a Firestore collection.

**Parameters**:
- {string} documentId - document ID to use when setting document in the collection.
- {object} document - document object to set in collection.
- {string} collection - name of top-level collection to set document in.
- {boolean} timestamp (optional) - Add 'lastUpdate' variable in the document. Default ```false```.
- {function} success (optional) - callback function to call on successfully setting the document.
- {function} error (optional) - callback function which will be passed a {string} error message as an argument.

```javascript
var documentId = "my_doc";
var document = {
    "a_string": "foo",
    "a_list": [1, 2, 3],
    "an_object": {
        "an_integer": 1,
    }
};
var collection = "my_collection";

// with timestamp
FirebasePlugin.setDocumentInFirestoreCollection(documentId, document, collection, true, function(){
    console.log("Successfully set document with id="+documentId);
}, function(error){
    console.error("Error setting document: "+error);
});

// without timestamp
FirebasePlugin.setDocumentInFirestoreCollection(documentId, document, collection, function(){
    console.log("Successfully set document with id="+documentId);
}, function(error){
    console.error("Error setting document: "+error);
});
```

### updateDocumentInFirestoreCollection
Updates an existing document with the given ID in a Firestore collection.
This is a non-destructive update that will only overwrite existing keys in the existing document or add new ones if they don't already exist.
If the no document with the specified ID exists in the collection, an error will be raised.

**Parameters**:
- {string} documentId - document ID of the document to update.
- {object} document - entire document or document fragment to update existing document with.
- {string} collection - name of top-level collection to update document in.
- {boolean} timestamp (optional) - Add 'lastUpdate' variable in the document. Default ```false```.
- {function} success (optional) - callback function to call on successfully updating the document.
- {function} error (optional) - callback function which will be passed a {string} error message as an argument.

```javascript
var documentId = "my_doc";
var documentFragment = {
    "a_string": "new value",
    "a_new_string": "bar"
};
var collection = "my_collection";

// with timestamp
FirebasePlugin.updateDocumentInFirestoreCollection(documentId, documentFragment, collection, true, function(){
    console.log("Successfully updated document with id="+documentId);
}, function(error){
    console.error("Error updating document: "+error);
});

// without timestamp
FirebasePlugin.updateDocumentInFirestoreCollection(documentId, documentFragment, collection, function(){
    console.log("Successfully updated document with id="+documentId);
}, function(error){
    console.error("Error updating document: "+error);
});
```

### deleteDocumentFromFirestoreCollection
Deletes an existing document with the given ID in a Firestore collection.

Note: If the no document with the specified ID exists in the collection, the Firebase SDK will still return a successful outcome.

**Parameters**:
- {string} documentId - document ID of the document to delete.
- {string} collection - name of top-level collection to delete document in.
- {function} success - callback function to call on successfully deleting the document.
- {function} error - callback function which will be passed a {string} error message as an argument.

```javascript
var documentId = "my_doc";
var collection = "my_collection";
FirebasePlugin.deleteDocumentFromFirestoreCollection(documentId, collection, function(){
    console.log("Successfully deleted document with id="+documentId);
}, function(error){
    console.error("Error deleting document: "+error);
});
```

### documentExistsInFirestoreCollection
Indicates if a document with the given ID exists in a Firestore collection.

**Parameters**:
- {string} documentId - document ID of the document.
- {string} collection - name of top-level collection to check for document.
- {function} success - callback function to call pass result.
Will be passed an {boolean} which is `true` if a document exists.
- {function} error - callback function which will be passed a {string} error message as an argument.

```javascript
var documentId = "my_doc";
var collection = "my_collection";
FirebasePlugin.documentExistsInFirestoreCollection(documentId, collection, function(exists){
    console.log("Document " + (exists ? "exists" : "doesn't exist"));
}, function(error){
    console.error("Error fetching document: "+error);
});
```

### fetchDocumentInFirestoreCollection
Fetches an existing document with the given ID from a Firestore collection.

Notes:
- If no document with the specified ID exists in the collection, the error callback will be invoked.
- If the document contains references to another document, they will be converted to the document path string to avoid circular reference issues.

**Parameters**:
- {string} documentId - document ID of the document to fetch.
- {string} collection - name of top-level collection to fetch document from.
- {function} success - callback function to call on successfully fetching the document.
Will be passed an {object} contain the document contents.
- {function} error - callback function which will be passed a {string} error message as an argument.

```javascript
var documentId = "my_doc";
var collection = "my_collection";
FirebasePlugin.fetchDocumentInFirestoreCollection(documentId, collection, function(document){
    console.log("Successfully fetched document: "+JSON.stringify(document));
}, function(error){
    console.error("Error fetching document: "+error);
});
```

### fetchFirestoreCollection
Fetches all the documents in the specific collection.

Notes:
- If no collection with the specified name exists, the error callback will be invoked.
- If the documents in the collection contain references to another document, they will be converted to the document path string to avoid circular reference issues.

**Parameters**:
- {string} collection - name of top-level collection to fetch.
- {array} filters (optional) - a list of filters to sort/filter the documents returned from your collection.
    - Supports `where`, `orderBy`, `startAt`, `endAt` and `limit` filters.
        - See the [Firestore documentation](https://firebase.google.com/docs/firestore/query-data/queries) for more details.
    - Each filter is defined as an array of filter components:
        - `where`: [`where`, `fieldName`, `operator`, `value`, `valueType`]
            - `fieldName` - name of field to match
            - `operator` - operator to apply to match
                - supported operators: `==`, `<`, `>`, `<=`, `>=`, `array-contains`
            - `value` - field value to match
            - `valueType` (optional) - type of variable to fetch value as
                - supported types: `string`, `boolean`, `integer`, `double`, `long`
                - if not specified, defaults to `string`
        - `startAt`: [`startAt`, `value`, `valueType`]
            - `value` - field value to start at
            - `valueType` (optional) - type of variable to fetch value as (as above)
        - `endAt`: [`endAt`, `value`, `valueType`]
            - `value` - field value to end at
            - `valueType` (optional) - type of variable to fetch value as (as above)
        - `orderBy`: [`orderBy`, `fieldName`, `sortDirection`]
            - `fieldName` - name of field to order by
            - `sortDirection` - direction to order in: `asc` or `desc`
        - `limit`: [`limit`, `value`]
            - `value` - `integer` defining maximum number of results to return.

- {function} success - callback function to call on successfully deleting the document.
Will be passed an {object} containing all the documents in the collection, indexed by document ID.
If a Firebase collection with that name does not exist or it contains no documents, the object will be empty.
- {function} error - callback function which will be passed a {string} error message as an argument.

```javascript
var collection = "my_collection";
var filters = [
    ['where', 'my_string', '==', 'foo'],
    ['where', 'my_integer', '>=', 0, 'integer'],
    ['where', 'my_boolean', '==', true, 'boolean'],
    ['orderBy', 'an_integer', 'desc'],
    ['startAt', 'an_integer', 10, 'integer'],
    ['endAt', 'an_integer', 100, 'integer'],
    ['limit', 100000]
];

FirebasePlugin.fetchFirestoreCollection(collection, filters, function(documents){
    console.log("Successfully fetched collection: "+JSON.stringify(documents));
}, function(error){
    console.error("Error fetching collection: "+error);
});
```

### listenToDocumentInFirestoreCollection
Adds a listener to detect real-time changes to the specified document.

Note: If the document contains references to another document, they will be converted to the document path string to avoid circular reference issues.

Upon adding a listener using this function, the success callback function will be invoked with an `id` event which specifies the native ID of the added listener.
This can be used to subsequently remove the listener using [`removeFirestoreListener()`](#removefirestorelistener).
For example:

```json
{
  "eventType": "id",
  "id": 12345
}
```

The callback will also be immediately invoked again with a `change` event which contains a snapshot of the document at the time of adding the listener.
Then each time the document is changed, either locally or remotely, the callback will be invoked with another `change` event detailing the change.

Event fields:
- `source` - specifies if the change was `local` (made locally on the app) or `remote` (made via the server).
- `fromCache` - specifies whether the snapshot was read from local cache
- `snapshot` - a snapshot of document at the time of the change.
    - May not be present if change event is due to a metadata change.

For example:

```json
{
    "eventType": "change",
    "source": "remote",
    "fromCache": true,
    "snapshot": {
        "a_field": "a_value"
    }
}
```

See the [Firestore documentation](https://firebase.google.com/docs/firestore/query-data/listen) for more info on real-time listeners.


**Parameters**:
- {function} success - callback function to call on successfully adding the listener AND on subsequently detecting changes to that document.
Will be passed an {object} representing the `id` or `change` event.
- {function} error - callback function which will be passed a {string} error message as an argument.
- {string} documentId - document ID of the document to listen to.
- {string} collection - name of top-level collection to listen to the document in.
- {boolean} includeMetadata - whether to listen for changes to document metadata.
    - Defaults to `false`.
    - See [Events for metadata changes](https://firebase.google.com/docs/firestore/query-data/listen#events-metadata-changes) for more info.


```javascript
var documentId = "my_doc";
var collection = "my_collection";
var includeMetadata = true;
var listenerId;

FirebasePlugin.listenToDocumentInFirestoreCollection(function(event){
    switch(event.eventType){
        case "id":
            listenerId = event.id;
            console.log("Successfully added document listener with id="+listenerId);
            break;
        case "change":
            console.log("Detected document change");
            console.log("Source of change: " + event.source);
            console.log("Read from local cache: " + event.fromCache);
            if(event.snapshot){
                console.log("Document snapshot: " + JSON.stringify(event.snapshot));
            }
            break;
    }
}, function(error){
    console.error("Error adding listener: "+error);
}, documentId, collection, includeMetadata);
```

### listenToFirestoreCollection
Adds a listener to detect real-time changes to documents in a Firestore collection.

Note: If the documents in the collection contain references to another document, they will be converted to the document path string to avoid circular reference issues.

Upon adding a listener using this function, the success callback function will be invoked with an `id` event which specifies the native ID of the added listener.
This can be used to subsequently remove the listener using [`removeFirestoreListener()`](#removefirestorelistener).
For example:

```json
{
  "eventType": "id",
  "id": 12345
}
```
The callback will also be immediately invoked again with a `change` event which contains a snapshot of all documents in the collection at the time of adding the listener.
Then each time document(s) in the collection change, either locally or remotely, the callback will be invoked with another `change` event detailing the change.

Event fields:
- `documents` - key/value list of document changes indexed by document ID. For each document change:
    - `source` - specifies if the change was `local` (made locally on the app) or `remote` (made via the server).
    - `fromCache` - specifies whether the snapshot was read from local cache
    - `type` - specifies the change type:
        - `added` - document was added to collection
        - `modified` - document was modified in collection
        - `removed` - document was removed from collection
        - `metadata` - document metadata changed
    - `snapshot` - a snapshot of document at the time of the change.
        - May not be present if change event is due to a metadata change.

For example:

```json
{
    "eventType": "change",
    "documents":{
        "a_doc": {
            "source": "remote",
            "fromCache": false,
            "type": "added",
            "snapshot": {
                "a_field": "a_value"
            }
        },
        "another_doc": {
            "source": "remote",
            "fromCache": false,
            "type": "removed",
            "snapshot": {
                "foo": "bar"
            }
        }
    }
}
```

See the [Firestore documentation](https://firebase.google.com/docs/firestore/query-data/listen) for more info on real-time listeners.


**Parameters**:
- {function} success - callback function to call on successfully adding the listener AND on subsequently detecting changes to that collection.
Will be passed an {object} representing the `id` or `change` event.
- {function} error - callback function which will be passed a {string} error message as an argument.
- {string} collection - name of top-level collection to listen to the document in.
- {array} filters (optional) - a list of filters to sort/filter the documents returned from your collection.
    - See [fetchFirestoreCollection](#fetchfirestorecollection)
- {boolean} includeMetadata (optional) - whether to listen for changes to document metadata.
    - Defaults to `false`.
    - See [Events for metadata changes](https://firebase.google.com/docs/firestore/query-data/listen#events-metadata-changes) for more info.


```javascript
var collection = "my_collection";
var filters = [
    ['where', 'field', '==', 'value'],
    ['orderBy', 'field', 'desc']
];
var includeMetadata = true;
var listenerId;

FirebasePlugin.listenToFirestoreCollection(function(event){
    switch(event.eventType){
        case "id":
            listenerId = event.id;
            console.log("Successfully added collection listener with id="+listenerId);
            break;
        case "change":
            console.log("Detected collection change");
            if(event.documents){
                for(var documentId in event.documents){
                    console.log("Document ID: " + documentId);

                    var docChange = event.documents[documentId];
                    console.log("Source of change: " + docChange.source);
                    console.log("Change type: " + docChange.type);
                    console.log("Read from local cache: " + docChange.fromCache);
                    if(docChange.snapshot){
                        console.log("Document snapshot: " + JSON.stringify(docChange.snapshot));
                    }
                }
            }
            break;
    }
}, function(error){
    console.error("Error adding listener: "+error);
}, collection, filters, includeMetadata);
```

### removeFirestoreListener
Removes an existing native Firestore listener (see [detaching listeners](https://firebase.google.com/docs/firestore/query-data/listen#detach_a_listener)) added with [`listenToDocumentInFirestoreCollection()`](#listentodocumentinfirestorecollection) or [`listenToFirestoreCollection()`](#listentofirestorecollection).

Upon adding a listener using either of the above functions, the success callback function will be invoked with an `id` event which specifies the native ID of the added listener.
For example:

```json
{
  "eventType": "id",
  "id": 12345
}
```
This can be used to subsequently remove the listener using this function.
You should remove listeners when you're not using them as while active they maintain a continual HTTP connection to the Firebase servers costing memory, bandwith and money: see [best practices for realtime updates](https://firebase.google.com/docs/firestore/best-practices#realtime_updates) and [billing for realtime updates](https://firebase.google.com/docs/firestore/pricing#listens).

**Parameters**:
- {function} success - callback function to call on successfully removing the listener.
- {function} error - callback function which will be passed a {string} error message as an argument.
- {string|number} listenerId - ID of the listener to remove

```javascript
FirebasePlugin.removeFirestoreListener(function(){
    console.log("Successfully removed listener");
}, function(error){
    console.error("Error removing listener: "+error);
}, listenerId);
```

## Functions
Exposes API methods of the [Firebase Functions SDK](https://firebase.google.com/docs/functions/callable).

### functionsHttpsCallable
Call a firebase [Https Callable function](https://firebase.google.com/docs/functions/callable)

**Parameters**:
- {string} name - the name of the function
- {object} args - arguments to send to the function
- {function} success - callback function to call on successfully completed the function call.
Will be passed an {object/array/string} containing the data returned by the function
- {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
var functionName = "myBackendFunction";
var args = {
    arg1: 'First argument',
    arg2: 'second argument'
};
FirebasePlugin.functionsHttpsCallable(functionName, args, function(result){
    console.log("Successfully called function: "+JSON.stringify(result));
}, function(error){
    console.error("Error calling function: "+JSON.stringify(error));
});
```

## Installations
Exposes API methods of the [Firebase Installations SDK](https://firebase.google.com/docs/projects/manage-installations).

### getInstallationId
[Returns the current Firebase installation ID (FID)](https://firebase.google.com/docs/projects/manage-installations#retrieve_client_identifers).

**Parameters**:
- {function} success - callback function to call on successfully completed the function call.
Will be passed the {string} Firebase installation ID.
- {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasePlugin.getInstallationId(function(id){
        console.log("Got installation ID: " + id);
    }, function(error) {
        console.error("Failed to get installation ID", error);
    });
```

### getInstallationToken
[Returns the JWT auth token](https://firebase.google.com/docs/projects/manage-installations#retrieve-fis-token) for the current Firebase installation ID (FID).

**Parameters**:
- {function} success - callback function to call on successfully completed the function call.
Will be passed the {string} Firebase installation token.
- {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasePlugin.getInstallationToken(function(token){
        console.log("Got installation token: " + token);
    }, function(error) {
        console.error("Failed to get installation token", error);
    });
```

### getInstallationId
[Deletes the current Firebase installation ID (FID)](https://firebase.google.com/docs/projects/manage-installations#delete-fid).

**Parameters**:
- {function} success - callback function to call on successfully completed the function call.
- {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasePlugin.deleteInstallationId(function(){
        console.log("Deleted installation ID");
    }, function(error) {
        console.error("Failed to delete installation ID", error);
    });
```

### registerInstallationIdChangeListener
Registers a Javascript function to invoke when [Firebase Installation ID changes](https://firebase.google.com/docs/projects/manage-installations#monitor-id-lifecycle).

iOS only.

**Parameters**:
- {function} fn - callback function to invoke when installation ID changes.
    - Will be a passed a single {string} argument which is the new installation ID.

Example usage:

```javascript
    FirebasePlugin.registerInstallationIdChangeListener(function(installationId){
        console.log("New installation ID: "+installationId);
    });
```

# Credits
- [@robertarnesson](https://github.com/robertarnesson) for the original [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) from which this plugin is forked.
- [@sagrawal31](https://github.com/sagrawal31) and [Wiz Panda](https://github.com/wizpanda) for contributions via [cordova-plugin-firebase-lib](https://github.com/wizpanda/cordova-plugin-firebase-lib).
- [Full list of contributors](https://github.com/dpa99c/cordova-plugin-firebasex/graphs/contributors)

# cordova-plugin-firebasex
This plugin is a fork of [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) which has been updated to fix several issues.

It brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!  Android and iOS supported.

<!-- DONATE -->
[![donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZRD3W47HQ3EMJ)

I dedicate a considerable amount of my free time to developing and maintaining this Cordova plugin, along with my other Open Source software.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance. Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Supported Cordova Versions](#supported-cordova-versions)
- [Migrating from cordova-plugin-firebase](#migrating-from-cordova-plugin-firebase)
- [Installation](#installation)
  - [Specifying dependent library versions](#specifying-dependent-library-versions)
- [Usage notes](#usage-notes)
  - [Android](#android)
    - [AndroidX](#androidx)
  - [iOS](#ios)
    - [Strip debug symbols](#strip-debug-symbols)
- [Guides](#guides)
- [Setup](#setup)
- [IMPORTANT NOTES](#important-notes)
  - [PhoneGap Build](#phonegap-build)
  - [Google Play Services](#google-play-services)
  - [Google Tag Manager](#google-tag-manager)
- [Configuring Notifications](#configuring-notifications)
- [API](#api)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Supported Cordova Versions
- cordova: `>= 8`
- cordova-android: `>= 8`
- cordova-ios: `>= 4`

## Migrating from cordova-plugin-firebase
If you already have [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) installed in your Cordova project, you need to completely remove it before installing this plugin otherwise they will conflict and cause build errors in your project. The safest way of doing this is as follows:

    rm -Rf platforms/android
    cordova plugin rm cordova-plugin-firebase
    rm -Rf plugins/ node_modules/
    npm install
    cordova plugin add cordova-plugin-firebasex
    cordova platform add android
    

## Installation
Install the plugin by adding it to your project's config.xml:
```
<plugin name="cordova-plugin-firebasex" spec="latest" />
```
or by running:
```
cordova plugin add cordova-plugin-firebasex
```

### Specifying dependent library versions
This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Gradle on Android and Cocoapods on iOS.
By default this plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebase/blob/master/plugin.xml) where you can find the currently pinned Android & iOS versions as `<preference>`'s, for example:

    <preference name="ANDROID_FIREBASE_CORE_VERSION" default="17.0.0" />

These defaults can be overridden at plugin installation time by specifying plugin variables as command-line arguments, for example:

    cordova plugin add cordova-plugin-firebasex --variable ANDROID_FIREBASE_CORE_VERSION=17.0.0
    
Or you can specify them as plugin variables in your `config.xml`, for example:

    <plugin name="cordova-plugin-firebasex" spec="latest">
        <variable name="ANDROID_FIREBASE_CORE_VERSION" value="17.0.0" />
    </plugin>
    
The following plugin variables are use to specify the follow Gradle dependency versions on Android:

- `ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION` => `com.google.android.gms:play-services-tagmanager`
- `ANDROID_FIREBASE_CORE_VERSION` => `com.google.firebase:firebase-core`
- `ANDROID_FIREBASE_MESSAGING_VERSION` => `com.google.firebase:firebase-messaging`
- `ANDROID_FIREBASE_CONFIG_VERSION` => `com.google.firebase:firebase-config`
- `ANDROID_FIREBASE_PERF_VERSION` => `com.google.firebase:firebase-perf`
- `ANDROID_FIREBASE_AUTH_VERSION` => `com.google.firebase:firebase-auth`
- `ANDROID_CRASHLYTICS_VERSION` => `com.crashlytics.sdk.android:crashlytics`
- `ANDROID_CRASHLYTICS_NDK_VERSION` => `com.crashlytics.sdk.android:crashlytics-ndk`
- `ANDROID_SHORTCUTBADGER_VERSION` => `me.leolin:ShortcutBadger`

For example, to explicitly specify all the component versions at plugin install time:

    cordova plugin add cordova-plugin-firebasex \
        --variable ANDROID_PLAY_SERVICES_TAGMANAGER_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_CORE_VERSION=17.0.0 \
        --variable ANDROID_FIREBASE_MESSAGING_VERSION=19.0.0 \
        --variable ANDROID_FIREBASE_CONFIG_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_PERF_VERSION=18.0.0 \
        --variable ANDROID_FIREBASE_AUTH_VERSION=18.0.0 \
        --variable ANDROID_CRASHLYTICS_VERSION=2.10.1 \
        --variable ANDROID_CRASHLYTICS_NDK_VERSION=2.1.0 \
        --variable ANDROID_SHORTCUTBADGER_VERSION=1.1.22 \

## Usage notes
### Android
#### AndroidX
This plugin has been migrated to use [AndroidX (Jetpack)](https://developer.android.com/jetpack/androidx/migrate) which is the successor to the [Android Support Library](https://developer.android.com/topic/libraries/support-library/index).
This is implemented by adding a dependency on [cordova-plugin-androidx](https://github.com/dpa99c/cordova-plugin-androidx) which enables AndroidX in the Android platform of a Cordova project.

This is because the [major release of the Firebase and Play Services libraries on 17 June 2019](https://developers.google.com/android/guides/releases#june_17_2019) were migrated to AndroidX.

Therefore if your project includes any plugins which are dependent on the legacy Android Support Library, you should add [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter) to your project.
This plugin will dynamically migrate any plugin code from the Android Support Library to AndroidX equivalents.

### iOS
#### Strip debug symbols
If your iOS app build contains too many debug symbols (i.e. because you include lots of libraries via a Cocoapods), you might get an error (e.g. [issue #28](https://github.com/dpa99c/cordova-plugin-firebase/issues/28)) when you upload your binary to App Store Connect, e.g.:

    ITMS-90381: Too many symbol files - These symbols have no corresponding slice in any binary [16EBC8AC-DAA9-39CF-89EA-6A58EB5A5A2F.symbols, 1B105D69-2039-36A4-A04D-96C1C5BAF235.symbols, 476EACDF-583B-3B29-95B9-253CB41097C8.symbols, 9789B03B-6774-3BC9-A8F0-B9D44B08DCCB.symbols, 983BAE60-D245-3291-9F9C-D25E610846AC.symbols].

To prevent this, you'll need to edit the `platforms/ios/Podfile` to add a config block to prevent symbolification of all libraries included via Cocoapods - (see here)[https://stackoverflow.com/a/48518656/777265]

Then run `pod install` from `platforms/ios/`

Note: if you do this, any crashes that occur within libraries included via Cocopods will not be recorded in Crashlytics or other crash reporting services.

## Guides
Great installation and setup guide by Medium.com - [https://medium.com/@felipepucinelli/how-to-add-push...](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821)

## Setup
Download your Firebase configuration files, GoogleService-Info.plist for iOS and google-services.json for android, and place them in the root folder of your cordova project.  Check out this [firebase article](https://support.google.com/firebase/answer/7015592) for details on how to download the files.

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

## IMPORTANT NOTES
- This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely `platforms/ios/\<My Project\>/Resources` for ios and `platforms/android` for android.
- Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

### PhoneGap Build
Hooks do not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see `src/ios` and `src/android`) with your actual ones, as well as hard coding your app id and api key in `plugin.xml`.

### Google Play Services
Your build may fail if you are installing multiple plugins that use Google Play Services.  This is caused by the plugins installing different versions of the Google Play Services library.  This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release).

If your build is still failing, you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release).  For more info, read the following [comment](https://github.com/dpa99c/cordova-plugin-request-location-accuracy/issues/50#issuecomment-390025013) about locking down the specific versions for play services and firebase.

### Google Tag Manager

Checkout our [guide](docs/GOOGLE_TAG_MANAGER.md) for info on setting up Google Tag Manager.

## Configuring Notifications

Checkout our [guide](docs/NOTIFICATIONS.md) for info on configuring notification icons and colors.

## API

See the full [API](docs/API.md) available for this plugin.


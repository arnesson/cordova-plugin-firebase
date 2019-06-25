# Cordova Firebase Plugin2

[![npm version](https://badge.fury.io/js/cordova-plugin-firebase-lib.svg)](https://badge.fury.io/js/cordova-plugin-firebase-lib)

This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!

## Table of Contents

<!-- toc -->

- [4.0.0 - Breaking Change](#400---breaking-change)
- [Difference from the fork repository](#difference-from-the-fork-repository)
- [Installation](#installation)
  * [Uninstall the original firebase plugin](#uninstall-the-original-firebase-plugin)
  * [For `cordova-android >= 8.x.x`](#for-cordova-android--8xx)
  * [For `cordova-android <= 7.1.4`](#for-cordova-android--714)
  * [AndroidX](#androidx)
- [Supported Cordova Versions](#supported-cordova-versions)
- [Guides](#guides)
  * [Setup](#setup)
        * [IMPORTANT NOTES](#important-notes)
  * [PhoneGap Build](#phonegap-build)
  * [Google Play Services](#google-play-services)
- [Docs](#docs)
  * [API](#api)
  * [Google Tag Manager](#google-tag-manager)
  * [Configuring Notifications](#configuring-notifications)

<!-- tocstop -->

## Difference from the fork repository

Maintained by [Wiz Panda](https://www.wizpanda.com/).

The [author](https://github.com/arnesson) did a great job on the plugin. But seems not to be maintaining the changes. So we at **Wiz Panda**
thought to maintain the repository with the latest changes & fixes so the others can take benefit of the Firebase in their cordova 
application. To see a full list of changes done after we started maintaining this fork, please see the [Releases](https://github
.com/wizpanda/cordova-plugin-firebase-lib/releases) or read the [CHANGELOG.md](https://github.com/wizpanda/cordova-plugin-firebase-lib/blob/master/CHANGELOG.md#v300)

## Major Releases

In the last week from Jun 17, 2019 to Jun 25, 2019, we released three major versions of this plugin so that developers across the globe, 
who are using different versions of `cordova-lib`, `cordova-android` & `cordova-ios` can use different version of this plugin without 
needing to upgrade these 3 dependencies immediately.

So here are the three major releases of this plugin:

### v5.x

1. CocoaPods is used to manage Firebase dependencies for iOS

#### Supported Cordova Platforms

- cordova-cli: `>= 9.0.0`
- cordova-lib: `>= 9.0.0` (Will be used automatically by `cordova-cli`)
- cordova-android: `>= 8.0.0`
- cordova-ios: `>= 5.0.1`

### v4.x

1. Minimum `v8.0.0` of `cordova-android` is now required. View [#13](https://github.com/wizpanda/cordova-plugin-firebase-lib/pull/13) for details.
2. Using latest versions of Firebase Android dependencies.

#### Supported Cordova Platforms

- cordova: `>= 8.0.0`
- cordova-lib: `>= 8.0.0` (Will be used automatically by `cordova-cli`)
- cordova-android: `>= 8.0.0`
- cordova-ios: `>= 4.5.5`

### v3.x

1. Using last [released](https://firebase.google.com/support/release-notes/android#update_-_may_31_2019) Firebase Android dependencies 
which was released before Jun 17, 2019.

#### Supported Cordova Platforms

- cordova: `>= 7.0.0`
- cordova-android: `>= 7.0.0` (Might work on `cordova-android 6.x` versions)
- cordova-ios: `>= 4.5.5` (Might work on old `cordova-ios` versions)

## Installation

### Uninstall the original firebase plugin

If you are using the [original](https://github.com/arnesson/cordova-plugin-firebase) firebase plugin, remove it first:

```bash
rm -rf platforms/android
cordova plugin remove cordova-plugin-firebase
```

### For `cordova-android >= 8.x.x`

Since `v4.0.0`, this plugin no longer support `cordova-android 7.x.x` because of the breaking change released by Google on Jun 17, 2019. 
See https://github.com/wizpanda/cordova-plugin-firebase-lib/pull/13

To install the latest version, run the following in your terminal:

```bash
cordova plugin add cordova-plugin-firebase-lib --save
```

### For `cordova-android <= 7.1.4`

Run the following in your terminal:

```bash
cordova plugin add cordova-plugin-firebase-lib@3.3.0 --save
```

Or add the following in your `config.xml`:

```xml
<plugin name="cordova-plugin-firebase-lib" spec="^3.3.0" />
```

### AndroidX

Because of the major breaking release by Google Firebase on [Jun 17, 2019](https://developers.google.com/android/guides/releases#june_17_2019)
this plugin has been migrated to use [AndroidX](https://developer.android.com/jetpack/androidx/migrate). AndroidX is a major improvement 
to the original Android [Support Library](https://developer.android.com/topic/libraries/support-library/index).

If any of your Cordova app includes any plugin which is still using legacy Android Support Library, then installing this plugin might 
break your build. For that install the following plugins:

```bash
cordova plugin add cordova-plugin-androidx
cordova plugin add cordova-plugin-androidx-adapter
```

## Guides

1. Great installation and setup guide [https://medium.com/@felipepucinelli/how-to-add-push...](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821)

### Setup

Download your Firebase configuration files:

* `GoogleService-Info.plist` for iOS and
* `google-services.json` for Android

And place them in the root folder of your cordova project. Check out this [firebase article](https://support.google.com/firebase/answer/7015592)
for details on how to download the files.

```bash
- my-cordova-project/
    platforms/
    plugins/
    www/
    config.xml
    google-services.json       <--
    GoogleService-Info.plist   <--
    ...
```

###### IMPORTANT NOTES
- This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely 
`platforms/ios/my-cordova-project/Resources` for iOS and `platforms/android` for Android.
- Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

### PhoneGap Build
Hooks do not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see `src/ios` and `src/android`) with your actual ones, as well as hard coding your app id and api key in `plugin.xml`.

### Google Play Services
Your build may fail if you are installing multiple plugins that use Google Play Services.  This is caused by the plugins installing different versions of the Google Play Services library.  This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release).

If your build is still failing, you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release).  For more info, read the following [comment](https://github.com/dpa99c/cordova-plugin-request-location-accuracy/issues/50#issuecomment-390025013) about locking down the specific versions for play services and firebase. It is suggested to use `+` instead of `15.+` to ensure the correct versions are used.

## Docs

### API

See the full [API](docs/API.md) docs available for this plugin.

### Google Tag Manager

Checkout our [guide](docs/GOOGLE_TAG_MANAGER.md) for info on setting up Google Tag Manager.

### Configuring Notifications

Checkout our [guide](docs/NOTIFICATIONS.md) for info on configuring notification icons and colors.

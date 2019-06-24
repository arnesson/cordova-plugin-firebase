# Cordova Firebase Plugin2

[![npm version](https://badge.fury.io/js/cordova-plugin-firebase-lib.svg)](https://badge.fury.io/js/cordova-plugin-firebase-lib)

This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!

## Table of Contents

- [4.0.0 - Breaking Change](#400---breaking-change)
- [Difference from the fork repository](#difference-from-the-fork-repository)
- [Installation](#installation)
  * [For `cordova-android >= 8.x.x`](#for-cordova-android--8xx)
  * [For `cordova-android <= 7.1.4`](#for-cordova-android--714)
- [Supported Cordova Versions](#supported-cordova-versions)
- [Guides](#guides)
  * [Setup](#setup)
        * [IMPORTANT NOTES](#important-notes)
  * [PhoneGap Build](#phonegap-build)
  * [cordova-lib@9 support](#cordova-lib9-support)
  * [Google Play Services](#google-play-services)
- [Google Tag Manager](#google-tag-manager)
- [Configuring Notifications](#configuring-notifications)
- [API](#api)

## 4.0.0 - Breaking Change

Minimum `v8.0.0` of `cordova-android` is now required. View https://github.com/wizpanda/cordova-plugin-firebase-lib/pull/13 for details.

## Difference from the fork repository

Maintained by [Wiz Panda](https://www.wizpanda.com/).

The [author](https://github.com/arnesson) did a great job on the plugin. But seems not to be maintaining the changes. So we at **Wiz Panda**
thought to maintain the repository with the latest changes & fixes so the others can take benefit of the Firebase in their cordova 
application.

To see a full list of changes done after we started maintaining this fork, please see the [Releases](https://github.com/wizpanda/cordova-plugin-firebase-lib/releases)
or read the [CHANGELOG.md](https://github.com/wizpanda/cordova-plugin-firebase-lib/blob/master/CHANGELOG.md#v300)

## Installation

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

## Supported Cordova Versions

- cordova: `>= 8`
- cordova-android: `>= 8.0.0`
- cordova-ios: `>= 4.5.5`

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

### cordova-lib@9 support
If you are using `cordova-cli@9` (i.e. `cordova-lib@9`) then you might need to install the `xcode` npm module dependency separately. To 
do that, just run this command `npm i xcode --save-dev` in your app.

### Google Play Services
Your build may fail if you are installing multiple plugins that use Google Play Services.  This is caused by the plugins installing different versions of the Google Play Services library.  This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release).

If your build is still failing, you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release).  For more info, read the following [comment](https://github.com/dpa99c/cordova-plugin-request-location-accuracy/issues/50#issuecomment-390025013) about locking down the specific versions for play services and firebase. It is suggested to use `+` instead of `15.+` to ensure the correct versions are used.

## Google Tag Manager

Checkout our [guide](docs/GOOGLE_TAG_MANAGER.md) for info on setting up Google Tag Manager.

## Configuring Notifications

Checkout our [guide](docs/NOTIFICATIONS.md) for info on configuring notification icons and colors.

## API

See the full [API](docs/API.md) available for this plugin.

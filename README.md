# Cordova Firebase Plugin2

[![npm version](https://badge.fury.io/js/cordova-plugin-firebase-lib.svg)](https://badge.fury.io/js/cordova-plugin-firebase-lib)

This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!

## Difference from the fork repository

Maintained by [Wiz Panda](https://www.wizpanda.com/).

The [author](https://github.com/arnesson) did a great job on the plugin. But seems not to be maintaining the changes. So we at **Wiz Panda**
thought to maintain the repository with the latest changes & fixes so the others can take benefit of the Firebase in their cordova 
application.

Here are the following changes in the first version i.e. 3.0.0

1. Cordova@9 support
2. Fixes issues cause by Firebase SDK updates on [5 April 2019](https://firebase.google.com/support/release-notes/android#update_-_april_05_2019).
Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/46a7bd1c06434fb4c5a72c2c20ae5d951a2e37f4)
3. Remove obsolete <service> entry for FirebasePluginInstanceIDService. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/eee2cfe845e6c2466d4c7fcb69d70c0c8840ea6b)
4. Remove unnecessary extra <config-file> block which can lead to race condition. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/17eb7c46176d5ad28fc93b53a2c49d9e6ed1888b)
5. Remove redundant build-extras.gradle. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/289706fc30fe848de082c468440c91ffecdce97d)

For the changes on the next versions, please check the [CHANGELOG.md](https://github.com/wizpanda/cordova-plugin-firebase-lib/blob/master/CHANGELOG.md)

## Supported Cordova Versions

- cordova: `>= 7`
- cordova-android: `>= 7.0.0`
- cordova-ios: `>= 4.5.5`

## Installation

Install the plugin by adding it to your project's `config.xml`:

```xml
<plugin name="cordova-plugin-firebase-lib" spec="^3.0.0" />
```

or by running:

```bash
cordova plugin add cordova-plugin-firebase-lib --save
```

### Guides

1. Great installation and setup guide [https://medium.com/@felipepucinelli/how-to-add-push...](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821)

### Setup

Download your Firebase configuration files:

* `GoogleService-Info.plist` for iOS and
* `google-services.json` for Android

And place them in the root folder of your cordova project. Check out this [firebase article](https://support.google
.com/firebase/answer/7015592) for details on how to download the files.

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

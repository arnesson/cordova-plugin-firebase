# cordova-plugin-firebasex
This plugin is a fork of [cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase) which has been update to fix several issues.

It brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!  Android and iOS supported.

<!-- DONATE -->
[![donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZRD3W47HQ3EMJ)

I dedicate a considerable amount of my free time to developing and maintaining this Cordova plugin, along with my other Open Source software.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance. Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->


## Supported Cordova Versions
- cordova: `>= 6`
- cordova-android: `>= 6.4`
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
<plugin name="cordova-plugin-firebasex" spec="^2.0.7" />
```
or by running:
```
cordova plugin add cordova-plugin-firebasex --save
```

### Guides
Great installation and setup guide by Medium.com - [https://medium.com/@felipepucinelli/how-to-add-push...](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821)

### Setup
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

###### IMPORTANT NOTES
- This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely `platforms/ios/\<My Project\>/Resources` for ios and `platforms/android` for android.
- Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

### PhoneGap Build
Hooks do not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see `src/ios` and `src/android`) with your actual ones, as well as hard coding your app id and api key in `plugin.xml`.

### Google Play Services
Your build may fail if you are installing multiple plugins that use Google Play Services.  This is caused by the plugins installing different versions of the Google Play Services library.  This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release).

If your build is still failing, you can try installing [cordova-android-firebase-gradle-release](https://github.com/dpa99c/cordova-android-firebase-gradle-release).  For more info, read the following [comment](https://github.com/dpa99c/cordova-plugin-request-location-accuracy/issues/50#issuecomment-390025013) about locking down the specific versions for play services and firebase. It is suggested to use `+` instead of `15.+` to ensure the correct versions are used.

## Google Tag Manager

Checkout our [guide](docs/GOOGLE_TAG_MANAGER.md) for info on setting up Google Tag Manager.

## Configuring Notifications

Checkout our [guide](docs/NOTIFICATIONS.md) for info on configuring notification icons and colors.

## API

See the full [API](docs/API.md) available for this plugin.

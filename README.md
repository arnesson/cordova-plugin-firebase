[![Build Status](https://travis-ci.org/arnesson/cordova-plugin-firebase.svg?branch=master)](https://travis-ci.org/arnesson/cordova-plugin-firebase)

# cordova-plugin-firebase
This plugin brings push notifications, analytics, event tracking, crash reporting and more from Google Firebase to your Cordova project!  Android and iOS supported.

## Supported Cordova Versions
- cordova: `>= 6`
- cordova-android: `>= 6.4`
- cordova-ios: `>= 4`

## Installation
Install the plugin by adding it to your project's config.xml:

```xml
<plugin name="cordova-plugin-firebase" spec="^2.1.0" />
```
or by running:

```shell
$ cordova plugin add cordova-plugin-firebase --save
```

### Guides
Great installation and setup guide by Medium.com - [https://medium.com/@felipepucinelli/how-to-add-push...](https://medium.com/@felipepucinelli/how-to-add-push-notifications-in-your-cordova-application-using-firebase-69fac067e821)


###### IMPORTANT NOTES
- This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely `platforms/ios/\<My Project\>/Resources` for ios and `platforms/android` for android.
- Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

### PhoneGap Build
Hooks do not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see `src/ios` and `src/android`) with your actual ones, as well as hard coding your app id and api key in `plugin.xml`.


## Google Tag Manager

Checkout our [guide](docs/GOOGLE_TAG_MANAGER.md) for info on setting up Google Tag Manager.

## Configuring Notifications

Checkout our [guide](docs/NOTIFICATIONS.md) for info on configuring notification icons and colors.

## Documentation API

See the full [documentation API](docs/index.md) available for this plugin.

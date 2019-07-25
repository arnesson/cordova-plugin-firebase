# Change Log

## v5.1.1

1. Common: Handling ampersand in app name.
2. Build: Improving JavaScript code and logging more information.

## v5.1.0

1. iOS: Downgrading the Firebase iOS dependency to 5.x to make the iOS app build fixed.
2. Common: Removed deprecated `getInstanceId` method. Use `getToken` instead.

## v5.0.0

1. iOS: Using CocoaPods to manage Firebase dependencies hence requires `cordova-cli` to be minimum `v9.0.0`.
2. Docs: Detailed instructions to get the Cordova environment versions and different major releases to be used.

## v4.1.0

1. Breaking change: Removed method `logJSError` (introduced in v3.2.0) and merged that into `logError` message.
2. Android: Handling a few edge cases for `logError` method.
3. Docs: Generating "Table of Contents" for README & API docs.

## v4.0.1

1. Fixed typo in `firebase-browser.js`

## v4.0.0 - Breaking Change

1. Stop supporting `cordova-android 7.x.x`. Minimum `cordova-android 8.0.0` is required.
2. Fix the failing build due to breaking changes released by Google Firebase on Jun 17, 2019.

## v3.3.0

1. Backward compatibility fixes to support breaking changes released by Google Firebase on Jun 17, 2019.

## v3.2.0

1. Added ability to log JavaScript stacktrace with a new method `logJSError`. Thanks to [distinctdan](https://github.com/distinctdan) for
 [PR#8](https://github.com/wizpanda/cordova-plugin-firebase-lib/pull/8).

## v3.1.0

1. Add `createChannel` function for Android O.

## v3.0.0

First version under [Wiz Panda](https://www.wizpanda.com/).

1. Cordova@9 support
2. Fixes issues cause by Firebase SDK updates on [5 April 2019](https://firebase.google.com/support/release-notes/android#update_-_april_05_2019).
Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/46a7bd1c06434fb4c5a72c2c20ae5d951a2e37f4)
3. Remove obsolete <service> entry for FirebasePluginInstanceIDService. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/eee2cfe845e6c2466d4c7fcb69d70c0c8840ea6b)
4. Remove unnecessary extra <config-file> block which can lead to race condition. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/17eb7c46176d5ad28fc93b53a2c49d9e6ed1888b)
5. Remove redundant build-extras.gradle. Thanks to [Dave Alden](https://github.com/dpa99c) for [commit](https://github.com/wizpanda/cordova-plugin-firebase-lib/commit/289706fc30fe848de082c468440c91ffecdce97d)

## For older versions

See the https://github.com/arnesson/cordova-plugin-firebase/blob/v2.0.5/CHANGELOG.md
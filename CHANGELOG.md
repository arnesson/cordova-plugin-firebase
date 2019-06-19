# Change Log

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
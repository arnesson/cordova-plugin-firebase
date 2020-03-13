# Version 9.0.1
* Re-add Firebase Inapp Messaging SDK component to master branch. 
* Document `cli_build` branch. See [#326](https://github.com/dpa99c/cordova-plugin-firebasex/issues/326).

# Version 9.0.0
* *BREAKING CHANGE*: Change method signature of `setCrashlyticsCollectionEnabled()` to `(enabled, success, error)` (from `()`) to allow enabling/disabling of Crashlytics at runtime and align it with `setPerformanceCollectionEnabled()` and `setAnalyticsCollectionEnabled()`
* Add `isCrashlyticsCollectionEnabled()` and `isCrashlyticsCollectionCurrentlyEnabled()` to respectively check if persistent Crashlytics setting is enabled and if Crashlytics is enabling during the current app session.
* Add `isAnalyticsCollectionEnabled()` and `isPerformanceCollectionEnabled()` to check if persistent settings are enabled.
* *BREAKING CHANGE*: Remove Firebase Inapp Messaging SDK component due to causing Cordova CLI build issues.
    * Resolves [#326](https://github.com/dpa99c/cordova-plugin-firebasex/issues/326).
* (iOS) Override CDVPlugin class abstract method `handleOpenURL` instead of implementing app delegate method `application:openURL:options` to prevent conflicts with other plugins. 
    * Resolves [#328](https://github.com/dpa99c/cordova-plugin-firebasex/issues/328).
* (Android) Fix parsing of existing `colors.xml` when it only contains a single `<color>` to prevent overwriting the existing value.
    * Fixes [#284](https://github.com/dpa99c/cordova-plugin-firebasex/issues/284).

# Version 8.1.1
* (Doc) Document custom FCM message handling.
* (Doc) Rationalise heading levels.
* (iOS) Implement message receiver mechanism (equivalent to existing Android mechanism) to enable custom handling of specific message types.
* (Android) Extend custom receiver to handle payload obtained from system notification message bundle received while in background/not running.
* (Android) Ignore invocation of auth state change listener at app start (same as on iOS) to prevent error due to race condition with plugin initialisation.


# Version 8.1.0
* Add support for Firebase inapp messaging
    * Merged from PR [#312](https://github.com/dpa99c/cordova-plugin-firebasex/pull/312).
* Add support for Firestore realtime database. Resolves [#190](https://github.com/dpa99c/cordova-plugin-firebasex/issues/190).
* (Doc) Add note regarding persistence of data collection settings. Resolves [#315](https://github.com/dpa99c/cordova-plugin-firebasex/issues/315).
* (iOS) Added missing Google Tag Manager Pod for iOS.
    * Merged from PR [#318](https://github.com/dpa99c/cordova-plugin-firebasex/pull/318).
* (iOS) Don't set `FirebaseScreenReportEnabled=false` in app list when `FIREBASE_ANALYTICS_COLLECTION_ENABLE=false`. Resolves [#317](https://github.com/dpa99c/cordova-plugin-firebasex/issues/317).
* (Android) Disable strict version check in Google Services plugin for Gradle as it causes erroneous build failures.

# Version 8.0.1
* Add `registerAuthStateChangeListener()` to support invocation of a callback function on the Firebase Authentication state changing. 
Resolves [#311](https://github.com/dpa99c/cordova-plugin-firebasex/issues/311). 
* (Android) Bump Firebase SDK dependency versions to latest releases. Resolves [#279](https://github.com/dpa99c/cordova-plugin-firebasex/issues/279).
* (iOS) Bump podspec versions for Firebase SDK components to [latest release (v6.17.0)](https://firebase.google.com/support/release-notes/ios#version_6170_-_february_11_2020)

# Version 8.0.0
* *BREAKING CHANGE*:  Rework `verifyPhoneNumber()` to preserve and reference the native credentials object (rather than attempting to extract and parse its properties to JS). Fixes [#176](https://github.com/dpa99c/cordova-plugin-firebasex/issues/176).
* Add other Firebase Authentication methods: Google Sign In, Sign In with Apple, email/password sign in, and authentication utility methods. Partially resolves [#208](https://github.com/dpa99c/cordova-plugin-firebasex/issues/208).
* (Android) Add check `google-services` plugin does not already exist. Fixes [#282](https://github.com/dpa99c/cordova-plugin-firebasex/issues/282).
* (iOS) Update pinned Firebase SDK versions to latest v6.13.0. Resolves [#232](https://github.com/dpa99c/cordova-plugin-firebasex/issues/232).

# Version 7.0.2
* (Android) Fix error caused by local variable
    * Merged from PR [#229](https://github.com/dpa99c/cordova-plugin-firebasex/pull/229).
* (iOS Hook) Fix retrieving Xcode project path
    * Merged from PR [#234](https://github.com/dpa99c/cordova-plugin-firebasex/pull/234).
* (Android) Check google-services plugin doesn't already exist in Gradle script   
    * Merged from PR [#281](https://github.com/dpa99c/cordova-plugin-firebasex/pull/281).

# Version 7.0.1
* (Android) Replace references to cordovaActivity with applicationContext when app is not running and therefore cordovaActivity doesn't exist. 
Resolves [#165](https://github.com/dpa99c/cordova-plugin-firebasex/issues/165).
* Fix .forEach is not a function.
Merged from PR [#219](https://github.com/dpa99c/cordova-plugin-firebasex/pull/219).
Resolves [#213](https://github.com/dpa99c/cordova-plugin-firebasex/issues/213).
* (Android) Parse this plugin's `plugin.xml` to extract default values for plugin variables not explicitly set at plugin install time.
Fixes [#218](https://github.com/dpa99c/cordova-plugin-firebasex/issues/218).
* (iOS) Fix after_prepare hook to run on multiple platforms so if they are added in one operation using `cordova prepare`, both platforms are processed.
Fixes [#221](https://github.com/dpa99c/cordova-plugin-firebasex/issues/221).
* (Typedef) Update the typedef for recent plugin API changes.

# Version 7.0.0
* (iOS) Update Firebase SDK to [v6.11.0 released 22 Oct 2019](https://firebase.google.com/support/release-notes/ios#version_6110_-_october_22_2019)
* (Android) Update pinned Firebase SDK versions to latest as of [25 Oct 2019](https://firebase.google.com/support/release-notes/android#2019-10-25)
Resolves [#207](https://github.com/dpa99c/cordova-plugin-firebasex/issues/207)
* (Doc) Document parameter types in API functions. 
Resolves [#140](https://github.com/dpa99c/cordova-plugin-firebasex/issues/140)
* (Doc) fix `onMessageReceived()` code sample. 
Merged from PR [#142](https://github.com/dpa99c/cordova-plugin-firebasex/pull/142).
* (Doc) Example sound name for custom Android notification sound.
Resolves [#160](https://github.com/dpa99c/cordova-plugin-firebasex/issues/160)
* (Feat): add Typescript declaration
Merged from PR [#166](https://github.com/dpa99c/cordova-plugin-firebasex/pull/166).
* (Doc) Fix `createChannel()` examples.
Merged from PR [#167](https://github.com/dpa99c/cordova-plugin-firebasex/pull/167).
* (Android) Expose `description` notification channel field.
Merged from PR [#168](https://github.com/dpa99c/cordova-plugin-firebasex/pull/168).
* (iOS) Update CocoaPods spec url to new CDN.
Merged from PR [#173](https://github.com/dpa99c/cordova-plugin-firebasex/pull/173).
* (Doc) Fix code example for default android icon.
Merged from PR [#174](https://github.com/dpa99c/cordova-plugin-firebasex/pull/174).
* (iOS) Support iOS 13 APNS format token change.
Merged from PR [#177](https://github.com/dpa99c/cordova-plugin-firebasex/pull/177).
* (Hook) Remove check for presence of platform in `config.xml`
Merged from PR [#185](https://github.com/dpa99c/cordova-plugin-firebasex/pull/185).
* (Feat) Expose Firebase Messaging autoinit API functions to allow enabling/disabling/checking of autoinit.
    * If disabled and `unregister()` is called, a new token will not be automatically allocated.
    * Resolves [#147](https://github.com/dpa99c/cordova-plugin-firebasex/issues/147).
* (iOS) Fix `logEvent()` so it doesn't generated warning message in console. Fixes [#154](https://github.com/dpa99c/cordova-plugin-firebasex/issues/154).
* (iOS) Handle notification messages that contain `"content-available":1` which wakes up the app while in the background to deliver the message payload immediately when the message arrives (without requiring user interaction by tapping the system notification).
Fixes [#158](https://github.com/dpa99c/cordova-plugin-firebasex/issues/158).
* (Android)(Do) Clarify Android custom notification icons example. Resolves [#183](https://github.com/dpa99c/cordova-plugin-firebasex/issues/183).
* (Doc) Add example of using stacktrace.js with `logError()`.
Clarifies [#118](https://github.com/dpa99c/cordova-plugin-firebasex/issues/118).
* (Doc) Add link to [cordova-plugin-firebasex-ionic3-test](https://github.com/dpa99c/cordova-plugin-firebasex-ionic3-test) Ionic 3 example project
*  Add `signInWithCredential()` to sign user into Firebase account and `linkUserWithCredential()` to link user account with credentials obtained via `verifyPhoneNumber()`.
* (Android) *BREAKING CHANGE* Rework `verifyPhoneNumber()`
    * Remove redundant `verified` in returned credentials object.
    * Support mocking of instant verification for `verifyPhoneNumber()` on Android for integration testing.
* (iOS) *BREAKING CHANGE* Rework `verifyPhoneNumber()` 
    * Return the same credential object structure as Android.
* (iOS) Add `SETUP_RECAPTCHA_VERIFICATION` plugin variable to automatically set up reCAPTURE verification for phone auth.
* (Doc) Add section to explicitly document all supported plugin variables.
* (iOS) Add `onApnsTokenReceived()` to register a callback function to be invoked when the APNS token is allocated. 
Resolves [#201](https://github.com/dpa99c/cordova-plugin-firebasex/issues/201).
* (Android) Tweak default empty values when sending stacktrace using `logError()`
* (Doc) Better example of using `logError()` to track unhandled JS exceptions vs logging a non-fatal logical error.
* (iOS) Modify `logError()` to send stacktrace.js output as an actual stacktrace instead of custom keys. 
Resolves [#118](https://github.com/dpa99c/cordova-plugin-firebasex/issues/118).
* (Hook) Fix parsing of `config.xml` to extract app name. 
Fixes [#139](https://github.com/dpa99c/cordova-plugin-firebasex/issues/139).
* (Android) Ensure functions which return a boolean result return an actual boolean type rather than a binary integer.
Fixes [#153](https://github.com/dpa99c/cordova-plugin-firebasex/issues/153).
* (Hook) Rework hook scripts to:
    * be fully synchronous to eliminate race conditions (remove q dependency)
    * use [xml-js](https://github.com/nashwaan/xml-js) (instead of [xml2js](https://github.com/Leonidas-from-XIV/node-xml2js)) to convert XML>JSON and JSON>XML
    * (Android) handle existing `colors.xml`. 
    Resolves [#132](https://github.com/dpa99c/cordova-plugin-firebasex/issues/132).


# Version 6.1.0
* (iOS) Add `getAPNSToken()` plugin API method to get the APNS token on iOS. Derived from merging PR [#100](https://github.com/dpa99c/cordova-plugin-firebasex/pull/100).
* Merge PR [#103](https://github.com/dpa99c/cordova-plugin-firebasex/pull/103) - fix for app name containing an ampersand.
* Merge PR [#115](https://github.com/dpa99c/cordova-plugin-firebasex/pull/115) - fix for short attribute in app name.
* Merge PR [#121](https://github.com/dpa99c/cordova-plugin-firebasex/pull/121) - fixes missing resolution of promise in after_prepare hook which caused other plugins to not run their after_prepare script (a bug introduced in v6.0.7)
* (Android) Merge PR [#64](https://github.com/dpa99c/cordova-plugin-firebasex/pull/64) - replace Android hooks scripts to configure Gradle with actual Gradle configuration.
* (iOS) Add missing `tap` property for notification messages received while app is running in background.
	* Based on https://github.com/arnesson/cordova-plugin-firebase/pull/1104
	* Resolves [#96](https://github.com/dpa99c/cordova-plugin-firebasex/issues/96)
* (iOS) Fix issues causing foreground notifications not to display on first run. Fixes [#109](https://github.com/dpa99c/cordova-plugin-firebasex/issues/109).	
* (iOS) Update string format when subscribing/unsubscribing topics. Resolves [#110](https://github.com/dpa99c/cordova-plugin-firebasex/issues/110]).
* Support disabling of data collection (analytics/performance/crashlytics) at app startup and manual enabling of these at runtime.
    * Resolves [#116](https://github.com/dpa99c/cordova-plugin-firebasex/issues/116]) and [#79](https://github.com/dpa99c/cordova-plugin-firebasex/issues/79]).
* Remove Android implementation of `getBadgeNumber()`/`setBadgeNumber()` as it doesn't work on Android 8+.
  * Resolves [#124](https://github.com/dpa99c/cordova-plugin-firebasex/issues/124]).    

# Version 6.0.7
* Merge PR [#93](https://github.com/dpa99c/cordova-plugin-firebasex/pull/93): Update Fabric dependencies
* Port code to apply IOS_STRIP_DEBUG plugin variable to Podfile into this plugin's hook scripts (from cordova-plugin-cocoapod-supportx).
    * Fixes [#89](https://github.com/dpa99c/cordova-plugin-firebasex/issues/89).

# Version 6.0.6
* Fix parameter type passed to hasPermission success callback for Android. Fixes [#83](https://github.com/dpa99c/cordova-plugin-firebasex/issues/83).

# Version 6.0.5
* Fix `hasPermission()` to return boolean result on Android (same as iOS).
    * Update docs to flag this as a breaking change from `cordova-plugin-firebase`.
    * Resolves [#81](https://github.com/dpa99c/cordova-plugin-firebasex/issues/81).

# Version 6.0.4
* Replace dependency on `cordova-lib` with `xml2js`.
* (iOS) Restore placeholder GoogleService-Info.plist. 
    * Partially reverts a9c66746ca3592f0eec217f7701d5835f33b43c5
    * See [#74](https://github.com/dpa99c/cordova-plugin-firebasex/issues/74)
* (iOS) Handle and report native logical errors.

# Version 6.0.3
* (iOS) If grantPermission() is called when permission is already granted, return an error (rather than attempting to grant permission again which causes issues).
    * See [#61](https://github.com/dpa99c/cordova-plugin-firebasex/issues/61)
* (iOS) Run badge number operations on UI thread (instead of background thread).
    * Resolves [#72](https://github.com/dpa99c/cordova-plugin-firebasex/issues/72)
* (iOS) Handle situation where value of sound is not an NSString.    
    * See [#61](https://github.com/dpa99c/cordova-plugin-firebasex/issues/61)
* (iOS) Add try/catch handlers at all code entry points to handle unexpected exceptions in order to prevent app crashes. Log native exceptions to native and JS consoles.
    * See [#61](https://github.com/dpa99c/cordova-plugin-firebasex/issues/61)
* Remove `google-services.json` and `GoogleService-Info.plist` placeholders.
    * See [#63](https://github.com/dpa99c/cordova-plugin-firebasex/issues/63)


# Version 6.0.2
* (Android) Improved exception handling to prevent app crashes due to plugin exceptions.
Document caveats of received message payload when notification message is received while app is not running on Android.
Further resolves [#52](https://github.com/dpa99c/cordova-plugin-firebasex/issues/52).

# Version 6.0.1
* (Android) Expose notification message properties in message object sent to onMessageReceived().
Ensure message is always sent to onMessageReceived(), regardless if it was tapped.
Resolves [#52](https://github.com/dpa99c/cordova-plugin-firebasex/issues/52).


# Version 6.0.0
* *BREAKING CHANGES*
    * `onMessageReceived()` is now called when a message is received (data or notification) AND when a system notification is tapped (whether app is running or not)
    * Resolves [#48](https://github.com/dpa99c/cordova-plugin-firebasex/issues/48).
    * The `tap` parameter passed to `onMessageReceived()` is only set if a system notification is tapped
        * If the system notification was tapped while the app is running in the foreground, the value will be `tap: "foreground"`
        * If the system notification was tapped while the app is not running / in the background, the value will be `tap: "background"`     

# Version 5.0.0
* *BREAKING CHANGES*
    * `onNotificationOpen()` renamed to `onMessageReceived()`
    * Changed key names for custom notification properties in FCM data messages to display system notifications in foreground.
    * Message payload is always delivered to `onMessageReceived()` for both data and notification messages.
    * `messageType` key indicates type of FCM message: `notification` or `data`
    * `tap` is only set when `messageType` is `notification`
    * Explicit dependency on `cordova-plugin-androidx-adapter` since Android implementation uses AndroidX so is incompatible with Android Support Library.
    * Set `remote-notification` background mode in native Xcode project for iOS.
    * Reworked plugin documentation.
* Support customisable display of system notifications while app is in foreground for both notification and data messages (both Android & iOS).
* Set default color accent and notification channel for FCM notifications.
* Add support for default and custom notification channels for Android 8+
    * Customise importance, visibility, LED light, badge number, notification sound and vibration pattern 
* Calling `logError()` on Android now also logs to native logcat (as well as a non-fatal error to remote Crashlytics service).
* Fix `logError()` on iOS to log non-fatal error to remote Crashyltics service.
* Implement stubs for `hasPermission()` and `grantPermission()` on Android so they both return true in to the success callback.
* Rationalise permission check/request on iOS.
* Remove legacy support for iOS 9 and below.
* Support overridable default color accent for Android notification icons via `ANDROID_ICON_ACCENT` plugin variable.
    
# Version 4.0.0
* *BREAKING CHANGE:* set min supported versions to `cordova@9` and `cordova-ios@5`.
    * Drop dependency on cordova-plugin-cocoapodsx to install pod dependencies.
    * Instead  update plugin.xml to use podspec formatting as required by cordova-ios@5.
    * Remove iOS plugin variables as these are not (currently) supported by cordova-ios@5
    * Resolves [#22](https://github.com/dpa99c/cordova-plugin-firebasex/issues/22).

# Version 3.0.8
* \[iOS\] Add support for stripping debug symbols for libraries included via Cocoapods. Resolves [#28](https://github.com/dpa99c/cordova-plugin-firebasex/issues/28).

# Version 3.0.7
* \[iOS\] Ensure runpath search path contains `$(inherited)` to avoid build warnings/issues. Resolves [#25](https://github.com/dpa99c/cordova-plugin-firebasex/issues/25).

# Version 3.0.6
* Update iOS to Firebase SDK v6.3.0 (from v5.20.2) - major version increment so update source code for breaking changes to API. Resolves [#9](https://github.com/dpa99c/cordova-plugin-firebasex/issues/9).
* Add support for NDK crashlytics on Android. Resolves [#17](https://github.com/dpa99c/cordova-plugin-firebasex/issues/17).

# Version 3.0.5
* Bump min version of cordova-plugin-cocoapod-supportx to 1.7.2 which fixes bug when using a plugin variable to specify the `ios-min-version` in `<pods-config>`

# Version 3.0.4
* Bump min version of cordova-plugin-cocoapod-supportx to 1.7.1 which supports using a plugin variable to specify the `ios-min-version` in `<pods-config>`

# Version 3.0.3
* Implement didReceiveRegistrationToken delegate for iOS. Resolves [#16](https://github.com/dpa99c/cordova-plugin-firebasex/issues/16).
* Document dependency on Cocoapods. Resolves [#15](https://github.com/dpa99c/cordova-plugin-firebasex/issues/15).
* Make min iOS version configurable. Resolves [#14](https://github.com/dpa99c/cordova-plugin-firebasex/issues/14).


# Version 3.0.2
* Update legacy Xpath reference to `<application>` element in `AndroidManifest.xml`

# Version 3.0.1
* Bump default iOS Firebase SDK version to 5.20.2 (https://firebase.google.com/support/release-notes/ios#version_5202_-_april_10_2019). Resolves [#8](https://github.com/dpa99c/cordova-plugin-firebasex/issues/8).

# Version 3.0.0
* Reapply: Support user-overriding of default Android Gradle & iOS Cocoapods versions using plugin variables.

# Version 2.1.2
* Revert: Support user-overriding of default Android Gradle & iOS Cocoapods versions using plugin variables.
    * Since it's not working on iOS due to Cocoapods plugin dependency.
    * Need to fix that plugin to handle plugin variables then reinstate this change in a major version release.

# Version 2.1.1
* Support user-overriding of default Android Gradle & iOS Cocoapods versions using plugin variables.

# Version 2.1.0
* Update Android source to use AndroidX class names and adds dependency on [cordova-plugin-androidx](https://github.com/dpa99c/cordova-plugin-androidx) for forward compatibility with future versions of Firebase libraries on Android.
    * Note: if you include other plugins in your project which reference the legacy Android Support Library, you'll still need to include [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter) in your project to dynamically patch them.
* Pins Firebase and Crashlytics Gradle dependencies to latest major version (to prevent build failures due to unexpected changes in subsequent major versions).
* Set minimum supported versions to `cordova@8+`, `cordova-android@8+`, `cordova-ios@4+`.

# Version 2.0.7
* Merge [PR #7](https://github.com/dpa99c/cordova-plugin-firebasex/pull/7): use `<pod>` instead of deprecated `<<framework type="podspec">`. Resolves [#5](https://github.com/dpa99c/cordova-plugin-firebasex/issues/5).

# Version 2.0.6
* Use Cocoapods to satisfy iOS Firebase SDK (rather than bundling with plugin). See https://github.com/arnesson/cordova-plugin-firebase/pull/972.
* Add support for logMessage() and sendCrash() functions (ported from cordova-fabric-plugin)
* Bump version of Crashlytics library on Android to current latest (v2.9.8 - Dec 2018)
* Bump Firebase SDK versions in iOS PodSpecs to latest version (v5.15.0)
* Remove redundant build-extras.gradle
* Set minimum iOS version to 9.0 in podspec
* Remove unnecessary extra <config-file> block which can lead to race condition
* Fixes issues cause by Firebase SDK updates on 5 April 2019 (https://firebase.google.com/support/release-notes/android#update_-_april_05_2019) which removed deprecated API features causing Android build failures.
See https://github.com/arnesson/cordov 
* Fix compatibility with cordova@9 CLI
* Add explicit dependency on cordova-lib to prevent build error on iOS. Fixes #2.

---> **FORKED FROM `cordova-plugin-firebase` AS `cordova-plugin-firebasex`** <---

# Version 2.0.5

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/897">#897</a>: Fixed issue with after_prepare hook not copying required files

# Version 2.0.4

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/866">#866</a>: Fixed issue with loading .plist file on some iOS devices

# Version 2.0.3

### Features
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/874">#874</a>: Added new api `setCrashlyticsUserId` which allows setting Crashlytics user identifier
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/861">#861</a>: Updated `verifyPhoneNumber` api on android to add the following properties to the returned object:
   - `code` - sms code
   - `verified` - whether or not the verification was successful

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/869">#869</a>: Replace add/remove hooks with install/uninstall hooks to ensure proper configuration of the plugin
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/870">#870</a>: Add error handling to `fetch` api on iOS

# Version 2.0.2

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/837">#837</a>: Fixed android build

# Version 2.0.1

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/836">#836</a>: Fixed Crashlytics on iOS
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/830">#830</a>: Fixed initialization of firebase services

# Version 2.0.0

### Features
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/796">#796</a>: Update Firebase SDK Version to 5.x

### Bug Fixes
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/822">#822</a>: Can't use initFirebase() on 1.1.3 [Firebase isn't initialized]
- <a href="https://github.com/arnesson/cordova-plugin-firebase/issues/827">#827</a>: doc missing: initFirebase call needed before anything
- <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/824">#824</a>: Removed initRemoteConfig method

# Version 1.1.4 (deprecated)

This version has been deprecated due to complications with PR <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/784">#784</a>

# Version 1.1.3 (deprecated)

This version has been deprecated due to complications with PR <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/784">#784</a>

# Version 1.1.2 (deprecated)

This version has been deprecated due to complications with PR <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/784">#784</a>

# Version 1.1.1 (deprecated)

This version has been deprecated due to complications with PR <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/784">#784</a>

# Version 1.1.0 (deprecated)

This version has been deprecated due to complications with PR <a href="https://github.com/arnesson/cordova-plugin-firebase/pull/784">#784</a>

# Version 1.0.5

To force cordova to use this version, add the following to your project's config.xml:
```
<plugin name="cordova-plugin-firebase" spec="1.0.5" />
```
or by running:
```
cordova plugin add cordova-plugin-firebase@1.0.5 --save
```

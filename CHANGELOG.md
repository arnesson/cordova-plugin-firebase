# Version 15.0.0
* (Android) Update pinned Firebase SDK component versions to [BOM v31.1.0 - November 17, 2022](https://firebase.google.com/support/release-notes/android#2022-11-17)
* (iOS) Update pinned version of Firebase SDK to [v10.2.0 - November 15, 2022](https://firebase.google.com/support/release-notes/ios#version_1020_-_november_15_2022)
  - **BREAKING CHANGE**: Minimum supported iOS version is now v11.0 (with Firebase SDK v9 it was v10.0) - [see here](https://firebase.google.com/support/release-notes/ios#version_1000_-_october_10_2022)
  - Update pinned versions of Google Sign In and Google Tag Manager libraries to latest to align with Firebase SDK v10
* (iOS) fix: Fix CLI builds with Xcode 14 and Cordova CLI.
  * Resolves [#766](https://github.com/dpa99c/cordova-plugin-firebasex/issues/766)
* (iOS) feat: Add `IOS_GOOGLE_SIGNIN_VERSION` AND `IOS_GOOGLE_TAG_MANAGER_VERSION` plugin vars to enable overriding default pinned versions at plugin install time.
* (iOS) feat: Add the authorization code to the credential object returned after authentication via Sign in with Apple
  * Merged from PR [#761](https://github.com/dpa99c/cordova-plugin-firebasex/pull/761)
* (Android) fix: Notification opening app for Android 12
    * Resolves [#763](https://github.com/dpa99c/cordova-plugin-firebasex/issues/763), [#764](https://github.com/dpa99c/cordova-plugin-firebasex/issues/764)
    * Merged from PR [#765](https://github.com/dpa99c/cordova-plugin-firebasex/pull/765)
* (Android) feat: Add support for Android push notification localization in foreground notifications
    * Merged from PR [#772](https://github.com/dpa99c/cordova-plugin-firebasex/pull/772)
* (Android) feat: Handle checking/requesting POST_NOTIFICATIONS runtime permission on Android 13+.
    * Resolves [#777](https://github.com/dpa99c/cordova-plugin-firebasex/issues/777)

# Version 14.2.1
* (iOS) bugfix: remove openURL delegate that was erroneously re-added by merge error.
    * Re-implements PR [#731](https://github.com/dpa99c/cordova-plugin-firebasex/pull/731)
    * Resolves [#718](https://github.com/dpa99c/cordova-plugin-firebasex/issues/718)

# Version 14.2.0
* (Android) bugfix: Fix no notifications on Android 12 and above
    * Merged from PR [#747](https://github.com/dpa99c/cordova-plugin-firebasex/pull/747)
    * Resolves [#746](https://github.com/dpa99c/cordova-plugin-firebasex/issues/746)
* (iOS & Android) feat: Add support to optionally specify timestamp when updating documents in a Firestore collection
    * Merged from PR [#743](https://github.com/dpa99c/cordova-plugin-firebasex/pull/743)
* (iOS) bugfix: Use standard pod for Firestore by default but add `IOS_USE_PRECOMPILED_FIRESTORE_POD` plugin variable to switch to using pre-built version.
    * Resolves [#735](https://github.com/dpa99c/cordova-plugin-firebasex/issues/735)
* (iOS) feat: add support for `IOS_FIREBASE_SDK_VERSION` plugin variable to override the Firebase iOS SDK versions specified in `plugin.xml`

# Version 14.1.0
* (Doc) bugfix: Fix markdown issue caused by unescaped HTML tags.
    * Resolves [#707](https://github.com/dpa99c/cordova-plugin-firebasex/issues/707)
* (Android) bugfix: Fix null pointer exception when missing notification image
    * Merged from PR [#709](https://github.com/dpa99c/cordova-plugin-firebasex/pull/709)
* (iOS) bugfix: Cordova-compliant external URL handling
    * Merged from PR [#731](https://github.com/dpa99c/cordova-plugin-firebasex/pull/731)
* (iOS & Android) feat: Add support for getClaims
    * Merged from PR [#723](https://github.com/dpa99c/cordova-plugin-firebasex/pull/723)
* (Types) bugfix: Correctly declare FirebasePlugin as global
    * Resolves [#715](https://github.com/dpa99c/cordova-plugin-firebasex/issues/715)
    * Merged from PR [#716](https://github.com/dpa99c/cordova-plugin-firebasex/pull/716)
* (Android) chore: bump pinned Firebase SDK component versions to [BOM 30.0.2 (May 19, 2022)](https://firebase.google.com/support/release-notes/android#2022-05-19)
* (iOS) chore: Update Firebase Apple SDK to [Version 9.1.0 - May 24, 2022](https://firebase.google.com/support/release-notes/ios#version_910_-_may_24_2022)
    * Major version increase from v8.1.0 but no breaking changes directly affect this plugin
* (iOS) bugfix: Ensure new FCM token is issued after calling unregister() when autoinit is enabled.
    * Resolves [#732](https://github.com/dpa99c/cordova-plugin-firebasex/issues/732)
* (iOS & Android) feat: Add support for FIREBASE_FCM_AUTOINIT_ENABLED plugin variable to set FCM autoinit on app startup at configuration time


# Version 14.0.0
* (iOS) chore: Minor version update to Firebase iOS SDK to latest ([Version 8.11.0 - January 18, 2022](https://firebase.google.com/support/release-notes/ios#version_8110_-_january_18_2022))
    * BREAKING CHANGE: Requires Cocoapods v1.11.2+
* (Android) chore: Update pinned Firebase Android SDK dependencies to latest ((January 25, 2022)[https://developers.google.com/android/guides/releases#january_25_2022])
* (iOS) bugfix: Update to GoogleSignIn v6 and update plugin for breaking API changes.
    * Resolves [#678](https://github.com/dpa99c/cordova-plugin-firebasex/issues/678)
* (Android) bugfix: Fix an error getting the providerId that could cause `getCurrentUser()` to fail.
    * Merged from PR [#706](https://github.com/dpa99c/cordova-plugin-firebasex/pull/706)
* (iOS & Android) feat: Include actionCodeSettings in the `sendUserEmailVerification()` function
* (iOS) feat: Implement authorization request for critical alerts
    * Merged from PR [#693](https://github.com/dpa99c/cordova-plugin-firebasex/pull/693)
    * Resolves [#572](https://github.com/dpa99c/cordova-plugin-firebasex/issues/572)
* (Types) bugfix: Fix return type for `didCrashOnPreviousExecution`
    * Merged from PR [#692](https://github.com/dpa99c/cordova-plugin-firebasex/pull/692)
* (Android) bugfix: Use OAuthProvider when available during `linkUserWithCredential()`
    * Merged from PR [#687](https://github.com/dpa99c/cordova-plugin-firebasex/pull/687)
* (Types) bugfix: Add missing type for `authenticateUserWithEmailAndPassword()`
    * Merged from PR [#686](https://github.com/dpa99c/cordova-plugin-firebasex/pull/686)
* (iOS & Android) feat: Support Firebase Authentication emulator
    * Merged from PR [#685](https://github.com/dpa99c/cordova-plugin-firebasex/pull/685)
* (Android) feat: Support html attributes in body notifications
    * Merged from PR [#668](https://github.com/dpa99c/cordova-plugin-firebasex/pull/668)
* (Android) feat: Improved notification image support
    * Merged from PR [#667](https://github.com/dpa99c/cordova-plugin-firebasex/pull/667)
* (Doc) bugfix: Fix `setUserProperty` parameters in `README.md`
    * Merged from PR [#638](https://github.com/dpa99c/cordova-plugin-firebasex/pull/638)
* (Android) bugfix: Specify version of GRPC OKHTTP and enable version override via plugin variable and bump Android Gradle build tool versions.
    * Based on PR [#696](https://github.com/dpa99c/cordova-plugin-firebasex/pull/696)
    * Resolves [#695](https://github.com/dpa99c/cordova-plugin-firebasex/issues/695)
* (Android) bugfix: add `android:exported` element
    * Merged from PR [#702](https://github.com/dpa99c/cordova-plugin-firebasex/pull/702)
* (iOS) bugfix: Return user's full name if present in Apple sign in response.
    * Resolves [#479](https://github.com/dpa99c/cordova-plugin-firebasex/issues/479)

# Version 13.0.1
* (iOS) Fix `onTokenRefresh` to return FCM token (not installation auth token).
    * Resolves [#637](https://github.com/dpa99c/cordova-plugin-firebasex/issues/637)
* (Android): Increment pinned version of Crashlytics Gradle plugin to [v2.7.1](https://firebase.google.com/support/release-notes/android#crashlytics_gradle_plugin_v2-7-1) to resolve build issues with Gradle v7.
    * This resolves build issues with `cordova-android@10.0.0` which defaults to Gradle v7.1.1
    * Resolves [#643](https://github.com/dpa99c/cordova-plugin-firebasex/issues/643)
* (iOS) Bump pinned Firebase SDK components to [v8.4.0 - July 20, 2021](https://firebase.google.com/support/release-notes/ios#version_840_-_july_20_2021)
* (Android): Update pinned Firebase Android SDK versions from BoM v28.1.0 to ([v28.2.1 - July 09, 2021](https://firebase.google.com/support/release-notes/android#bom_v28-2-1))


# Version 13.0.0
* (iOS) BREAKING CHANGE: Major version update to Firebase iOS SDK from v7 to v8 ([Version 8.1.1 - June 11, 2021](https://firebase.google.com/support/release-notes/ios#version_811_-_june_11_2021))
    * Remove/replace references to previously-deprecated Firebase IID SDK component which is removed in SDK v8 with Firebase Installations SDK
* (Android) BREAKING CHANGE: Major version update to Firebase Android BOM from v26 to v28 ([v28.1.0 - June 03, 2021](https://firebase.google.com/support/release-notes/android#2021-06-03))
    * Remove/replace references to previously-deprecated Firebase IID SDK component which is removed in SDK BOM v28 with Firebase Installations SDK
    * Add explicit dependency on deprecated `firebase-iid` because latest version `firebase-functions:20.0.0` [depends on an older version](https://mvnrepository.com/artifact/com.google.firebase/firebase-functions/20.0.0) and so causes duplicate class conflicts with latest `firebase-messaging:22.0.0`
* (Android) doc: Add note regarding creating new notification channels for each new sound.
    * Relates to [#560](https://github.com/dpa99c/cordova-plugin-firebasex/issues/560).
* doc: Add note regarding allowed values for `logEvent`
    * Merged from PR [#619](https://github.com/dpa99c/cordova-plugin-firebasex/pull/619).
* (Android) bugfix: Fix sound configuration per channel
    * Merged from PR [#625](https://github.com/dpa99c/cordova-plugin-firebasex/pull/625).
* (iOS & Android) feature(auth): add idToken on signIn w/ Google response
    * Merged from PR [#633](https://github.com/dpa99c/cordova-plugin-firebasex/pull/633).
* (iOS) feature: support for `AppNotificationSettingsButton`
    * Merged from PR [#577](https://github.com/dpa99c/cordova-plugin-firebasex/pull/577).
* (iOS) bugfix: Check `content-available` key is present before casting it.
    * Resolves [#624](https://github.com/dpa99c/cordova-plugin-firebasex/issues/624)
* (iOS & Android) bugfix: Convert references to their path strings when fetching data from Firestore to avoid crashes due to circular references.
    * Resolves [#617](https://github.com/dpa99c/cordova-plugin-firebasex/issues/617)


# Version 12.1.0
* (iOS & Android) feature: Add support for Firebase Installations SDK.
    * Resolves [#603](https://github.com/dpa99c/cordova-plugin-firebasex/issues/603)
* (iOS) feature: Implement [Firebase Functions](https://firebase.google.com/docs/functions/callable)
    * Relates to PR [#509](https://github.com/dpa99c/cordova-plugin-firebasex/pull/509).

# Version 12.0.0
* (iOS) BREAKING CHANGE: Major version update to Firebase iOS SDK from v6 to v7 ([v7.8.1 - 12 March 2021](https://firebase.google.com/support/release-notes/ios#version_781_-_march_12_2021))
    * Requires `cocoapods@1.10` (previously `cocoapods@1.9`)
    * Removes `developerModeEnabled` property from `getInfo()` Remote Config response as this was removed in the latest Firebase SDK
    * Removes direct channel support for Firebase Messaging as no longer supported by Firebase iOS SDK v7.
    * Resolves [#561](https://github.com/dpa99c/cordova-plugin-firebasex/issues/561).
* (Android) BREAKING CHANGE: Major version update to Firebase Android BOM from v25 to v26 ([v26.7.0 - 11 March 2021](https://firebase.google.com/support/release-notes/android#bom_v26-7-0))
    * Removes `developerModeEnabled` property from `getInfo()` Remote Config response as this was removed in the latest Firebase SDK
* (iOS) Bugfix: Fix conflict with [cordova-plugin-local-notifications](https://github.com/katzer/cordova-plugin-local-notifications) to enable both remote notifications via this plugin and local notifications via that plugin to work simultaneously in the same app.
    * Merged from PR [#573](https://github.com/dpa99c/cordova-plugin-firebasex/pull/573).
    * Resolves [#230](https://github.com/dpa99c/cordova-plugin-firebasex/issues/230).
* (Android) Feature: add support for calling [Firebase Functions](https://firebase.google.com/docs/functions/callable)
    * Merged from PR [#509](https://github.com/dpa99c/cordova-plugin-firebasex/pull/509).
* (iOS) Bugfix: Add base class to `FirebasePluginMessageReceiverManager` to prevent Xcode build error
    * Merged from PR [#579](https://github.com/dpa99c/cordova-plugin-firebasex/pull/579).
* (Android) Bugfix: Fix GSON serialization of `NaN` values in Firestore
    * Merged from PR [#584](https://github.com/dpa99c/cordova-plugin-firebasex/pull/584).
* (Android) Bugfix: Fix serialization of JSON arrays and objects in `logEvent()` for Analytics
    * Merged from PR [#598](https://github.com/dpa99c/cordova-plugin-firebasex/pull/598).
* (iOS) Bugfix: Fix reading of all Remote Config keys in `getAll()` by falling back if default source is empty.
* (iOS) Bugfix: Register notification delegate during didFinishLaunching to ensure notifications are ready when app starts.
    * Resolves [#542](https://github.com/dpa99c/cordova-plugin-firebasex/issues/542).
* (iOS) Bugfix: Make interaction with firestoreListeners thread-safe.
    * Resolves [#574](https://github.com/dpa99c/cordova-plugin-firebasex/issues/574).
* (iOS) Bugfix: Ensure traces array is always defined before referencing it.
    * Resolves [#602](https://github.com/dpa99c/cordova-plugin-firebasex/issues/602).
* (iOS) Bugfix: Gracefully handle sending empty error message to logError.
    * Resolves [#555](https://github.com/dpa99c/cordova-plugin-firebasex/issues/555).
* (iOS) Bugfix: Gracefully handle errors in fetching token data when returning user info.
* (Android) Bugfix: Gracefully handle errors when attempting to retrieve ID token when fetching current user info.
    * Resolves [#566](https://github.com/dpa99c/cordova-plugin-firebasex/issues/566).


# Version 11.0.3
* (Android) Make Firebase Performance Monitoring Gradle plugin optional (disabled by default) via `ANDROID_FIREBASE_PERFORMANCE_MONITORING` plugin variable due to increased build times/memory usage when it's included.
* (Android) Add defensive code in `handleExceptionWithContext()` to prevent app crashes.
    * Resolves [#535](https://github.com/dpa99c/cordova-plugin-firebasex/issues/535).
* (iOS) Fix `setConfigSettings` implementation.
    * Merged from PR [#534](https://github.com/dpa99c/cordova-plugin-firebasex/pull/534).

# Version 11.0.2
* (iOS) Check if file contents for `pn-actions.json` exists before attempting to use it.
    * Resolves [#512](https://github.com/dpa99c/cordova-plugin-firebasex/issues/512).
    * Bug introduced by PR [#482](https://github.com/dpa99c/cordova-plugin-firebasex/pull/482).
* (Android) Add the Firebase Performance Monitoring Gradle plugin to monitor network traffic.
    * Resolves [#520](https://github.com/dpa99c/cordova-plugin-firebasex/issues/520).
* (Feature): Add setLanguageCode method for Firebase Auth
    * Merged from PR [#527](https://github.com/dpa99c/cordova-plugin-firebasex/pull/527).
* (iOS): Bump podspec versions for Firebase iOS SDK to v6.33.0.
    * Resolves [#530](https://github.com/dpa99c/cordova-plugin-firebasex/issues/530).
* (Android): Bump pinned Firebase SDK dependencies to latest release versions.
* (Types) Export interfaces in types definition.
    * Resolves [#529](https://github.com/dpa99c/cordova-plugin-firebasex/issues/529).

# Version 11.0.1
* (iOS) Set the Sign In with Apple capability based on the `IOS_ENABLE_APPLE_SIGNIN` plugin variable.
    * Resolves [#511](https://github.com/dpa99c/cordova-plugin-firebasex/issues/511).

# Version 11.0.0
* (Android & iOS): Bump pinned Firebase SDK component versions to latest releases.
* Added support for `didCrashOnPreviousExecution()` and `setCrashlyticsCustomKey()`
    * Merged from PR [#492](https://github.com/dpa99c/cordova-plugin-firebasex/pull/492).
* (Doc) Clarify requirements for parameters passed to `logEvent()`.
    * Resolves [#491](https://github.com/dpa99c/cordova-plugin-firebasex/issues/491).
* Implement Remote Config v2 API
    * Add new methods: `fetchAndActivate()`, `resetRemoteConfig()`, `getAll()`
    * *BREAKING CHANGE:* Change API signature and implementations for `setConfigSettings()` and `setDefaults()` on Android,
    and implement for iOS.
    * Resolves [#155](https://github.com/dpa99c/cordova-plugin-firebasex/issues/155).
* (Android) *BREAKING CHANGE:* Remove dependency on `cordova-plugin-androidx` and `cordova-plugin-androidx-adapter`
* Add support for Firestore real-time listeners: `listenToDocumentInFirestoreCollection()`, `listenToFirestoreCollection()`, `removeFirestoreListener()`
* (Types) Update typedef for recent API changes
* (iOS) Set Sign In with Apple entitlement automatically.
    * Resolves [#485](https://github.com/dpa99c/cordova-plugin-firebasex/issues/485).
* Add `authenticateUserWithEmailAndPassword()`
    * Resolves [#486](https://github.com/dpa99c/cordova-plugin-firebasex/issues/486).
* (iOS) Remove superfluous braces from `FirebasePluginMessageReceiver.h`
    * Resolves [#493](https://github.com/dpa99c/cordova-plugin-firebasex/issues/493).
* Support optional `valueType` parameter when filtering Firestore collections.
    * Resolves [#496](https://github.com/dpa99c/cordova-plugin-firebasex/issues/496).
* (iOS) Add support for foreground and destructive `UNNotificationActionOptions`
    * Cherrypicked from PR [#487](https://github.com/dpa99c/cordova-plugin-firebasex/pull/487)

# Version 10.2.0
* (iOS) Fix crashes on receiving push notifications on iOS due to delegate chaining.
    * Resolves [#385](https://github.com/dpa99c/cordova-plugin-firebasex/issues/385).
    * Reverts commit 4e9a0f4a1fd4ceb871af40629e1ddf146f287ca8 "co-existence with cordova-plugin-local-notification on iOS"
    * Since upon testing, this plugin does not work with `cordova-plugin-local-notification` present in the same project even with this code in place.
    * And the conflict between the 2 plugins will need to be addressed separately under [#230](https://github.com/dpa99c/cordova-plugin-firebasex/issues/230).
* (iOS) Add support for iOS actionable notifications
    * Merged from PR [#482](https://github.com/dpa99c/cordova-plugin-firebasex/pull/482).
* (Android): Handle task outcomes where task is not successful but exception is null.
    * Resolves [#473](https://github.com/dpa99c/cordova-plugin-firebasex/issues/473).
* (Android) Add missing Inapp Messaging component.
    * Resolves [#478](https://github.com/dpa99c/cordova-plugin-firebasex/issues/478).
* (iOS): Bump minimum required Cocoapods version to v1.9.1 due to requirement by Firestore v6.28.1
* (Android) (Bug fix) Fix all cases where task outcomes are being incorrectly handled.
* (iOS) Update remote config to use `activateWithCompletion` instead of deprecated `activateWithCompletionHandler` for activating remote config.
* (iOS) (Bug fix) Use regex to extract cocoapods from stdout when verifying cocoapods version during plugin install.
    * Resolves [#462](https://github.com/dpa99c/cordova-plugin-firebasex/issues/462).
* (Android, iOS): Support custom locations for Firebase config files
    * Merged from PR [#465](https://github.com/dpa99c/cordova-plugin-firebasex/pull/465).
    * Resolves [#452](https://github.com/dpa99c/cordova-plugin-firebasex/issues/452).

# Version 10.1.2
* (iOS): Bump Firebase SDK versions to v6.28.1 to resolve build freeze issue.
    * Resolves [#460](https://github.com/dpa99c/cordova-plugin-firebasex/issues/460).

# Version 10.1.1
* (iOS) Fix regression bug in `getToken()` introduced by [35a2a68e8db3808723c9f2fcb6aa176021f6c77a](https://github.com/dpa99c/cordova-plugin-firebasex/commit/35a2a68e8db3808723c9f2fcb6aa176021f6c77a).
    * Resolves [#456](https://github.com/dpa99c/cordova-plugin-firebasex/issues/456).
* (iOS) Update to use Firebase SDK v6.28.0
    * Resolves [#453](https://github.com/dpa99c/cordova-plugin-firebasex/issues/453).

# Version 10.1.0
* (iOS) Use precompiled pod for Firestore to reduce build times.
    * *BREAKING CHANGE:* Requires `cocoapods>=1.9` (previously `cocoapods>=1.8`).
    * Adds hook script to check local cocoapods version during plugin install.
    * Based on PR [#440](https://github.com/dpa99c/cordova-plugin-firebasex/pull/440).
    * Resolves [#407](https://github.com/dpa99c/cordova-plugin-firebasex/issues/407).
* (Android) Fixed regression bug related to default Crashlytics permission.
    * See [this comment](https://github.com/dpa99c/cordova-plugin-firebasex/issues/335#issuecomment-651218052).
* (iOS) Bump pinned Firebase SDK versions to latest 6.27.0
    * See [release notes](https://firebase.google.com/support/release-notes/ios#version_6270_-_june_16_2020)
* (Android): Bump Firebase SDK versions to latest for Analytics, Cloud Messaging & Inapp Messaging.

# Version 10.0.0
* *BREAKING CHANGE:* (Android, iOS) Migrate from Fabric Crashlytics SDK to Firebase Crashlytics SDK.
** Based on [this commit](https://github.com/vickydlion/cordova-plugin-firebasex/commit/0dfb5753edcd9fc19a0e7a52fdd4fc79d6d976ea) in [PR #432](https://github.com/dpa99c/cordova-plugin-firebasex/pull/432).
** Resolves [#335](https://github.com/dpa99c/cordova-plugin-firebasex/issues/335).
** Removes `isCrashlyticsCollectionCurrentlyEnabled()` as it's no longer necessary to manually init Crashlytics and a runtime method exists to enable/disable it.
** For more info see the [Firebase Crashlytics SDK upgrade documentation](https://firebase.google.com/docs/crashlytics/upgrade-sdk).
* (iOS) Fix exception raised if another plugin as already configured Firebase
    * Merged from PR [#419](https://github.com/dpa99c/cordova-plugin-firebasex/pull/419).
* (iOS) Handle case where LD_RUNPATH_SEARCH_PATHS is an array. Resolves [#344](https://github.com/dpa99c/cordova-plugin-firebasex/issues/344).
* (Android, iOS): Avoid collection state getting out of sync & remove restriction to override config defaults.
    * Merged from PR [#423](https://github.com/dpa99c/cordova-plugin-firebasex/pull/423).
* (iOS) Fix escaping already escaped json.
    * Merged from PR [#430](https://github.com/dpa99c/cordova-plugin-firebasex/pull/430).
    * Further resolves [#401](https://github.com/dpa99c/cordova-plugin-firebasex/issues/401).
* (Android): Fix parsing of existing `colors.xml` when it contains multiple existing `<color>` to prevent overwriting the existing values.
    * Resolves [#436](https://github.com/dpa99c/cordova-plugin-firebasex/issues/436).
* (Android, iOS): Return success/failure result when subscribing/unsubscribing from topics.
    * Resolves [#422](https://github.com/dpa99c/cordova-plugin-firebasex/issues/422).

# Version 9.1.2
* (Android) Fix retrieval of auth provider ID - [see here for more info](https://github.com/firebase/FirebaseUI-Android/issues/329#issuecomment-564409912)
* (iOS) Align retrieval of auth provider ID with Android.
* (Typing): correct return type of a method
    * Merged from PR [#390](https://github.com/dpa99c/cordova-plugin-firebasex/pull/390).
* (Documentation) Update guidance and requirements when opening issues
* (iOS): Fix escaping of line endings in multi-line log messages being sent from native iOS implementation to JS console.
    * Resolves [#401](https://github.com/dpa99c/cordova-plugin-firebasex/issues/401).
* (iOS): Set shouldEstablishDirectChannel via a  plugin variable which defaults to false.
    Resolves [#406](https://github.com/dpa99c/cordova-plugin-firebasex/issues/406).
* Bump androidx plugin version dependencies.
    Resolves [#418](https://github.com/dpa99c/cordova-plugin-firebasex/issues/418).

# Version 9.1.1
* (iOS): Bump Firebase SDK components to v6.23.0.
    * Relates to [#373](https://github.com/dpa99c/cordova-plugin-firebasex/issues/373).
    * See https://firebase.google.com/support/release-notes/ios#version_6230_-_april_21_2020.
* (Android) Bump Firebase SDK (and other Gradle dependencies) to latest versions.
    * See https://firebase.google.com/support/release-notes/android#2020-04-23

# Version 9.1.0
* (Android & iOS) *BREAKING CHANGE*: Add support for filters to `fetchDocumentInFirestoreCollection()`
    * *BREAKING CHANGE* to function signature.
    * Merged from PR [#367](https://github.com/dpa99c/cordova-plugin-firebasex/pull/367).

# Version 9.0.3
* (Android & iOS) Add `reloadCurrentUser()`
* (Doc) `createChannel()` suggestion for multiple sounds
    * Merged from PR [#225](https://github.com/dpa99c/cordova-plugin-firebasex/pull/225).
* (iOS) Implement `getInfo()` for iOS.
    * Merged from PR [#363](https://github.com/dpa99c/cordova-plugin-firebasex/pull/363).
* (Android & iOS) Add `signInUserWithCustomToken()` AND `signInUserAnonymously()` auth methods
    * Merged from PR [#359](https://github.com/dpa99c/cordova-plugin-firebasex/pull/359).

# Version 9.0.2
* (Android): Don't display app icon for large notification icon on Android. Resolves [#343](https://github.com/dpa99c/cordova-plugin-firebasex/issues/343).
* (Android & iOS) Sign out of Google signing out of Firebase. Resolves [#353](https://github.com/dpa99c/cordova-plugin-firebasex/issues/353).
* (Android & iOS) Add `documentExistsInFirestoreCollection()` and fix resolution of `fetchDocumentInFirestoreCollection()`.

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

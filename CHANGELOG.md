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

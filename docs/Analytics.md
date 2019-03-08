# Google Analytics for Firebase
Official link https://firebase.google.com/docs/analytics/


## logEvent

Log an event
```
window.FirebasePlugin.logEvent("select_content", {content_type: "page_view", item_id: "home"});
```

## setScreenName

Set the name of the current screen:
```
window.FirebasePlugin.setScreenName("Home");
```

## setUserId

Set a user id for use:
```
window.FirebasePlugin.setUserId("user_id");
```

## setUserProperty

Set a user property for use:
```
window.FirebasePlugin.setUserProperty("name", "value");
```

## setAnalyticsCollectionEnabled

Enable/disable analytics collection.

```
window.FirebasePlugin.setAnalyticsCollectionEnabled(true/false); // Enables or disabled analytics collection
```

<br>
# Disable Analytics Collection
### Permanently deactivate collection
For more information read the documentation https://firebase.google.com/support/guides/disable-analytics

#### Android
If you need to deactivate Analytics collection permanently in a version of your app, set *firebase_analytics_collection_deactivated* to true in your app's AndroidManifest.xml in the application tag. For example:

```xml
<meta-data android:name="firebase_analytics_collection_deactivated" android:value="true" />
```

#### iOS
If you need to deactivate Analytics collection permanently in a version of your app, set *FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED* to YES in your app's Info.plist file. Setting *FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED* to YES takes priority over any values for FIREBASE_ANALYTICS_COLLECTION_ENABLED in your app's Info.plist as well as any values set with setAnalyticsCollectionEnabled.

To re-enable collection, remove *FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED* from your Info.plist. Setting *FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED* to NO has no effect and results in the same behavior as not having *FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED* set in your Info.plist file.

<br>
### Disable Advertising ID collection
#### Android
If you wish to disable collection of the Advertising ID in your Android app, you can set the value of *google_analytics_adid_collection_enabled* to false in your app's AndroidManifest.xml in the application tag. For example:

```xml
<meta-data android:name="google_analytics_adid_collection_enabled" android:value="false" />
```

### iOS
This feature does not exist.


<br>
# Debugging Events
For more information read the documentation https://firebase.google.com/docs/analytics/debugview

### Android
For Android, enable or disable debugging using the adb command

Enabled
```
adb shell setprop debug.firebase.analytics.app <package_name>
```

Disabled
```
adb shell setprop debug.firebase.analytics.app .none.
```

### iOS
To enable Analytics Debug mode on your development device, specify the following command line argument in Xcode:

1. In Xcode, select Product > Scheme > Edit scheme...
2. Select Run from the left menu.
3. Select the Arguments tab.
4. In the Arguments Passed On Launch section, add -FIRAnalyticsDebugEnabled.

Enabled
```
-FIRDebugEnabled
```

Disabled
```
-FIRDebugDisabled
```
You can also set this parameter using the Swift code, by inserting these lines in the *AppDelegate* file within the *didFinishLaunchingWithOptions* method.

```swift
var newArguments = ProcessInfo.processInfo.arguments
newArguments.append("-FIRDebugEnabled")
ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
```

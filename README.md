# cordova-plugin-firebase
This repository is a fork of [https://github.com/arnesson/cordova-plugin-firebase](https://github.com/arnesson/cordova-plugin-firebase)

The following changes have been done:
- Allow reception of notification title & body on Android inside the javascript callback (foreground only)

    Title & body are pushed inside the data as:

    ```
    data.title
    data.body
    ```

- Avoid wrong callback of notification upon application boot or resume (Fix since OnNotificationOpenReceiver does not seems to be called)
- Added `tap=true` when notification is tapped (Fix since OnNotificationOpenReceiver does not seems to be called) (Resuming case and cold start)
- Included this [PR](https://github.com/arnesson/cordova-plugin-firebase/pull/175) in order to have `hasPermission` method working on Android



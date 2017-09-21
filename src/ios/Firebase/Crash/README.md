# Firebase Crash Reporting

Firebase Crash Reporting is a free mobile crash analytics service.  It provides
detailed analytics and diagnostic information about the crashes encountered
by your users.  For more information about crash reporting and many other
cool mobile services, check out [Firebase] (https://firebase.google.com).

## Getting Started with Cocoapods

1.  Follow the instructions for
    [setting up Firebase](https://developers.google.com/firebase/docs/ios/)
2.  Add the following to your Podfile

    ```
    pod 'Firebase/Crash'
    ```

3.  Set up automatic symbol file uploads.  Symbol files are required to
    turn your stack traces into pretty classes and selectors.  In
    Xcode, click on your project file, choose your application target,
    select "Build Phases", hit the little + sign to add a phase,
    then select "Run Script".  Fill the resulting build step with:

    ```
    "${PODS_ROOT}"/FirebaseCrash/upload-sym
    ```

## Testing Integration

In order to try out integration, you need to force a crash
**while not attached to the debugger**.  The debugger will
intercept all crashes, preventing Firebase Crash Reporting from
gathering any useful information.

1.  Add a crash somewhere in your app.  This will do the trick:

    ```
    abort();
    ```

2.  Run your app to get the latest code installed on the test
    device, then once the app has launched, hit stop.

3.  Relaunch your app directly from the test device and trigger the crash.

4.  Restart your app (either in the debugger or not) and the crash will be
    uploaded.  Wait at least 10 seconds.  Firebase Crash Reporting delays
    crash uploading at startup to avoid creating contention with your own code.

5.  Your crash should show up in Firebase within 20 minutes.

More information can be found in the
[Firebase documentation](https://developers.google.com/firebase/).
Happy bug hunting!

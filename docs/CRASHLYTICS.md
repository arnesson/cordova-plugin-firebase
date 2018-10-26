# Crashlytics

First of all, you need to have configuration files in place i.e. `GoogleService-Info.plist` for iOS and `google-services.json` for android.

### Android
There is no extra configuration required for Android.

### iOS
For iOS, the plugin depends upon [CocoaPods](https://cocoapods.org/).

You have to add the Crashlytics SDK to your Project either usign CocoaPods or by adding the files manually.
See the setup instructions [here](https://firebase.google.com/docs/crashlytics/get-started).

In a nutshell, navigate to `platforms/ios` folder, and then you can do:
```bash
sudo gem install cocoapods  # installs CocoaPods
pod repo update
pod setup
```

Then you can add these lines in your `PodFile`:
```bash

use_frameworks!  # comment if you're not using Swift and don't want to use dynamic frameworks

pod 'Fabric', '~> 1.7.11'
pod 'Crashlytics', '~> 3.10.7'
```

Then you can do:
```bash
pod repo update
pod install # installs the dependencies
```

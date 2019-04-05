# Notifications

Read below for details on configuring notification [icons](#changing-notification-icon) and [colors](#notification-colors).

## Changing Notification Icon
By default Firebase will use the app icon as the notification icon.  The icon is treated as a silhouette, so if the app icon has a background, it might appear as a large blob.  To change the icon, you need to [add the icons](#add-the-icons) to the project and [configure firebase](#configure-firebase).

### Add the icons
Add your icons to your project in your res directory, such as `<projectroot>/res/native/android/res/<drawable-DPI>`.  Make sure the icons all have the same name (example has ic_silhouette).  Next, we will need to copy the icons over to the Android project when it is created.  To do this, add the following lines to your `config.xml`.
```
<platform name="android">
....
    <resource-file src="res/native/android/res/drawable-hdpi/ic_silhouette.png" target="app/src/main/res/drawable-hdpi/ic_silhouette.png"/>
    <resource-file src="res/native/android/res/drawable-xhdpi/ic_silhouette.png" target="app/src/main/res/drawable-hdpi/ic_silhouette.png"/>
    ... Repeated for each screen resolution you have a notification icons for...
</platform>
```
Note: the src of the files is not important, but the target directory with the proper dpi filter is very imporant.  You will also need to name all the icons the same name.

### Configure Firebase
We need to copy a metadata flag into the Manifest to tell Firebase which icon to use.  To do this, add the following line to your `config.xml`.
```
<platform name="android">
....
    <config-file parent="/manifest/application" target="AndroidManifest.xml">
        <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/ic_silhouette" />
    </config-file>
</platform>
```
Note: If you have XML Namespace issues, which I encountered when trying to build in Android Studio, add this `xmlns:android="http://schemas.android.com/apk/res/android"` to the widget element at the root of the `config.xml`.

## Notification Colors

To add color to the custom icon, you will need to [create a color definition](#create-a-color-definition) and [configure firebase color](#configure-firebase-color).

### Create a Color Definition
On Android Lollipop and above you can also set the accent color for the notification by adding a color setting.

`<projectroot>/res/native/android/res/values/colors.xml`
```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#FFFFFF00</color>
    <color name="primary_dark">#FF220022</color>
    <color name="accent">#FF00FFFF</color>
</resources>
```

You will again need to copy this file over to your project to get it to work by adding these lines to your `config.xml`
```
<platform name="android">
...
    <resource-file src="res/native/android/res/values/colors.xml" target="app/src/main/res/values/colors.xml"/>
</platform>
```

### Configure Firebase Color
We need to copy a metadata flag into the Manifest to tell Firebase which color to use for the icon.  To do this, add the following line to your `config.xml`.
```
<platform name="android">
....
    <config-file parent="/manifest/application" target="AndroidManifest.xml">
        <meta-data android:name="com.google.firebase.messaging.default_notification_color" android:resource="@color/primary" />
    </config-file>
</platform>
```
Note: If you have XML Namespace issues, which I encountered when trying to build in Android Studio, add this `xmlns:android="http://schemas.android.com/apk/res/android"` to the widget element at the root of the `config.xml`.

# Final Result

If you added a custom icon and color, your `config.xml` should include something like this.

```
<widget .... xmlns:android="http://schemas.android.com/apk/res/android">
...
    <platform name="android">
        <!-- Copy the color definition -->
        <resource-file src="res/native/android/res/values/colors.xml" target="app/src/main/res/values/colors.xml"/>
        <!-- Copy the icons -->
        <resource-file src="res/native/android/res/drawable-hdpi/ic_silhouette.png" target="app/src/main/res/drawable-hdpi/ic_silhouette.png"/>
        <resource-file src="res/native/android/res/drawable-xhdpi/ic_silhouette.png" target="app/src/main/res/drawable-xhdpi/ic_silhouette.png"/>
        <resource-file src="res/native/android/res/drawable-xxhdpi/ic_silhouette.png" target="app/src/main/res/drawable-xxhdpi/ic_silhouette.png"/>
        <resource-file src="res/native/android/res/drawable-xxxhdpi/ic_silhouette.png" target="app/src/main/res/drawable-xxxhdpi/ic_silhouette.png"/>

        <!-- Configure Firebase -->
        <config-file parent="/manifest/application" target="AndroidManifest.xml">
            <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/ic_silhouette" />
            <meta-data android:name="com.google.firebase.messaging.default_notification_color" android:resource="@color/primary" />
        </config-file>
    </platform>
</widget>
```

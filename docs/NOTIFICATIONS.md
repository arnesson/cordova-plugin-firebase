# Notifications

Read below for details on configuring notification [icons](#changing-notification-icon) and [colors](#notification-colors).

## Changing Notification Icon
The plugin will use notification_icon from drawable resources if it exists, otherwise the default app icon is used.
To set a big icon and small icon for notifications, define them through drawable nodes.  
Create the required `styles.xml` files and add the icons to the  
`<projectroot>/res/native/android/res/<drawable-DPI>` folders.  

The example below uses a png named `ic_silhouette.png`, the app Icon (@mipmap/icon) and sets a base theme.  
From android version 21 (Lollipop) notifications were changed, needing a separate setting.  
If you only target Lollipop and above, you don't need to setup both.  
Thankfully using the version dependant asset selections, we can make one build/apk supporting all target platforms.  
`<projectroot>/res/native/android/res/values/styles.xml`
```
<?xml version="1.0" encoding="utf-8" ?>
<resources>
    <!-- inherit from the holo theme -->
    <style name="AppTheme" parent="android:Theme.Light">
        <item name="android:windowDisablePreview">true</item>
    </style>
    <drawable name="notification_big">@mipmap/icon</drawable>
    <drawable name="notification_icon">@mipmap/icon</drawable>
</resources>
```
and  
`<projectroot>/res/native/android/res/values-v21/styles.xml`
```
<?xml version="1.0" encoding="utf-8" ?>
<resources>
    <!-- inherit from the material theme -->
    <style name="AppTheme" parent="android:Theme.Material">
        <item name="android:windowDisablePreview">true</item>
    </style>
    <drawable name="notification_big">@mipmap/icon</drawable>
    <drawable name="notification_icon">@drawable/ic_silhouette</drawable>
</resources>
```

## Notification Colors

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

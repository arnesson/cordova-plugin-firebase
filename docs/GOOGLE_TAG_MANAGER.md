# Google Tag Manager
Download your container-config json file from Tag Manager and add a resource-file node in your `config.xml`.

## Android
```
<platform name="android">
    <resource-file src="GTM-XXXXXXX.json" target="app/src/main/assets/containers/GTM-XXXXXXX.json" />
    ...
```

## iOS
```
<platform name="ios">
    <resource-file src="GTM-YYYYYYY.json" />
    ...
```

# Debug

## Android 

### Firebase

`adb shell setprop log.tag.FA VERBOSE`
`adb shell setprop log.tag.FA-SVC VERBOSE`
`adb logcat -v time -s FA FA-SVC`

### Firebase and GoogleTagManager

`adb shell setprop log.tag.FA VERBOSE`
`adb shell setprop log.tag.FA-SVC VERBOSE`
`adb shell setprop log.tag.GoogleTagManager VERBOSE`
`adb logcat -v time -s FA FA-SVC GoogleTagManager`

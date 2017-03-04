# cordova-plugin-firebase
This repository is a fork of [https://github.com/arnesson/cordova-plugin-firebase]

A single change has been done:
- Allow reception of notification title & body on Android inside the javascript callback (foreground only)

Title & body are pushed inside the data as:

```
data.title
data.body
```



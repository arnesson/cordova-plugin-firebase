# Firebase Cloud Messaging
Official link https://firebase.google.com/docs/cloud-messaging

## getToken

Get the device token (id):
```js
window.FirebasePlugin.getToken(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```
Note that token will be null if it has not been established yet

## onTokenRefresh

Register for token changes:
```js
window.FirebasePlugin.onTokenRefresh(function(token) {
    // save this server-side and use it to push notifications to this device
    console.log(token);
}, function(error) {
    console.error(error);
});
```
This is the best way to get a valid token for the device as soon as the token is established

## onNotificationOpen

Register notification callback:

```js
window.FirebasePlugin.onNotificationOpen(function(notification) {
    console.log(notification);
}, function(error) {
    console.error(error);
});
```
Notification flow:

1. App is in foreground:
    1. User receives the notification data in the JavaScript callback without any notification on the device itself (this is the normal behaviour of push notifications, it is up to you, the developer, to notify the user)
2. App is in background:
    1. User receives the notification message in its device notification bar
    2. User taps the notification and the app opens
    3. User receives the notification data in the JavaScript callback

Notification icon on Android:

[Changing notification icon](NOTIFICATIONS.md#changing-notification-icon)

## grantPermission (iOS only)

Grant permission to receive push notifications (will trigger prompt):

```js
window.FirebasePlugin.grantPermission();
```
## hasPermission

Check permission to receive push notifications:

```js
window.FirebasePlugin.hasPermission(function(data){
    console.log(data.isEnabled);
});
```

## setBadgeNumber

Set a number on the icon badge:

```js
window.FirebasePlugin.setBadgeNumber(3);
```

Set 0 to clear the badge

```js
window.FirebasePlugin.setBadgeNumber(0);
```

## getBadgeNumber

Get icon badge number:

```js
window.FirebasePlugin.getBadgeNumber(function(n) {
    console.log(n);
});
```

## clearAllNotifications

Clear all pending notifications from the drawer:

```js
window.FirebasePlugin.clearAllNotifications();
```

## subscribe

Subscribe to a topic:

```js
window.FirebasePlugin.subscribe("example");
```

## unsubscribe

Unsubscribe from a topic:

```js
window.FirebasePlugin.unsubscribe("example");
```

## unregister

Unregister from firebase, used to stop receiving push notifications. Call this when you logout user from your app. :

```js
window.FirebasePlugin.unregister();
```

# Message types
Firebase allows to use two types of message: notification messages and data messages.

## Notification message
### Behaviour
* if the app is closed or in background, displays a notification in the notification tray of the user's device, when the notification is touched, `onNotificationOpen` is called
* if the app is in foreground, calls immediately `onNotificationOpen`
### The tap attribute
To know how the `onNotificationOpen` was called it is possible to check the `tap` attribute, like this:
```
window.FirebasePlugin.onNotificationOpen(
  function(notification) {
    if(notification.tap) {
      console.log("Notification touched by the user");
    }
    else {
      console.log("Notification received while in foreground");
    }
  }, 
function(error) {
    console.error(error);
});
```
### FCM API Call from server via HTTP(s)
Send request to:
```
https://fcm.googleapis.com/fcm/send
```
HTTP Method:
```
POST
```
Additional headers:
```
Content-Type: application/json
Authorization:key=<Your FCM Server API key>
```
The request body:
```
{
    "registration_ids" : ["<Your client FCM token>"],
    "notification" : {
        "title":"<Your notification title>",
        "body":"<Your notification body>"
    }
}
```
Or, the request body if you want to add some custom data payload:
```
{
    "registration_ids" : ["<Your client FCM token>"],
    "notification" : {
        "title":"<Your notification title>",
        "body":"<Your notification body>"
    }
    "data" : {
        "<customKey1>":"<customData1>",
        "<customKey2>":"<customData2>"
    }
}
```
## Data message
### Behaviour
* if the app is closed or in background, the message is enqueued, the queue will be read when the app will be opened, and `onNotificationOpen` will be called (with `notification.tap`=`false`)
* if the app is in foreground, calls immidiately `onNotificationOpen` (with `notification.tap`=`false`)

### FCM API Call from server via HTTP(s)
Send request to:
```
https://fcm.googleapis.com/fcm/send
```
HTTP Method:
```
POST
```
Additional headers:
```
Content-Type: application/json
Authorization:key=<Your FCM Server API key>
```
The request body, just omit the `notification` section of the body:
```
{
    "registration_ids" : ["<Your client FCM token>"],
    "data" : {
        "<customKey1>":"<customData1>",
        "<customKey2>":"<customData2>"
    }
}
```
## How to read the custom data from your app
Supposing you have, in your `data` section `"<customKey1>":"<customData1>"`, to read the `customKey1` value from your app, you can just check the attribute `notification.customKey1`, like this:
```
window.FirebasePlugin.onNotificationOpen(
  function(notification) {
    console.log(notification.customKey1);
  }, 
function(error) {
    console.error(error);
});
```

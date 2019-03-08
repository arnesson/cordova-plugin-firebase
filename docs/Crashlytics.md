# Firebase Crashlytics
Official link https://firebase.google.com/docs/crashlytics/

## sendCrash
This method triggers an application crash.

```js
window.FirebasePlugin.sendCrash();
```
It is used once to tell Firebase that Crashlitycs is configured. Its use is not recommended as it is not a true information in the Firebase panel. In fact it will appear as an error in the plugin line.


## logMessage
Log an error message into plugin file.
```js
window.FirebasePlugin.logMessage("Error message", success, error);
```

## logError
In iOS log a message and it is an alias of logMessage. Android records an exception, but will always be displayed in the plugin's file line.

```js
window.FirebasePlugin.logError("Error message", success, error);
```

## sendNonFatalCrash(message, stack, domain, success, error)

- message: Typeof string and represent the error message
- stack: Type Array and represents the lines of the error stack. To get this information use this JavaScript library: [StackTraceJS](https://www.stacktracejs.com)
- domain: Typeof string and represent the domain of error. Ex. "javascript"

Here under a use case:

```javascript
window.addEventListener('error', (error)=>{

	if ( window.FirebasePlugin && window.FirebasePlugin.sendNonFatalCrash ){
		StackTrace.fromError(error).then((stack)=>{
			console.log(error.message, stack);
			window.FirebasePlugin.sendNonFatalCrash(error.message, stack, 'javascript');
		});

	}

});
```

In this case, the panel displays the javascript stack supplied as input from the library.

##### Note for iOS
If you do not use a local webserver, the error received is: `"Script Error." on line 0`, when the error occurs in a script that's hosted on a domain other than the domain of the current page.
To bypass this block disable the local file restrictions of WKWebview. Reference: https://bugs.webkit.org/show_bug.cgi?id=154916

```xml
<preference name="FirebasePluginAllowFileAccess" value="true" />
```


## setCrashlyticsUserId
If set, it associates an error with a given user.

```js
window.FirebasePlugin.setCrashlyticsUserId("userId", success, error);
```

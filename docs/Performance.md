# Firebase Performance Monitoring
Official link https://firebase.google.com/docs/perf-mon/

## startTrace

Start a trace.

```js
window.FirebasePlugin.startTrace("test trace", success, error);
```

## incrementMetric

To count the performance-related events that occur in your app (such as cache hits or retries), add a line of code similar to the following whenever the event occurs, using a string other than retry to name that event if you are counting a different type of event:

```js
window.FirebasePlugin.incrementCounter("test trace", "retry", 1, success, error);
```

## stopTrace

Stop the trace

```js
window.FirebasePlugin.stopTrace("test trace");
```

## startTraceHTTP(url, method, payloadSize, success, error )
Call this method before sending an ajax request. The success callback will return the identification key that will serve to run the stopTraceHttp.

- url: String, Http url of api.
- method: String, the name of method (ex. GET).
- payloadSize: Integer, the size of payload.

```js
var httpTraces = {};
window.FirebasePlugin.startTraceHTTP("https://api.mydomain.com/nations", "GET", 0, function(traceId)=>{
	httpTraces["GET+https://api.mydomain.com/nations"] = traceId;
});
```

## stopTraceHTTP(traceId, statusCode, contentType, payloadSize, success, error)

Stop the trace HTTP with information:

- traceId: String, it is used to obtain tracking.
- statusCode: Integer, the status code return of http.
- contentType: String, content type returned of http.
- payloadSize: Integer, the size of response

```js
window.FirebasePlugin.stopTraceHTTP(httpTraces["GET+https://api.mydomain.com/nations"], 200, "application/json", 2000);
```

##### Example of use:

```js

var callbackAjaxSuccessAndError = function callbackAjaxSuccessAndError(event, jqXHR, options, data){
	var ct          = (jqXHR.getResponseHeader("content-type") || '' ).split(';');
	var url         = options.url;
	var statusCode  = jqXHR.status;
	var contentType = ct[0];
	var traceId     = options.traceId;
	var payloadSize = (JSON.stringify(data)).length;

	window.FirebasePlugin.stopTraceHTTP(traceId, statusCode, contentType, payloadSize);
};

$(document).ajaxSend(function(event, jqXHR, options){

	var url         = options.url;
	var method      = options.type;
	var data        = JSON.stringify(options.data);
	var payloadSize = data.length;

	window.FirebasePlugin.startTraceHTTP(url, method, payloadSize, function(traceId){
		// Save the traceId on object options. This object will be passed to the call completion event.
		options.traceId = traceId
	});

});

$(document).ajaxSuccess(callbackAjaxSuccessAndError);
$(document).ajaxError(callbackAjaxSuccessAndError);

$.ajax({
	url: 'https://api.mydomain.com/nations',
	type: 'GET',
	success: function(){...},
	error: function(){...}
});

```

## isPerformanceEnabled
Check if Firebase Performance Collection is enabled.

```js
window.FirebasePlugin.isPerformanceEnabled(function(enabled){
	console.log("Performace is %s", enabled ? "enabled" : "disabled" )
}, error);
```

## enabeldPerformance
Enabled Firebase Performance Collection.

```js
window.FirebasePlugin.enabeldPerformance(success);
```

## setPerformanceCollectionEnabled
Enabled Firebase Performance Collection.

```js
window.FirebasePlugin.setPerformanceCollectionEnabled(true, success, error);
```

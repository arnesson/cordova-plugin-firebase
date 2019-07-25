package org.apache.cordova.firebase;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Exception class to log Javascript based exceptions with stacktrace.
 *
 * @author https://github.com/distinctdan
 */
public class JavaScriptException extends Exception {

    public JavaScriptException(String message) {
        super(message);
    }

    public JavaScriptException(String message, JSONArray stackTrace) throws JSONException {
        super(message);
        this.handleStacktrace(stackTrace);
    }

    private void handleStacktrace(JSONArray stackTrace) throws JSONException {
        if (stackTrace == null) {
            return;
        }

        StackTraceElement[] trace = new StackTraceElement[stackTrace.length()];

        for (int i = 0; i < stackTrace.length(); i++) {
            JSONObject elem = stackTrace.getJSONObject(i);
            trace[i] = new StackTraceElement(
                    "undefined",
                    elem.optString("functionName", "undefined"),
                    elem.optString("fileName", "undefined"),
                    elem.optInt("lineNumber", -1)
            );
        }

        this.setStackTrace(trace);
    }
}

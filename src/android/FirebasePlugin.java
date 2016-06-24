package org.apache.cordova.firebase;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;


public class FirebasePlugin extends CordovaPlugin {
    private FirebaseAnalytics mFirebaseAnalytics;
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getRegistrationId")) {
            this.getRegistrationId(callbackContext);
            return true;
        } else if (action.equals("startAnalytics")) {
            this.startTracker(callbackContext);
            return true;
        }
        return false;
    }

    private void getRegistrationId(CallbackContext callbackContext) {
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        callbackContext.success(refreshedToken);
    }
    
    private void startTracker(CallbackContext callbackContext) {
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
        if (mFirebaseAnalytics) {
            callbackContext.success("tracker started");
        } else {
            callbackContext.error("tracker not started");
        }
    }
}

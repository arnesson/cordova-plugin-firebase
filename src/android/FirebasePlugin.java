package org.apache.cordova.firebase;

import android.util.Log;
import android.content.Context;
import android.os.Bundle;

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
            this.startAnalytics(callbackContext);
            return true;
        } else if (action.equals("logEvent")) {
            this.logEvent(callbackContext, args.getString(0), args.getString(1));
            return true;
        } 
        return false;
    }

    private void getRegistrationId(CallbackContext callbackContext) {
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        callbackContext.success(refreshedToken);
    }
    
    private void startAnalytics(CallbackContext callbackContext) {
        Context context=this.cordova.getActivity().getApplicationContext(); 
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
        callbackContext.success("tracker started");
    }

    private void logEvent(CallbackContext callbackContext, String key, String value) {
        Bundle params = new Bundle();
        params.putString(key, value);
        mFirebaseAnalytics.logEvent(key, params);
        callbackContext.success("event logged");
        Log.d("FirebaseAnalytics", "Event logged");
    }
}

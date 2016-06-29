package org.apache.cordova.firebase.FirebasePlugin;

import android.content.Context;
import android.util.Log;
import android.os.Bundle;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.messaging.FirebaseMessaging;


public class FirebasePlugin extends CordovaPlugin {

    private FirebaseAnalytics mFirebaseAnalytics;
    private final String TAG = "FirebasePlugin";

    @Override
    protected void pluginInitialize() {
        final Context context = this.cordova.getActivity().getApplicationContext();
        this.cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Log.d(TAG, "Starting Firebase plugin");
                mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
                FirebaseMessaging.getInstance().subscribeToTopic("android");
                FirebaseMessaging.getInstance().subscribeToTopic("all");
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getInstanceId")) {
            this.getInstanceId(callbackContext);
            return true;
        } else if (action.equals("subscribe")) {
            this.subscribe(callbackContext, args.getString(0));
            return true;
        } else if (action.equals("unsubscribe")) {
            this.unsubscribe(callbackContext, args.getString(0));
            return true;
        } else if (action.equals("logEvent")) {
            this.logEvent(callbackContext, args.getString(0), args.getString(1));
            return true;
        }
        return false;
    }

    private void getInstanceId(CallbackContext callbackContext) {
        String token = FirebaseInstanceId.getInstance().getToken();
        callbackContext.success(token);
    }

    private void subscribe(CallbackContext callbackContext, String topic) {
        FirebaseMessaging.getInstance().subscribeToTopic(topic);
        callbackContext.success();
    }

    private void unsubscribe(CallbackContext callbackContext, String topic) {
        FirebaseMessaging.getInstance().unsubscribeFromTopic(topic);
        callbackContext.success();
    }

    private void logEvent(CallbackContext callbackContext, String key, String value) {
        Bundle params = new Bundle();
        params.putString(key, value);
        mFirebaseAnalytics.logEvent(key, params);
        callbackContext.success();
    }
}

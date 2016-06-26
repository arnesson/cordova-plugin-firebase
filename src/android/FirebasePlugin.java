package org.apache.cordova.firebase;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;


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
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getRegistrationId")) {
            this.getRegistrationId(callbackContext);
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

    private void logEvent(CallbackContext callbackContext, String key, String value) {
        Bundle params = new Bundle();
        params.putString(key, value);
        mFirebaseAnalytics.logEvent(key, params);
        callbackContext.success();
    }
}

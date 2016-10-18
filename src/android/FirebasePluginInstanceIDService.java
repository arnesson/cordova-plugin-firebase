package org.apache.cordova.firebase;

import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;


public class FirebasePluginInstanceIDService extends FirebaseInstanceIdService {

    private static final String TAG = "FirebasePlugin";

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String token = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + token);

        if(FirebasePlugin.tokenRefreshCallbackContext == null) {
            return;
        }
        final CallbackContext callbackContext = FirebasePlugin.tokenRefreshCallbackContext.get();
        if (callbackContext != null && token != null) {
            callbackContext.success(token);
        }
    }
}

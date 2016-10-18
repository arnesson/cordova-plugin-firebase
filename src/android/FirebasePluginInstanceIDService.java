package org.apache.cordova.firebase;

import com.google.firebase.iid.FirebaseInstanceIdService;


public class FirebasePluginInstanceIDService extends FirebaseInstanceIdService {

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    @Override
    public void onTokenRefresh() {
        FirebasePlugin.onTokenRefresh();
    }
}

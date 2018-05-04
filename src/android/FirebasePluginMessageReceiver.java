package org.apache.cordova.firebase;

import com.google.firebase.messaging.RemoteMessage;

public abstract class FirebasePluginMessageReceiver {

    public FirebasePluginMessageReceiver() {
        FirebasePluginMessageReceiverManager.register(this);
    }

    /**
     * Concrete subclasses should override this and return true if they handle the received message.
     *
     * @param remoteMessage
     * @return true if the received message was handled by the receiver so should not be handled by FirebasePlugin.
     */
    public abstract boolean onMessageReceived(RemoteMessage remoteMessage);
}

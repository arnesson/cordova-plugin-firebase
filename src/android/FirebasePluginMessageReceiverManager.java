package org.apache.cordova.firebase;

import android.os.Bundle;

import com.google.firebase.messaging.RemoteMessage;

import java.util.ArrayList;
import java.util.List;

public class FirebasePluginMessageReceiverManager {

    private static List<FirebasePluginMessageReceiver> receivers = new ArrayList<FirebasePluginMessageReceiver>();

    public static void register(FirebasePluginMessageReceiver receiver) {
        receivers.add(receiver);
    }

    public static boolean onMessageReceived(RemoteMessage remoteMessage) {
        boolean handled = false;
        for (FirebasePluginMessageReceiver receiver : receivers) {
            boolean wasHandled = receiver.onMessageReceived(remoteMessage);
            if (wasHandled) {
                handled = true;
            }
        }

        return handled;
    }

    public static boolean sendMessage(Bundle bundle) {
            boolean handled = false;
            for (FirebasePluginMessageReceiver receiver : receivers) {
                boolean wasHandled = receiver.sendMessage(bundle);
                if (wasHandled) {
                    handled = true;
                }
            }

            return handled;
        }
}

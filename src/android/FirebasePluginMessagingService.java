package org.apache.cordova.firebase;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.app.Notification;
import android.text.TextUtils;
import android.content.ContentResolver;
import android.graphics.Color;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.List;
import java.util.Map;
import java.util.Random;

public class FirebasePluginMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FirebasePlugin";

    /**
     * Get a string from resources without importing the .R package
     *
     * @param name Resource Name
     * @return Resource
     */
    private String getStringResource(String name) {
        return this.getString(
                this.getResources().getIdentifier(
                        name, "string", this.getPackageName()
                )
        );
    }

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // Pass the message to the receiver manager so any registered receivers can decide to handle it
        boolean wasHandled = FirebasePluginMessageReceiverManager.onMessageReceived(remoteMessage);
        if (wasHandled) {
            Log.d(TAG, "Message was handled by a registered receiver");

            // Don't process the message in this method.
            return;
        }

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        String title = "";
        String text = "";
        String id = "";
        String sound = "";
        String lights = "";
        Map<String, String> data = remoteMessage.getData();

        if (remoteMessage.getNotification() != null) {
            title = remoteMessage.getNotification().getTitle();
            text = remoteMessage.getNotification().getBody();
            id = remoteMessage.getMessageId();
        } else if (data != null) {
            title = data.get("title");
            text = data.get("text");
            id = data.get("id");
            sound = data.get("sound");
            lights = data.get("lights"); //String containing hex ARGB color, miliseconds on, miliseconds off, example: '#FFFF00FF,1000,3000'

            if (TextUtils.isEmpty(text)) {
                text = data.get("body");
            }
        }

        if (TextUtils.isEmpty(id)) {
            Random rand = new Random();
            int n = rand.nextInt(50) + 1;
            id = Integer.toString(n);
        }

        Log.d(TAG, "From: " + remoteMessage.getFrom());
        Log.d(TAG, "Notification Message id: " + id);
        Log.d(TAG, "Notification Message Title: " + title);
        Log.d(TAG, "Notification Message Body/Text: " + text);
        Log.d(TAG, "Notification Message Sound: " + sound);
        Log.d(TAG, "Notification Message Lights: " + lights);

        // TODO: Add option to developer to configure if show notification when app on foreground
        if (!TextUtils.isEmpty(text) || !TextUtils.isEmpty(title) || (data != null && !data.isEmpty())) {
            boolean showNotification = (FirebasePlugin.inBackground() || !FirebasePlugin.hasNotificationsCallback()) && (!TextUtils.isEmpty(text) || !TextUtils.isEmpty(title));
            sendNotification(id, title, text, data, showNotification, sound, lights);
        }
    }

    private void sendNotification(String id, String title, String messageBody, Map<String, String> data, boolean showNotification, String sound, String lights) {
        Bundle bundle = new Bundle();
        for (String key : data.keySet()) {
            bundle.putString(key, data.get(key));
        }

    if (showNotification) {
        Intent intent = new Intent(this, OnNotificationOpenReceiver.class);
        intent.putExtras(bundle);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(this, id.hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT);


        String channelId = "FBApp-" + getPackageName(); // Create one for the app, don't use default.  this.getStringResource("default_notification_channel_id");
        String channelName = "Sound-" + sound; //notificationChannel is only created/built once. Lets create one per sound file so we can switch sounds
        Uri soundPath = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

        if (sound != null) {
            Log.d(TAG, "sound before path is: " + sound);
            // Place your .mp3 in res/raw using resource-file in your config.xml
            soundPath = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + getPackageName() + "//" + sound);
            Log.d(TAG, "Parsed sound is: " + soundPath.toString());
        } else {
            Log.d(TAG, "Sound was null ");
        }

        String imageThumbail = null;
        Log.d(TAG, "Notification Message Oreo compatibility version v1 ");

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {

            Log.d(TAG, "Notification Message is Oreo and above, using notification channel");

            Notification.Builder notificationBuilder =
                new Notification.Builder(this /*MyApplication.getInstance().getApplicationContext()*/, channelId /*NOTIFICATION_CHANNEL_ID */)
                    .setSmallIcon(getApplicationInfo().icon)
                    //.setPriority(Notification.PRIORITY_MAX) // this is deprecated in API 26 but you can still use for below 26. check below update for 26 API
                    //.setSound(defaultSoundUri)
                    .setContentIntent(pendingIntent);

            NotificationChannel notificationChannel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH);
            // Configure the notification channel.
            AudioAttributes att = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build();

            notificationChannel.setSound(soundPath, att);
            notificationChannel.setDescription(messageBody);

            int lightArgb = 0;
            if (lights != null) {
                /*
                try {
                    String[] lightsComponents = lights.replaceAll("\\s", "").split(",");
                    if (lightsComponents.length == 3) {
                        lightArgb = Color.parseColor(lightsComponents[0]);
                        int lightOnMs = Integer.parseInt(lightsComponents[1]);
                        int lightOffMs = Integer.parseInt(lightsComponents[2]);

                        notificationBuilder.setLights(lightArgb, lightOnMs, lightOffMs);
                    }
                } catch (Exception e) {
                }
                */
                notificationChannel.enableLights(true);
                notificationChannel.setLightColor(Color.RED);
            } else {
                notificationChannel.enableLights(false);
                notificationChannel.setLightColor(Color.RED);

            }

            notificationChannel.setVibrationPattern(new long[]{0, 1000, 500, 1000, 200, 1000, 200, 1000});
            notificationChannel.enableVibration(true);
            notificationManager.createNotificationChannel(notificationChannel);
            /*
            if (imageThumbnail != null) {
                notificationBuilder.setStyle(new Notification.BigPictureStyle()
                    .bigPicture(imageThumbnail).setSummaryText(messageBody));
            }
            */

            notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());

        } else {
            NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this /*MyApplication.getInstance().getApplicationContext()*/)
                    .setSmallIcon(getApplicationInfo().icon)
                    .setContentTitle(title)
                    .setContentText(messageBody)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(messageBody))
                    .setAutoCancel(true)
                    .setPriority(Notification.PRIORITY_MAX) // this is deprecated in API 26 but you can still use for below 26. check below update for 26 API
                    .setSound(soundPath) // which may be default
                    .setContentIntent(pendingIntent);
            /*
            if (imageThumbnail != null) {
                notificationBuilder.setStyle(new NotificationCompat.BigPictureStyle()
                    .bigPicture(imageThumbnail).setSummaryText(messageBody));
            }
            */

            int resID = getResources().getIdentifier("notification_icon", "drawable", getPackageName());
            if (resID != 0) {
                notificationBuilder.setSmallIcon(resID);
            } else {
                notificationBuilder.setSmallIcon(getApplicationInfo().icon);
            }

            int lightArgb = 0;
            if (lights != null) {
                try {
                    String[] lightsComponents = lights.replaceAll("\\s", "").split(",");
                    if (lightsComponents.length == 3) {
                        lightArgb = Color.parseColor(lightsComponents[0]);
                        int lightOnMs = Integer.parseInt(lightsComponents[1]);
                        int lightOffMs = Integer.parseInt(lightsComponents[2]);

                        notificationBuilder.setLights(lightArgb, lightOnMs, lightOffMs);
                    }
                } catch (Exception e) {
                }
            }


            notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());

        } else {
            bundle.putBoolean("tap", false);
            bundle.putString("title", title);
            bundle.putString("body", messageBody);
            FirebasePlugin.sendNotification(bundle, this.getApplicationContext());
        }
    }
}

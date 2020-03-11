package org.apache.cordova.firebase;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.content.ContentResolver;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import android.util.Base64;
import android.util.Log;

import com.crashlytics.android.Crashlytics;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigInfo;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;

import io.fabric.sdk.android.Fabric;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.List;

// Firebase PhoneAuth
import java.util.concurrent.TimeUnit;

import com.google.firebase.FirebaseException;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import static android.content.Context.MODE_PRIVATE;

public class FirebasePlugin extends CordovaPlugin {

    protected static FirebasePlugin instance = null;
    private FirebaseAnalytics mFirebaseAnalytics;
    private FirebaseFirestore firestore;
    private Gson gson;
    private FirebaseAuth.AuthStateListener authStateListener;
    private boolean authStateChangeListenerInitialized = false;
    private static CordovaInterface cordovaInterface = null;
    protected static Context applicationContext = null;
    private static Activity cordovaActivity = null;
    private boolean isCrashlyticsEnabled = false;

    protected static final String TAG = "FirebasePlugin";
    protected static final String JS_GLOBAL_NAMESPACE = "FirebasePlugin.";
    protected static final String KEY = "badge";
    protected static final int GOOGLE_SIGN_IN = 0x1;
    protected static final String SETTINGS_NAME = "settings";
    private static final String CRASHLYTICS_COLLECTION_ENABLED = "firebase_crashlytics_collection_enabled";
    private static final String ANALYTICS_COLLECTION_ENABLED = "firebase_analytics_collection_enabled";
    private static final String PERFORMANCE_COLLECTION_ENABLED = "firebase_performance_collection_enabled";

    private static boolean inBackground = true;
    private static ArrayList<Bundle> notificationStack = null;
    private static CallbackContext notificationCallbackContext;
    private static CallbackContext tokenRefreshCallbackContext;
    private static CallbackContext activityResultCallbackContext;
    private static CallbackContext authResultCallbackContext;

    private static NotificationChannel defaultNotificationChannel = null;
    public static String defaultChannelId = null;
    public static String defaultChannelName = null;

    private Map<String, AuthCredential> authCredentials = new HashMap<String, AuthCredential>();
    private Map<String, OAuthProvider> authProviders = new HashMap<String, OAuthProvider>();

    @Override
    protected void pluginInitialize() {
        instance = this;
        cordovaActivity = this.cordova.getActivity();
        applicationContext = cordovaActivity.getApplicationContext();
        final Bundle extras = cordovaActivity.getIntent().getExtras();
        FirebasePlugin.cordovaInterface = this.cordova;
        this.cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Log.d(TAG, "Starting Firebase plugin");

                    if(!getMetaDataFromManifest(CRASHLYTICS_COLLECTION_ENABLED)){
                        isCrashlyticsEnabled = getPreference(CRASHLYTICS_COLLECTION_ENABLED);
                        if(isCrashlyticsEnabled){
                            Fabric.with(applicationContext, new Crashlytics());
                        }
                    }else{
                        isCrashlyticsEnabled = true;
                        setPreference(CRASHLYTICS_COLLECTION_ENABLED, true);
                    }

                    if(getMetaDataFromManifest(ANALYTICS_COLLECTION_ENABLED)){
                        setPreference(ANALYTICS_COLLECTION_ENABLED, true);
                    }

                    if(getMetaDataFromManifest(PERFORMANCE_COLLECTION_ENABLED)){
                        setPreference(PERFORMANCE_COLLECTION_ENABLED, true);
                    }

                    FirebaseApp.initializeApp(applicationContext);
                    mFirebaseAnalytics = FirebaseAnalytics.getInstance(applicationContext);

                    authStateListener = new AuthStateListener();
                    FirebaseAuth.getInstance().addAuthStateListener(authStateListener);

					firestore = FirebaseFirestore.getInstance();
                    gson = new Gson();

                    if (extras != null && extras.size() > 1) {
                        if (FirebasePlugin.notificationStack == null) {
                            FirebasePlugin.notificationStack = new ArrayList<Bundle>();
                        }
                        if (extras.containsKey("google.message_id")) {
                            extras.putString("messageType", "notification");
                            extras.putString("tap", "background");
                            notificationStack.add(extras);
                            Log.d(TAG, "Notification message found on init: " + extras.toString());
                        }
                    }
                    defaultChannelId = getStringResource("default_notification_channel_id");
                    defaultChannelName = getStringResource("default_notification_channel_name");
                    createDefaultChannel();
                }catch (Exception e){
                    handleExceptionWithoutContext(e);
                }
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try{
            if (action.equals("getId")) {
                this.getId(callbackContext);
                return true;
            } else if (action.equals("getToken")) {
                this.getToken(callbackContext);
                return true;
            } else if (action.equals("hasPermission")) {
                this.hasPermission(callbackContext);
                return true;
            }else if (action.equals("subscribe")) {
                this.subscribe(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("unsubscribe")) {
                this.unsubscribe(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("isAutoInitEnabled")) {
                isAutoInitEnabled(callbackContext);
                return true;
            } else if (action.equals("setAutoInitEnabled")) {
                setAutoInitEnabled(callbackContext, args.getBoolean(0));
                return true;
            } else if (action.equals("unregister")) {
                this.unregister(callbackContext);
                return true;
            } else if (action.equals("onMessageReceived")) {
                this.onMessageReceived(callbackContext);
                return true;
            } else if (action.equals("onTokenRefresh")) {
                this.onTokenRefresh(callbackContext);
                return true;
            } else if (action.equals("logEvent")) {
                this.logEvent(callbackContext, args.getString(0), args.getJSONObject(1));
                return true;
            } else if (action.equals("logError")) {
                this.logError(callbackContext, args);
                return true;
            }else if(action.equals("setCrashlyticsUserId")){
                this.setCrashlyticsUserId(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("setScreenName")) {
                this.setScreenName(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("setUserId")) {
                this.setUserId(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("setUserProperty")) {
                this.setUserProperty(callbackContext, args.getString(0), args.getString(1));
                return true;
            } else if (action.equals("activateFetched")) {
                this.activateFetched(callbackContext);
                return true;
            } else if (action.equals("fetch")) {
                if (args.length() > 0) {
                    this.fetch(callbackContext, args.getLong(0));
                } else {
                    this.fetch(callbackContext);
                }
                return true;
            } else if (action.equals("getByteArray")) {
                this.getByteArray(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("getValue")) {
                this.getValue(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("getInfo")) {
                this.getInfo(callbackContext);
                return true;
            } else if (action.equals("setConfigSettings")) {
                this.setConfigSettings(callbackContext, args.getJSONObject(0));
                return true;
            } else if (action.equals("setDefaults")) {
                this.setDefaults(callbackContext, args.getJSONObject(0));
                return true;
            } else if (action.equals("verifyPhoneNumber")) {
                this.verifyPhoneNumber(callbackContext, args);
                return true;
            } else if (action.equals("authenticateUserWithGoogle")) {
                this.authenticateUserWithGoogle(callbackContext, args);
                return true;
            } else if (action.equals("authenticateUserWithApple")) {
                this.authenticateUserWithApple(callbackContext, args);
                return true;
            } else if (action.equals("createUserWithEmailAndPassword")) {
                this.createUserWithEmailAndPassword(callbackContext, args);
                return true;
            } else if (action.equals("signInUserWithEmailAndPassword")) {
                this.signInUserWithEmailAndPassword(callbackContext, args);
                return true;
            } else if (action.equals("signInWithCredential")) {
                this.signInWithCredential(callbackContext, args);
                return true;
            } else if (action.equals("linkUserWithCredential")) {
                this.linkUserWithCredential(callbackContext, args);
                return true;
            } else if (action.equals("reauthenticateWithCredential")) {
                this.reauthenticateWithCredential(callbackContext, args);
                return true;
            } else if (action.equals("isUserSignedIn")) {
                this.isUserSignedIn(callbackContext, args);
                return true;
            } else if (action.equals("signOutUser")) {
                this.signOutUser(callbackContext, args);
                return true;
            } else if (action.equals("getCurrentUser")) {
                this.getCurrentUser(callbackContext, args);
                return true;
            } else if (action.equals("updateUserProfile")) {
                this.updateUserProfile(callbackContext, args);
                return true;
            } else if (action.equals("updateUserEmail")) {
                this.updateUserEmail(callbackContext, args);
                return true;
            } else if (action.equals("sendUserEmailVerification")) {
                this.sendUserEmailVerification(callbackContext, args);
                return true;
            } else if (action.equals("updateUserPassword")) {
                this.updateUserPassword(callbackContext, args);
                return true;
            } else if (action.equals("sendUserPasswordResetEmail")) {
                this.sendUserPasswordResetEmail(callbackContext, args);
                return true;
            } else if (action.equals("deleteUser")) {
                this.deleteUser(callbackContext, args);
                return true;
            } else if (action.equals("startTrace")) {
                this.startTrace(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("incrementCounter")) {
                this.incrementCounter(callbackContext, args.getString(0), args.getString(1));
                return true;
            } else if (action.equals("stopTrace")) {
                this.stopTrace(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("setAnalyticsCollectionEnabled")) {
                this.setAnalyticsCollectionEnabled(callbackContext, args.getBoolean(0));
                return true;
            } else if (action.equals("isAnalyticsCollectionEnabled")) {
                this.isAnalyticsCollectionEnabled(callbackContext);
                return true;
            } else if (action.equals("setPerformanceCollectionEnabled")) {
                this.setPerformanceCollectionEnabled(callbackContext, args.getBoolean(0));
                return true;
            } else if (action.equals("isPerformanceCollectionEnabled")) {
                this.isPerformanceCollectionEnabled(callbackContext);
                return true;
            } else if (action.equals("setCrashlyticsCollectionEnabled")) {
                this.setCrashlyticsCollectionEnabled(callbackContext, args.getBoolean(0));
                return true;
            } else if (action.equals("isCrashlyticsCollectionEnabled")) {
                this.isCrashlyticsCollectionEnabled(callbackContext);
                return true;
            } else if (action.equals("isCrashlyticsCollectionCurrentlyEnabled")) {
                this.isCrashlyticsCollectionCurrentlyEnabled(callbackContext);
                return true;
            } else if (action.equals("clearAllNotifications")) {
                this.clearAllNotifications(callbackContext);
                return true;
            } else if (action.equals("logMessage")) {
                logMessage(args, callbackContext);
                return true;
            } else if (action.equals("sendCrash")) {
                sendCrash(args, callbackContext);
                return true;
            } else if (action.equals("createChannel")) {
                this.createChannel(callbackContext, args.getJSONObject(0));
                return true;
            } else if (action.equals("deleteChannel")) {
                this.deleteChannel(callbackContext, args.getString(0));
                return true;
            } else if (action.equals("listChannels")) {
                this.listChannels(callbackContext);
                return true;
            } else if (action.equals("setDefaultChannel")) {
                this.setDefaultChannel(callbackContext, args.getJSONObject(0));
                return true;
            } else if (action.equals("addDocumentToFirestoreCollection")) {
                this.addDocumentToFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("setDocumentInFirestoreCollection")) {
                this.setDocumentInFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("updateDocumentInFirestoreCollection")) {
                this.updateDocumentInFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("deleteDocumentFromFirestoreCollection")) {
                this.deleteDocumentFromFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("fetchDocumentInFirestoreCollection")) {
                this.fetchDocumentInFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("fetchFirestoreCollection")) {
                this.fetchFirestoreCollection(args, callbackContext);
                return true;
            } else if (action.equals("grantPermission")
                    || action.equals("setBadgeNumber")
                    || action.equals("getBadgeNumber")
            ) {
                // Stubs for other platform methods
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, true));
                return true;
            }else{
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Invalid action: " + action));
                return false;
            }
        }catch(Exception e){
            handleExceptionWithContext(e, callbackContext);
        }
        return false;
    }

    @Override
    public void onPause(boolean multitasking) {
        FirebasePlugin.inBackground = true;
    }

    @Override
    public void onResume(boolean multitasking) {
        FirebasePlugin.inBackground = false;
    }

    @Override
    public void onReset() {
        FirebasePlugin.notificationCallbackContext = null;
        FirebasePlugin.tokenRefreshCallbackContext = null;
        FirebasePlugin.activityResultCallbackContext = null;
        FirebasePlugin.authResultCallbackContext = null;
    }

    @Override
    public void onDestroy() {
        FirebaseAuth.getInstance().removeAuthStateListener(authStateListener);
        instance = null;
        cordovaActivity = null;
        cordovaInterface = null;
        applicationContext = null;
        super.onDestroy();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        try {
            switch (requestCode) {
                case GOOGLE_SIGN_IN:
                    Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
                    GoogleSignInAccount acct;
                    try{
                        acct = task.getResult(ApiException.class);
                    }catch (ApiException ae){
                        if(ae.getStatusCode() == 10){
                            throw new Exception("Unknown server client ID");
                        }else{
                            throw new Exception(CommonStatusCodes.getStatusCodeString(ae.getStatusCode()));
                        }
                    }
                    AuthCredential credential = GoogleAuthProvider.getCredential(acct.getIdToken(), null);
                    String id = FirebasePlugin.instance.saveAuthCredential(credential);

                    JSONObject returnResults = new JSONObject();
                    returnResults.put("instantVerification", true);
                    returnResults.put("id", id);
                    FirebasePlugin.activityResultCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, returnResults));
                    break;
            }
        } catch (Exception e) {
            handleExceptionWithContext(e, FirebasePlugin.activityResultCallbackContext);
        }
    }

    /**
     * Get a string from resources without importing the .R package
     *
     * @param name Resource Name
     * @return Resource
     */
    private String getStringResource(String name) {
        return applicationContext.getString(
                applicationContext.getResources().getIdentifier(
                        name, "string", applicationContext.getPackageName()
                )
        );
    }

    private void onMessageReceived(final CallbackContext callbackContext) {
        FirebasePlugin.notificationCallbackContext = callbackContext;
        if (FirebasePlugin.notificationStack != null) {
            for (Bundle bundle : FirebasePlugin.notificationStack) {
                FirebasePlugin.sendMessage(bundle, applicationContext);
            }
            FirebasePlugin.notificationStack.clear();
        }
    }

    private void onTokenRefresh(final CallbackContext callbackContext) {
        FirebasePlugin.tokenRefreshCallbackContext = callbackContext;

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String currentToken = FirebaseInstanceId.getInstance().getToken();
                    if (currentToken != null) {
                        FirebasePlugin.sendToken(currentToken);
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public static void sendMessage(Bundle bundle, Context context) {
        if (!FirebasePlugin.hasNotificationsCallback()) {
            String packageName = context.getPackageName();
            if (FirebasePlugin.notificationStack == null) {
                FirebasePlugin.notificationStack = new ArrayList<Bundle>();
            }
            notificationStack.add(bundle);

            return;
        }

        final CallbackContext callbackContext = FirebasePlugin.notificationCallbackContext;
        if(bundle != null){
            // Pass the message bundle to the receiver manager so any registered receivers can decide to handle it
            boolean wasHandled = FirebasePluginMessageReceiverManager.sendMessage(bundle);
            if (wasHandled) {
                Log.d(TAG, "Message bundle was handled by a registered receiver");
            }else if (callbackContext != null) {
                JSONObject json = new JSONObject();
                Set<String> keys = bundle.keySet();
                for (String key : keys) {
                  try {
                      json.put(key, bundle.get(key));
                  } catch (JSONException e) {
                      handleExceptionWithContext(e, callbackContext);
                      return;
                  }
                }

                PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, json);
                pluginresult.setKeepCallback(true);
                callbackContext.sendPluginResult(pluginresult);
            }
        }
    }

    public static void sendToken(String token) {
        if (FirebasePlugin.tokenRefreshCallbackContext == null) {
            return;
        }

        final CallbackContext callbackContext = FirebasePlugin.tokenRefreshCallbackContext;
        if (callbackContext != null && token != null) {
            PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, token);
            pluginresult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginresult);
        }
    }

    public static boolean inBackground() {
        return FirebasePlugin.inBackground;
    }

    public static boolean hasNotificationsCallback() {
        return FirebasePlugin.notificationCallbackContext != null;
    }

    @Override
    public void onNewIntent(Intent intent) {
        try {
            super.onNewIntent(intent);
            final Bundle data = intent.getExtras();
            if (data != null && data.containsKey("google.message_id")) {
                data.putString("messageType", "notification");
                data.putString("tap", "background");
                Log.d(TAG, "Notification message on new intent: " + data.toString());
                FirebasePlugin.sendMessage(data, applicationContext);
            }
        }catch (Exception e){
            handleExceptionWithoutContext(e);
        }
    }


    private void getId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String id = FirebaseInstanceId.getInstance().getId();
                    callbackContext.success(id);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void getToken(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String token = FirebaseInstanceId.getInstance().getToken();
                    callbackContext.success(token);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void hasPermission(final CallbackContext callbackContext) {
        if(cordovaActivity == null) return;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(cordovaActivity);
                    boolean areNotificationsEnabled = notificationManagerCompat.areNotificationsEnabled();
                    callbackContext.success(areNotificationsEnabled ? 1 : 0);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void subscribe(final CallbackContext callbackContext, final String topic) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseMessaging.getInstance().subscribeToTopic(topic);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void unsubscribe(final CallbackContext callbackContext, final String topic) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseMessaging.getInstance().unsubscribeFromTopic(topic);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void unregister(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseInstanceId.getInstance().deleteInstanceId();
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void isAutoInitEnabled(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    boolean isEnabled = FirebaseMessaging.getInstance().isAutoInitEnabled();
                    callbackContext.success(isEnabled ? 1 : 0);
                } catch (Exception e) {
                    logExceptionToCrashlytics(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setAutoInitEnabled(final CallbackContext callbackContext, final boolean enabled) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseMessaging.getInstance().setAutoInitEnabled(enabled);
                    callbackContext.success();
                } catch (Exception e) {
                    logExceptionToCrashlytics(e);
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void logEvent(final CallbackContext callbackContext, final String name, final JSONObject params)
            throws JSONException {
        final Bundle bundle = new Bundle();
        Iterator iter = params.keys();
        while (iter.hasNext()) {
            String key = (String) iter.next();
            Object value = params.get(key);

            if (value instanceof Integer || value instanceof Double) {
                bundle.putFloat(key, ((Number) value).floatValue());
            } else {
                bundle.putString(key, value.toString());
            }
        }

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.logEvent(name, bundle);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void logError(final CallbackContext callbackContext, final JSONArray args) throws JSONException {
        final String message = args.getString(0);

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    if(isCrashlyticsEnabled) {
                        // We can optionally be passed a stack trace generated by stacktrace.js.
                        if (args.length() == 2) {
                            JSONArray stackTrace = args.getJSONArray(1);
                            StackTraceElement[] trace = new StackTraceElement[stackTrace.length()];
                            for (int i = 0; i < stackTrace.length(); i++) {
                                JSONObject elem = stackTrace.getJSONObject(i);
                                trace[i] = new StackTraceElement(
                                        "",
                                        elem.optString("functionName", "(anonymous function)"),
                                        elem.optString("fileName", "(unknown file)"),
                                        elem.optInt("lineNumber", -1)
                                );
                            }

                            Exception e = new JavaScriptException(message);
                            e.setStackTrace(trace);
                            logExceptionToCrashlytics(e);
                        } else {
                            logExceptionToCrashlytics(new JavaScriptException(message));
                        }

                        Log.e(TAG, message);
                        callbackContext.success(1);
                    }else{
                        callbackContext.error("Cannot log error - Crashlytics collection is disabled");
                    }
                } catch (Exception e) {
                    logExceptionToCrashlytics(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void logMessage(final JSONArray data,
                            final CallbackContext callbackContext) {

        if(isCrashlyticsEnabled){
            String message = data.optString(0);
            logMessageToCrashlytics(message);
            callbackContext.success();
        }else{
            callbackContext.error("Cannot log message - Crashlytics collection is disabled");
        }
    }

    private void sendCrash(final JSONArray data,
                           final CallbackContext callbackContext) {

        cordovaActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                throw new RuntimeException("This is a crash");
            }
        });
    }


    private void setCrashlyticsUserId(final CallbackContext callbackContext, final String userId) {
        cordovaActivity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    if(isCrashlyticsEnabled){
                        Crashlytics.setUserIdentifier(userId);
                        callbackContext.success();
                    }else{
                        callbackContext.error("Cannot set Crashlytics user ID - Crashlytics collection is disabled");
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setScreenName(final CallbackContext callbackContext, final String name) {
        // This must be called on the main thread
        cordovaActivity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.setCurrentScreen(cordovaActivity, name, null);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setUserId(final CallbackContext callbackContext, final String id) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.setUserId(id);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setUserProperty(final CallbackContext callbackContext, final String name, final String value) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.setUserProperty(name, value);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void activateFetched(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    final boolean activated = FirebaseRemoteConfig.getInstance().activateFetched();
                    callbackContext.success(String.valueOf(activated));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void fetch(CallbackContext callbackContext) {
        fetch(callbackContext, FirebaseRemoteConfig.getInstance().fetch());
    }

    private void fetch(CallbackContext callbackContext, long cacheExpirationSeconds) {
        fetch(callbackContext, FirebaseRemoteConfig.getInstance().fetch(cacheExpirationSeconds));
    }

    private void fetch(final CallbackContext callbackContext, final Task<Void> task) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    task.addOnSuccessListener(new OnSuccessListener<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            callbackContext.success();
                        }
                    }).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(Exception e) {
                            handleExceptionWithContext(e, callbackContext);
                        }
                    });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void getByteArray(final CallbackContext callbackContext, final String key) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    byte[] bytes = FirebaseRemoteConfig.getInstance().getByteArray(key);
                    JSONObject object = new JSONObject();
                    object.put("base64", Base64.encodeToString(bytes, Base64.DEFAULT));
                    object.put("array", new JSONArray(bytes));
                    callbackContext.success(object);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void getValue(final CallbackContext callbackContext, final String key) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseRemoteConfigValue value = FirebaseRemoteConfig.getInstance().getValue(key);
                    callbackContext.success(value.asString());
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void getInfo(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseRemoteConfigInfo remoteConfigInfo = FirebaseRemoteConfig.getInstance().getInfo();
                    JSONObject info = new JSONObject();

                    JSONObject settings = new JSONObject();
                    settings.put("developerModeEnabled", remoteConfigInfo.getConfigSettings().isDeveloperModeEnabled());
                    info.put("configSettings", settings);

                    info.put("fetchTimeMillis", remoteConfigInfo.getFetchTimeMillis());
                    info.put("lastFetchStatus", remoteConfigInfo.getLastFetchStatus());

                    callbackContext.success(info);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setConfigSettings(final CallbackContext callbackContext, final JSONObject config) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    boolean devMode = config.getBoolean("developerModeEnabled");
                    FirebaseRemoteConfigSettings.Builder settings = new FirebaseRemoteConfigSettings.Builder()
                            .setDeveloperModeEnabled(devMode);
                    FirebaseRemoteConfig.getInstance().setConfigSettings(settings.build());
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setDefaults(final CallbackContext callbackContext, final JSONObject defaults) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseRemoteConfig.getInstance().setDefaults(defaultsToMap(defaults));
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private static Map<String, Object> defaultsToMap(JSONObject object) throws JSONException {
        final Map<String, Object> map = new HashMap<String, Object>();

        for (Iterator<String> keys = object.keys(); keys.hasNext(); ) {
            String key = keys.next();
            Object value = object.get(key);

            if (value instanceof Integer) {
                //setDefaults() should take Longs
                value = new Long((Integer) value);
            } else if (value instanceof JSONArray) {
                JSONArray array = (JSONArray) value;
                if (array.length() == 1 && array.get(0) instanceof String) {
                    //parse byte[] as Base64 String
                    value = Base64.decode(array.getString(0), Base64.DEFAULT);
                } else {
                    //parse byte[] as numeric array
                    byte[] bytes = new byte[array.length()];
                    for (int i = 0; i < array.length(); i++)
                        bytes[i] = (byte) array.getInt(i);
                    value = bytes;
                }
            }

            map.put(key, value);
        }
        return map;
    }


    public void isUserSignedIn(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    boolean isSignedIn = FirebaseAuth.getInstance().getCurrentUser() != null;
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isSignedIn));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void signOutUser(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }
                    FirebaseAuth.getInstance().signOut();
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void getCurrentUser(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }
                    JSONObject returnResults = new JSONObject();
                    returnResults.put("name", user.getDisplayName());
                    returnResults.put("email", user.getEmail());
                    returnResults.put("emailIsVerified", user.isEmailVerified());
                    returnResults.put("phoneNumber", user.getPhoneNumber());
                    returnResults.put("photoUrl", user.getPhotoUrl() == null ? null : user.getPhotoUrl().toString());
                    returnResults.put("uid", user.getUid());
                    returnResults.put("providerId", user.getProviderId());

                    user.getIdToken(true).addOnSuccessListener(new OnSuccessListener<GetTokenResult>() {
                        @Override
                        public void onSuccess(GetTokenResult result) {
                            try {
                                String idToken = result.getToken();
                                returnResults.put("idToken", idToken);
                                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, returnResults));
                            } catch (Exception e) {
                                handleExceptionWithContext(e, callbackContext);
                            }
                        }
                    });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void updateUserProfile(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    JSONObject profile = args.getJSONObject(0);
                    UserProfileChangeRequest profileUpdates;
                    if(profile.has("name") && profile.has("photoUri")){
                        profileUpdates = new UserProfileChangeRequest.Builder()
                            .setDisplayName(profile.getString("name"))
                            .setPhotoUri(Uri.parse(profile.getString("photoUri")))
                            .build();
                    }else if(profile.has("name")){
                        profileUpdates = new UserProfileChangeRequest.Builder()
                            .setDisplayName(profile.getString("name"))
                            .build();
                    }else if(profile.has("photoUri")){
                        profileUpdates = new UserProfileChangeRequest.Builder()
                            .setPhotoUri(Uri.parse(profile.getString("photoUri")))
                            .build();
                    }else{
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "'name' and/or 'photoUri' keys must be specified in the profile object"));
                        return;
                    }

                    user.updateProfile(profileUpdates)
                        .addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                            }
                        });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void updateUserEmail(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    String email = args.getString(0);
                    user.updateEmail(email)
                        .addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                            }
                        });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void sendUserEmailVerification(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    user.sendEmailVerification()
                        .addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                            }
                        });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void updateUserPassword(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    String password = args.getString(0);
                    user.updatePassword(password)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void sendUserPasswordResetEmail(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseAuth auth = FirebaseAuth.getInstance();
                    String email = args.getString(0);
                    auth.sendPasswordResetEmail(email)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void deleteUser(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    user.delete()
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void reauthenticateWithCredential(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                    if(user == null){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No user is currently signed"));
                        return;
                    }

                    JSONObject jsonCredential = args.getJSONObject(0);
                    if(!FirebasePlugin.instance.isValidJsonCredential(jsonCredential)){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No auth credentials specified"));
                        return;
                    }

                    AuthCredential authCredential = FirebasePlugin.instance.obtainAuthCredential(jsonCredential);
                    if(authCredential != null){
                        user.reauthenticate(authCredential)
                                .addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {
                                        FirebasePlugin.instance.handleTaskOutcome(task, callbackContext);
                                    }
                                });
                        return;
                    }

                    OAuthProvider authProvider = FirebasePlugin.instance.obtainAuthProvider(jsonCredential);
                    if(authProvider != null){
                        FirebasePlugin.instance.authResultCallbackContext = callbackContext;
                        user.startActivityForReauthenticateWithProvider(FirebasePlugin.cordovaActivity, authProvider)
                                .addOnSuccessListener(new AuthResultOnSuccessListener())
                                .addOnFailureListener(new AuthResultOnFailureListener());
                        return;
                    }

                    //ELSE
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Specified native auth credential id does not exist"));

                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }



    public void signInWithCredential(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    JSONObject jsonCredential = args.getJSONObject(0);
                    if(!FirebasePlugin.instance.isValidJsonCredential(jsonCredential)){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No auth credentials specified"));
                        return;
                    }

                    AuthCredential authCredential = FirebasePlugin.instance.obtainAuthCredential(jsonCredential);
                    if(authCredential != null){
                        FirebaseAuth.getInstance().signInWithCredential(authCredential).addOnCompleteListener(cordova.getActivity(), new AuthResultOnCompleteListener(callbackContext));
                        return;
                    }

                    OAuthProvider authProvider = FirebasePlugin.instance.obtainAuthProvider(jsonCredential);
                    if(authProvider != null){
                        FirebasePlugin.instance.authResultCallbackContext = callbackContext;
                        FirebaseAuth.getInstance().startActivityForSignInWithProvider(FirebasePlugin.cordovaActivity, authProvider)
                                .addOnSuccessListener(new AuthResultOnSuccessListener())
                                .addOnFailureListener(new AuthResultOnFailureListener());
                        return;
                    }

                    //ELSE
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Specified native auth credential id does not exist"));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void linkUserWithCredential(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    JSONObject jsonCredential = args.getJSONObject(0);
                    if(!FirebasePlugin.instance.isValidJsonCredential(jsonCredential)){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "No auth credentials specified"));
                        return;
                    }

                    AuthCredential authCredential = FirebasePlugin.instance.obtainAuthCredential(jsonCredential);
                    if(authCredential != null){
                        FirebaseAuth.getInstance().getCurrentUser().linkWithCredential(authCredential).addOnCompleteListener(cordova.getActivity(), new AuthResultOnCompleteListener(callbackContext));
                        return;
                    }

                    //ELSE
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Specified native auth credential id does not exist"));

                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private boolean isValidJsonCredential(JSONObject jsonCredential) throws JSONException{
        return jsonCredential.has("id") || (jsonCredential.has("verificationId") && jsonCredential.has("code"));
    }

    private PhoneAuthProvider.OnVerificationStateChangedCallbacks mCallbacks;

    public void verifyPhoneNumber(
            final CallbackContext callbackContext,
            final JSONArray args
    ) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mCallbacks = new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                        @Override
                        public void onVerificationCompleted(PhoneAuthCredential credential) {
                            // This callback will be invoked in two situations:
                            // 1 - Instant verification. In some cases the phone number can be instantly
                            //     verified without needing to send or enter a verification code.
                            // 2 - Auto-retrieval. On some devices Google Play services can automatically
                            //     detect the incoming verification SMS and perform verificaiton without
                            //     user action.
                            Log.d(TAG, "success: verifyPhoneNumber.onVerificationCompleted");

                            String id = FirebasePlugin.instance.saveAuthCredential((AuthCredential) credential);

                            JSONObject returnResults = new JSONObject();
                            try {
                                returnResults.put("instantVerification", true);
                                returnResults.put("id", id);
                            } catch(JSONException e){
                                handleExceptionWithContext(e, callbackContext);
                                return;
                            }
                            PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, returnResults);
                            pluginresult.setKeepCallback(true);
                            callbackContext.sendPluginResult(pluginresult);
                        }

                        @Override
                        public void onVerificationFailed(FirebaseException e) {
                            // This callback is invoked in an invalid request for verification is made,
                            // for instance if the the phone number format is not valid.
                            Log.w(TAG, "failed: verifyPhoneNumber.onVerificationFailed ", e);

                            String errorMsg;
                            if (e instanceof FirebaseAuthInvalidCredentialsException) {
                                // Invalid request
                                errorMsg = "Invalid phone number";
                            } else if (e instanceof FirebaseTooManyRequestsException) {
                                // The SMS quota for the project has been exceeded
                                errorMsg = "The SMS quota for the project has been exceeded";
                            }else{
                                errorMsg = e.getMessage();
                            }
                            callbackContext.error(errorMsg);
                        }

                        @Override
                        public void onCodeSent(String verificationId, PhoneAuthProvider.ForceResendingToken token) {
                            // The SMS verification code has been sent to the provided phone number, we
                            // now need to ask the user to enter the code and then construct a credential
                            // by combining the code with a verification ID [(in app)].
                            Log.d(TAG, "success: verifyPhoneNumber.onCodeSent");

                            JSONObject returnResults = new JSONObject();
                            try {
                                returnResults.put("verificationId", verificationId);
                                returnResults.put("instantVerification", false);
                            } catch (JSONException e) {
                                handleExceptionWithContext(e, callbackContext);
                                return;
                            }
                            PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, returnResults);
                            pluginresult.setKeepCallback(true);
                            callbackContext.sendPluginResult(pluginresult);
                        }
                    };

                    String number = args.getString(0);
                    int timeOutDuration = args.getInt(1);
                    String smsCode = args.getString(2);

                    if(smsCode != null && smsCode != "null"){
                        FirebaseAuth.getInstance().getFirebaseAuthSettings().setAutoRetrievedSmsCodeForPhoneNumber(number, smsCode);
                    }

                    PhoneAuthProvider.getInstance().verifyPhoneNumber(number, // Phone number to verify
                            timeOutDuration, // Timeout duration
                            TimeUnit.SECONDS, // Unit of timeout
                            cordovaActivity, // Activity (for callback binding)
                            mCallbacks); // OnVerificationStateChangedCallbacks
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void createUserWithEmailAndPassword(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String email = args.getString(0);
                    String password = args.getString(1);

                    if(email == null || email.equals("")){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "User email address must be specified"));
                        return;
                    }

                    if(password == null || password.equals("")){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "User password must be specified"));
                        return;
                    }

                    FirebaseAuth.getInstance().createUserWithEmailAndPassword(email, password).addOnCompleteListener(cordova.getActivity(), new AuthResultOnCompleteListener(callbackContext));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void signInUserWithEmailAndPassword(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String email = args.getString(0);
                    String password = args.getString(1);

                    if(email == null || email.equals("")){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "User email address must be specified"));
                        return;
                    }

                    if(password == null || password.equals("")){
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "User password must be specified"));
                        return;
                    }

                    FirebaseAuth.getInstance().signInWithEmailAndPassword(email, password).addOnCompleteListener(cordova.getActivity(), new AuthResultOnCompleteListener(callbackContext));
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }


    public void authenticateUserWithGoogle(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String clientId = args.getString(0);

                    GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                            .requestIdToken(clientId)
                            .requestEmail()
                            .build();

                    GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(FirebasePlugin.instance.cordovaActivity, gso);
                    Intent signInIntent = mGoogleSignInClient.getSignInIntent();
                    FirebasePlugin.activityResultCallbackContext = callbackContext;
                    FirebasePlugin.instance.cordovaInterface.startActivityForResult(FirebasePlugin.instance, signInIntent, GOOGLE_SIGN_IN);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void authenticateUserWithApple(final CallbackContext callbackContext, final JSONArray args){
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String locale = args.getString(0);
                    OAuthProvider.Builder provider = OAuthProvider.newBuilder("apple.com");
                    if(locale != null){
                        provider.addCustomParameter("locale", locale);
                    }
                    Task<AuthResult> pending = FirebaseAuth.getInstance().getPendingAuthResult();
                    if (pending != null) {
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Auth result is already pending"));
                        pending
                                .addOnSuccessListener(new AuthResultOnSuccessListener())
                                .addOnFailureListener(new AuthResultOnFailureListener());
                    } else {
                        String id = FirebasePlugin.instance.saveAuthProvider(provider.build());;
                        JSONObject returnResults = new JSONObject();
                        returnResults.put("instantVerification", true);
                        returnResults.put("id", id);
                        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, returnResults));
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    //
    // Firebase Performace
    //

    private HashMap<String, Trace> traces = new HashMap<String, Trace>();

    private void startTrace(final CallbackContext callbackContext, final String name) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    Trace myTrace = null;
                    if (self.traces.containsKey(name)) {
                        myTrace = self.traces.get(name);
                    }

                    if (myTrace == null) {
                        myTrace = FirebasePerformance.getInstance().newTrace(name);
                        myTrace.start();
                        self.traces.put(name, myTrace);
                    }

                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void incrementCounter(final CallbackContext callbackContext, final String name, final String counterNamed) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    Trace myTrace = null;
                    if (self.traces.containsKey(name)) {
                        myTrace = self.traces.get(name);
                    }

                    if (myTrace != null && myTrace instanceof Trace) {
                        myTrace.incrementMetric(counterNamed, 1);
                        callbackContext.success();
                    } else {
                        callbackContext.error("Trace not found");
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void stopTrace(final CallbackContext callbackContext, final String name) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    Trace myTrace = null;
                    if (self.traces.containsKey(name)) {
                        myTrace = self.traces.get(name);
                    }

                    if (myTrace != null && myTrace instanceof Trace) { //
                        myTrace.stop();
                        self.traces.remove(name);
                        callbackContext.success();
                    } else {
                        callbackContext.error("Trace not found");
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void setAnalyticsCollectionEnabled(final CallbackContext callbackContext, final boolean enabled) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    if(getMetaDataFromManifest(ANALYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Cannot set Analytics data collection at runtime as it's hard-coded to ENABLED at build-time in the manifest");
                    }else if(enabled && getPreference(ANALYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Analytics data collection is already set to enabled");
                    }else if(!enabled && !getPreference(ANALYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Analytics data collection is already set to disabled");
                    }else{
                        mFirebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
                        setPreference(ANALYTICS_COLLECTION_ENABLED, enabled);
                        callbackContext.success();
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void isAnalyticsCollectionEnabled(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    callbackContext.success(getPreference(ANALYTICS_COLLECTION_ENABLED) ? 1 : 0);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void setPerformanceCollectionEnabled(final CallbackContext callbackContext, final boolean enabled) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    if(getMetaDataFromManifest(PERFORMANCE_COLLECTION_ENABLED)){
                        callbackContext.error("Cannot set Performance data collection at runtime as it's hard-coded to ENABLED at build-time in the manifest");
                    }else if(enabled && getPreference(PERFORMANCE_COLLECTION_ENABLED)){
                        callbackContext.error("Performance data collection is already set to enabled");
                    }else if(!enabled && !getPreference(PERFORMANCE_COLLECTION_ENABLED)){
                        callbackContext.error("Performance data collection is already set to disabled");
                    }else{
                        FirebasePerformance.getInstance().setPerformanceCollectionEnabled(enabled);
                        setPreference(PERFORMANCE_COLLECTION_ENABLED, enabled);
                        callbackContext.success();
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void isPerformanceCollectionEnabled(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    callbackContext.success(getPreference(PERFORMANCE_COLLECTION_ENABLED) ? 1 : 0);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void setCrashlyticsCollectionEnabled(final CallbackContext callbackContext, final boolean enabled) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    if(getMetaDataFromManifest(CRASHLYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Cannot set Crashlytics data collection at runtime as it's hard-coded to ENABLED at build-time in the manifest");
                    }else if(enabled && getPreference(CRASHLYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Crashlytics data collection is already set to enabled");
                    }else if(!enabled && !getPreference(CRASHLYTICS_COLLECTION_ENABLED)){
                        callbackContext.error("Crashlytics data collection is already set to disabled");
                    }else{
                        setPreference(CRASHLYTICS_COLLECTION_ENABLED, enabled);
                        callbackContext.success();
                    }
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void isCrashlyticsCollectionEnabled(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    callbackContext.success(getPreference(CRASHLYTICS_COLLECTION_ENABLED) ? 1 : 0);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    private void isCrashlyticsCollectionCurrentlyEnabled(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    callbackContext.success(isCrashlyticsEnabled ? 1 : 0);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                    e.printStackTrace();
                }
            }
        });
    }

    public void clearAllNotifications(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    NotificationManager nm = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
                    nm.cancelAll();
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void createChannel(final CallbackContext callbackContext, final JSONObject options) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    createChannel(options);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    protected static NotificationChannel createChannel(final JSONObject options) throws JSONException {
        NotificationChannel channel = null;
        // only call on Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String id = options.getString("id");
            Log.i(TAG, "Creating channel id="+id);

            if(channelExists(id)){
                deleteChannel(id);
            }

            NotificationManager nm = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
            String packageName = cordovaActivity.getPackageName();

            String name = options.optString("name", "");
            Log.d(TAG, "Channel "+id+" - name="+name);

            int importance = options.optInt("importance", NotificationManager.IMPORTANCE_HIGH);
            Log.d(TAG, "Channel "+id+" - importance="+importance);

            channel = new NotificationChannel(id,
                    name,
                    importance);

            // Description
            String description = options.optString("description", "");
            Log.d(TAG, "Channel "+id+" - description="+description);
            channel.setDescription(description);

            // Light
            boolean light = options.optBoolean("light", true);
            Log.d(TAG, "Channel "+id+" - light="+light);
            channel.enableLights(light);

            int lightColor = options.optInt("lightColor", -1);
            if (lightColor != -1) {
                Log.d(TAG, "Channel "+id+" - lightColor="+lightColor);
                channel.setLightColor(lightColor);
            }

            // Visibility
            int visibility = options.optInt("visibility", NotificationCompat.VISIBILITY_PUBLIC);
            Log.d(TAG, "Channel "+id+" - visibility="+visibility);
            channel.setLockscreenVisibility(visibility);

            // Badge
            boolean badge = options.optBoolean("badge", true);
            Log.d(TAG, "Channel "+id+" - badge="+badge);
            channel.setShowBadge(badge);

            // Sound
            String sound = options.optString("sound", "default");
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE).build();
            if ("ringtone".equals(sound)) {
                channel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE), audioAttributes);
                Log.d(TAG, "Channel "+id+" - sound=ringtone");
            } else if (sound != null && !sound.contentEquals("default")) {
                Uri soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/raw/" + sound);
                channel.setSound(soundUri, audioAttributes);
                Log.d(TAG, "Channel "+id+" - sound="+sound);
            } else if (sound != "false"){
                channel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), audioAttributes);
                Log.d(TAG, "Channel "+id+" - sound=default");
            }else{
                Log.d(TAG, "Channel "+id+" - sound=none");
            }

            // Vibration: if vibration setting is an array set vibration pattern, else set enable vibration.
            JSONArray pattern = options.optJSONArray("vibration");
            if (pattern != null) {
                int patternLength = pattern.length();
                long[] patternArray = new long[patternLength];
                for (int i = 0; i < patternLength; i++) {
                    patternArray[i] = pattern.optLong(i);
                }
                channel.enableVibration(true);
                channel.setVibrationPattern(patternArray);
                Log.d(TAG, "Channel "+id+" - vibrate="+pattern);
            } else {
                boolean vibrate = options.optBoolean("vibration", true);
                channel.enableVibration(vibrate);
                Log.d(TAG, "Channel "+id+" - vibrate="+vibrate);
            }

            // Create channel
            nm.createNotificationChannel(channel);
        }
        return channel;
    }

    protected static void createDefaultChannel() throws JSONException {
        JSONObject options = new JSONObject();
        options.put("id", defaultChannelId);
        options.put("name", defaultChannelName);
        createDefaultChannel(options);
    }

    protected static void createDefaultChannel(final JSONObject options) throws JSONException {
        defaultNotificationChannel = createChannel(options);
    }

    public void setDefaultChannel(final CallbackContext callbackContext, final JSONObject options) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    deleteChannel(defaultChannelId);

                    String id = options.optString("id", null);
                    if(id != null){
                        defaultChannelId = id;
                    }

                    String name = options.optString("name", null);
                    if(name != null){
                        defaultChannelName = name;
                    }
                    createDefaultChannel(options);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public void deleteChannel(final CallbackContext callbackContext, final String channelID) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    deleteChannel(channelID);
                    callbackContext.success();
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    protected static void deleteChannel(final String channelID){
        // only call on Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
            nm.deleteNotificationChannel(channelID);
        }
    }

    public void listChannels(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    List<NotificationChannel> notificationChannels = listChannels();
                    JSONArray channels = new JSONArray();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        for (NotificationChannel notificationChannel : notificationChannels) {
                            JSONObject channel = new JSONObject();
                            channel.put("id", notificationChannel.getId());
                            channel.put("name", notificationChannel.getName());
                            channels.put(channel);
                        }
                    }
                    callbackContext.success(channels);
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    public static List<NotificationChannel> listChannels(){
        List<NotificationChannel> notificationChannels = null;
        // only call on Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager nm = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationChannels = nm.getNotificationChannels();
        }
        return notificationChannels;
    }

    public static boolean channelExists(String channelId){
        boolean exists = false;
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            List<NotificationChannel> notificationChannels = FirebasePlugin.listChannels();
            if(notificationChannels != null){
                for (NotificationChannel notificationChannel : notificationChannels) {
                    if(notificationChannel.getId().equals(channelId)){
                        exists = true;
                    }
                }
            }
        }
        return exists;
    }

    //
    // Firestore
    //
    private void addDocumentToFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String jsonDoc = args.getString(0);
                    String collection = args.getString(1);

                    firestore.collection(collection)
                            .add(jsonStringToMap(jsonDoc))
                            .addOnSuccessListener(new OnSuccessListener<DocumentReference>() {
                                @Override
                                public void onSuccess(DocumentReference documentReference) {
                                    callbackContext.success(documentReference.getId());
                                }
                            })
                            .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    handleExceptionWithContext(e, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void setDocumentInFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String documentId = args.getString(0);
                    String jsonDoc = args.getString(1);
                    String collection = args.getString(2);

                    firestore.collection(collection).document(documentId)
                            .set(jsonStringToMap(jsonDoc))
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    callbackContext.success();
                                }
                            })
                            .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    handleExceptionWithContext(e, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void updateDocumentInFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String documentId = args.getString(0);
                    String jsonDoc = args.getString(1);
                    String collection = args.getString(2);

                    firestore.collection(collection).document(documentId)
                            .update(jsonStringToMap(jsonDoc))
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    callbackContext.success();
                                }
                            })
                            .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    handleExceptionWithContext(e, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void deleteDocumentFromFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String documentId = args.getString(0);
                    String collection = args.getString(1);

                    firestore.collection(collection).document(documentId)
                            .delete()
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    callbackContext.success();
                                }
                            })
                            .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    handleExceptionWithContext(e, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void fetchDocumentInFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String documentId = args.getString(0);
                    String collection = args.getString(1);

                    firestore.collection(collection).document(documentId)
                            .get()
                            .addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                                @Override
                                public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                    try {
                                        if (task.isSuccessful()) {
                                            DocumentSnapshot document = task.getResult();
                                            if (document != null) {
                                                JSONObject jsonDoc = mapToJsonObject(document.getData());
                                                callbackContext.success(jsonDoc);
                                            } else {
                                                callbackContext.error("No document found in collection");
                                            }
                                        } else {
                                            Exception e = task.getException();
                                            if(e != null){
                                                handleExceptionWithContext(e, callbackContext);
                                            }
                                        }
                                    } catch (Exception e) {
                                        handleExceptionWithContext(e, callbackContext);
                                    }
                                }
                            })
                            .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    handleExceptionWithContext(e, callbackContext);
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }

    private void fetchFirestoreCollection(JSONArray args, CallbackContext callbackContext) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String collection = args.getString(0);
                    firestore.collection(collection)
                            .get()
                            .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                                @Override
                                public void onComplete(@NonNull Task<QuerySnapshot> task) {
                                    try {
                                        if (task.isSuccessful()) {
                                            JSONObject jsonDocs = new JSONObject();
                                            for (QueryDocumentSnapshot document : task.getResult()) {
                                                jsonDocs.put(document.getId(), mapToJsonObject(document.getData()));
                                            }
                                            callbackContext.success(jsonDocs);
                                        } else {
                                            handleExceptionWithContext(task.getException(), callbackContext);
                                        }
                                    } catch (Exception e) {
                                        handleExceptionWithContext(e, callbackContext);
                                    }
                                }
                            });
                } catch (Exception e) {
                    handleExceptionWithContext(e, callbackContext);
                }
            }
        });
    }


    protected static void handleExceptionWithContext(Exception e, CallbackContext context) {
        String msg = e.toString();
        Log.e(TAG, msg);
        instance.logExceptionToCrashlytics(e);
        context.error(msg);
    }

    protected static void handleExceptionWithoutContext(Exception e){
        String msg = e.toString();
        Log.e(TAG, msg);
        if (instance != null) {
            instance.logExceptionToCrashlytics(e);
            instance.logErrorToWebview(msg);
        }
    }

    protected void logErrorToWebview(String msg){
        Log.e(TAG, msg);
        executeGlobalJavascript("console.error(\""+TAG+"[native]: "+escapeDoubleQuotes(msg)+"\")");
    }

    private String escapeDoubleQuotes(String string){
        String escapedString = string.replace("\"", "\\\"");
        escapedString = escapedString.replace("%22", "\\%22");
        return escapedString;
    }

    private void executeGlobalJavascript(final String jsString){
        if(cordovaActivity == null) return;
        cordovaActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:" + jsString);
            }
        });
    }

    private String saveAuthCredential(AuthCredential authCredential){
        String id = this.generateId();
        this.authCredentials.put(id, authCredential);
        return id;
    }

    private String saveAuthProvider(OAuthProvider authProvider){
        String id = this.generateId();
        this.authProviders.put(id, authProvider);
        return id;
    }

    private String generateId(){
        Random r = new Random();
        return Integer.toString(r.nextInt(1000+1));
    }

    private boolean getMetaDataFromManifest(String name) throws Exception{
        return applicationContext.getPackageManager().getApplicationInfo(applicationContext.getPackageName(), PackageManager.GET_META_DATA).metaData.getBoolean(name);
    }

    private void setPreference(String name, boolean value){
        SharedPreferences settings = cordovaActivity.getSharedPreferences(SETTINGS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean(name, value);
        editor.apply();
    }

    private boolean getPreference(String name){
        SharedPreferences settings = cordovaActivity.getSharedPreferences(SETTINGS_NAME, MODE_PRIVATE);
        return settings.getBoolean(name, false);
    }

    private void handleTaskOutcome(@NonNull Task<Void> task, CallbackContext callbackContext) {
        try {
            if (task.isSuccessful()) {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            }else{
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, task.getException().getMessage()));
            }
        } catch (Exception e) {
            handleExceptionWithContext(e, callbackContext);
        }
    }

    private void handleAuthTaskOutcome(@NonNull Task<AuthResult> task, CallbackContext callbackContext) {
        try {
            if (task.isSuccessful()) {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            }else{
                String errMessage = task.getException().getMessage();
                if (task.getException() instanceof FirebaseAuthInvalidCredentialsException) {
                    errMessage = "Invalid verification code";
                }
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, errMessage));
            }
        } catch (Exception e) {
            handleExceptionWithContext(e, callbackContext);
        }
    }

    private AuthCredential obtainAuthCredential(JSONObject jsonCredential) throws JSONException {
        AuthCredential authCredential = null;
        if(jsonCredential.has("verificationId") && jsonCredential.has("code")){
            Log.d(TAG, "Using specified verificationId and code to authenticate");
            authCredential = (AuthCredential) PhoneAuthProvider.getCredential(jsonCredential.getString("verificationId"), jsonCredential.getString("code"));
        }else if(jsonCredential.has("id") && FirebasePlugin.instance.authCredentials.containsKey(jsonCredential.getString("id"))){
            Log.d(TAG, "Using native auth credential to authenticate");
            authCredential = FirebasePlugin.instance.authCredentials.get(jsonCredential.getString("id"));
        }
        return authCredential;
    }

    private OAuthProvider obtainAuthProvider(JSONObject jsonCredential) throws JSONException{
        OAuthProvider authProvider = null;
        if(jsonCredential.has("id") && FirebasePlugin.instance.authProviders.containsKey(jsonCredential.getString("id"))){
            Log.d(TAG, "Using native auth provider to authenticate");
            authProvider = FirebasePlugin.instance.authProviders.get(jsonCredential.getString("id"));
        }
        return authProvider;
    }


    private static class AuthResultOnSuccessListener implements OnSuccessListener<AuthResult> {
        @Override
        public void onSuccess(AuthResult authResult) {
            Log.d(TAG, "AuthResult:onSuccess:" + authResult);
            if(FirebasePlugin.instance.authResultCallbackContext != null){
                FirebasePlugin.instance.authResultCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            }
        }
    }

    private static class AuthResultOnFailureListener implements OnFailureListener {
        @Override
        public void onFailure(@NonNull Exception e) {
            Log.w(TAG, "AuthResult:onFailure", e);
            if(FirebasePlugin.instance.authResultCallbackContext != null){
                FirebasePlugin.instance.authResultCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
            }
        }
    }

    private static class AuthResultOnCompleteListener implements OnCompleteListener<AuthResult> {
        private final CallbackContext callbackContext;

        public AuthResultOnCompleteListener(CallbackContext callbackContext) {
            this.callbackContext = callbackContext;
        }

        @Override
        public void onComplete(@NonNull Task<AuthResult> task) {
            FirebasePlugin.instance.handleAuthTaskOutcome(task, callbackContext);
        }
    }

    private static class AuthStateListener implements FirebaseAuth.AuthStateListener {
        @Override
        public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
            try {
                if(!FirebasePlugin.instance.authStateChangeListenerInitialized){
                    FirebasePlugin.instance.authStateChangeListenerInitialized = true;
                }else{
                    FirebaseUser user = firebaseAuth.getCurrentUser();
                    FirebasePlugin.instance.executeGlobalJavascript(JS_GLOBAL_NAMESPACE+"_onAuthStateChange("+(user != null ? "true" : "false")+")");
                }
            } catch (Exception e) {
                handleExceptionWithoutContext(e);
            }
        }
    }

	private Map<String, Object> jsonStringToMap(String jsonString)  throws JSONException {
        Type type = new TypeToken<Map<String, Object>>(){}.getType();
        return gson.fromJson(jsonString, type);
    }


    private JSONObject mapToJsonObject(Map<String, Object> map) throws JSONException {
        String jsonString = gson.toJson(map);
        return new JSONObject(jsonString);
    }

    private void logMessageToCrashlytics(String message){
        if(isCrashlyticsEnabled){
            try{
                Crashlytics.log(message);
            }catch (Exception e){
                Log.e(TAG, e.getMessage());
            }
        }else{
            Log.e(TAG, "Cannot log message - Crashlytics collection is disabled");
        }
    }

    private void logExceptionToCrashlytics(Exception exception){
        if(isCrashlyticsEnabled){
            try{
                Crashlytics.logException(exception);
            }catch (Exception e){
                Log.e(TAG, e.getMessage());
            }
        }else{
            Log.e(TAG, "Cannot log exception - Crashlytics collection is disabled");
        }
    }
}

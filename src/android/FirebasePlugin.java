package org.apache.cordova.firebase;

import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.NotificationManagerCompat;
import android.util.Base64;
import android.util.Log;

import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;
import java.lang.reflect.Field;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.perf.metrics.HttpMetric;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigInfo;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;

import me.leolin.shortcutbadger.ShortcutBadger;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

// Firebase PhoneAuth
import java.util.concurrent.TimeUnit;

import com.google.firebase.FirebaseException;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;

public class FirebasePlugin extends CordovaPlugin {

    private FirebaseAnalytics mFirebaseAnalytics;
    private static CordovaWebView appView;
    private final String TAG = "FirebasePlugin";
    protected static final String KEY = "badge";

    private static boolean inBackground = true;
    private static ArrayList<Bundle> notificationStack = null;
    private static CallbackContext notificationCallbackContext;
    private static CallbackContext tokenRefreshCallbackContext;

    @Override
    protected void pluginInitialize() {
        final Context context = this.cordova.getActivity().getApplicationContext();

        final Intent intent = this.cordova.getActivity().getIntent();
        final Bundle extras = intent.getExtras();

        this.cordova.getThreadPool().execute(() -> {
            Log.d(TAG, "Starting Firebase plugin");
            FirebaseApp.initializeApp(context);
            mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
            mFirebaseAnalytics.setAnalyticsCollectionEnabled(true);
            if (extras != null && extras.size() > 1) {
                if (FirebasePlugin.notificationStack == null) {
                    FirebasePlugin.notificationStack = new ArrayList<Bundle>();
                }
                if (extras.containsKey("google.message_id")) {
                    extras.putBoolean("tap", true);
                    notificationStack.add(extras);
                }
            }
        });
    }


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("getInstanceId")) {
            this.getInstanceId(callbackContext);
            return true;
        } else if (action.equals("getId")) {
            this.getId(callbackContext);
            return true;
        } else if (action.equals("getToken")) {
            this.getToken(callbackContext);
            return true;
        } else if (action.equals("hasPermission")) {
            this.hasPermission(callbackContext);
            return true;
        } else if (action.equals("setBadgeNumber")) {
            this.setBadgeNumber(callbackContext, args.getInt(0));
            return true;
        } else if (action.equals("getBadgeNumber")) {
            this.getBadgeNumber(callbackContext);
            return true;
        } else if (action.equals("subscribe")) {
            this.subscribe(callbackContext, args.getString(0));
            return true;
        } else if (action.equals("unsubscribe")) {
            this.unsubscribe(callbackContext, args.getString(0));
            return true;
        } else if (action.equals("unregister")) {
            this.unregister(callbackContext);
            return true;
        } else if (action.equals("onNotificationOpen")) {
            this.onNotificationOpen(callbackContext);
            return true;
        } else if (action.equals("onTokenRefresh")) {
            this.onTokenRefresh(callbackContext);
            return true;
        } else if (action.equals("logEvent")) {
            this.logEvent(callbackContext, args.getString(0), args.getJSONObject(1));
            return true;
        } else if (action.equals("logError")) {
            this.logError(callbackContext, args.getString(0));
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
            if (args.length() > 1) {
                this.getByteArray(callbackContext, args.getString(0), args.getString(1));
            } else {
                this.getByteArray(callbackContext, args.getString(0), null);
            }
            return true;
        } else if (action.equals("getValue")) {
            if (args.length() > 1) {
                this.getValue(callbackContext, args.getString(0), args.getString(1));
            } else {
                this.getValue(callbackContext, args.getString(0), null);
            }
            return true;
        } else if (action.equals("getInfo")) {
            this.getInfo(callbackContext);
            return true;
        } else if (action.equals("setConfigSettings")) {
            this.setConfigSettings(callbackContext, args.getJSONObject(0));
            return true;
        } else if (action.equals("setDefaults")) {
            if (args.length() > 1) {
                this.setDefaults(callbackContext, args.getJSONObject(0), args.getString(1));
            } else {
                this.setDefaults(callbackContext, args.getJSONObject(0), null);
            }
            return true;
        } else if (action.equals("verifyPhoneNumber")) {
            this.verifyPhoneNumber(callbackContext, args.getString(0), args.getInt(1));
            return true;
        }else if (action.equals("enabeldPerformance")) {
            this.enabeldPerformance(callbackContext, args.getBoolean(0) );
        }else if (action.equals("isPerformanceEnabled")) {
            this.isPerformanceEnabled(callbackContext);
        }else if (action.equals("startTrace")) {
            this.startTrace(callbackContext, args.getString(0));
            return true;
        } else if (action.equals("incrementMetric")) {
            this.incrementMetric(callbackContext, args.getString(0), args.getString(1));
            return true;
        } else if (action.equals("stopTrace")) {
            this.stopTrace(callbackContext, args.getString(0));
            return true;
        }else if (action.equals("startTraceHTTP")) {
            String url = args.getString(0);
            String method = args.getString(1);
            long requestPayloadSize = 0;
            if ( !args.isNull(2) )
                requestPayloadSize = args.getLong(2);
            this.startTraceHTTP(callbackContext, url, method, requestPayloadSize);
            return true;
        }else if (action.equals("stopTraceHTTP")) {
            String traceId = args.getString(0);
            int statusCode = args.getInt(1);
            String contentType = args.getString(2);
            long responsePayloadSize = 0;
            if ( !args.isNull(3) )
                responsePayloadSize = args.getLong(3);
            this.stopTraceHTTP(callbackContext, traceId, statusCode, contentType, responsePayloadSize);
            return true;
        } else if (action.equals("setAnalyticsCollectionEnabled")) {
            this.setAnalyticsCollectionEnabled(callbackContext, args.getBoolean(0));
            return true;
        } else if (action.equals("setPerformanceCollectionEnabled")) {
            this.setPerformanceCollectionEnabled(callbackContext, args.getBoolean(0));
            return true;
        } else if (action.equals("clearAllNotifications")) {
            this.clearAllNotifications(callbackContext);
            return true;
		} else if (action.equals("checkIntentUrlScheme")){
            // check if the starup with custom url scheme
            final Intent intent = this.cordova.getActivity().getIntent();
            final String intentString = intent.getDataString();
            if (intentString != null && intent.getScheme() != null) {
                // callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, intentString));
                this.getUrlFromDynamicLink(intent, callbackContext);
            } else {
                callbackContext.error("App was not started via the launchmyapp URL scheme. Ignoring this errorcallback is the best approach.");
            }
            return  true;
        } else if (action.equals("clearIntentUrlScheme")){
            // clear the intent if the app start up with custom url scheme
            Intent intent = this.cordova.getActivity().getIntent();
            intent.setData(null);
		};

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
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (this.appView != null) {
            appView.handleDestroy();
        }
    }

    private void onNotificationOpen(final CallbackContext callbackContext) {
        FirebasePlugin.notificationCallbackContext = callbackContext;
        if (FirebasePlugin.notificationStack != null) {
            for (Bundle bundle : FirebasePlugin.notificationStack) {
                FirebasePlugin.sendNotification(bundle, this.cordova.getActivity().getApplicationContext());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    public static void sendNotification(Bundle bundle, Context context) {
        if (!FirebasePlugin.hasNotificationsCallback()) {
            String packageName = context.getPackageName();
            if (FirebasePlugin.notificationStack == null) {
                FirebasePlugin.notificationStack = new ArrayList<Bundle>();
            }
            notificationStack.add(bundle);

            return;
        }
        final CallbackContext callbackContext = FirebasePlugin.notificationCallbackContext;
        if (callbackContext != null && bundle != null) {
            JSONObject json = new JSONObject();
            Set<String> keys = bundle.keySet();
            for (String key : keys) {
                try {
                    json.put(key, bundle.get(key));
                } catch (JSONException e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                    return;
                }
            }

            PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, json);
            pluginresult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginresult);
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
        super.onNewIntent(intent);
        final Bundle data = intent.getExtras();
        if (data != null && data.containsKey("google.message_id")) {
            data.putBoolean("tap", true);
            FirebasePlugin.sendNotification(data, this.cordova.getActivity().getApplicationContext());
        }

        this.getUrlFromDynamicLink(intent, null);

    }

    private  void runHandleOpenURLJs(String url, String scheme){
        this.cordova.getActivity().runOnUiThread(() -> {
            if (url != null && scheme != null) {
                try {
                    StringWriter writer = new StringWriter(url.length() * 2);
                    escapeJavaStyleString(writer, url, true, false);
                    webView.loadUrl("javascript:window.handleOpenURL('" + URLEncoder.encode(writer.toString()) + "')");
                } catch (IOException ignore) {}

            }
        });
    }

    private void getUrlFromDynamicLink(Intent intent, final CallbackContext callbackContext){

        FirebaseDynamicLinks.getInstance()
                .getDynamicLink(intent)
                .addOnSuccessListener(this.cordova.getActivity(), (PendingDynamicLinkData pendingDynamicLinkData) -> {
                    // Get deep link from result (may be null if no link is found)
                    Uri deepLink = intent.getData();
                    if (pendingDynamicLinkData != null) {
                        deepLink = pendingDynamicLinkData.getLink();
                    }

                    if ( callbackContext != null && deepLink != null ){
                        callbackContext.success(deepLink.toString());
                    }else{
                        runHandleOpenURLJs(deepLink.toString(), intent.getScheme());
                    }
                })
                .addOnFailureListener(this.cordova.getActivity(),(Exception e) -> {
                    Uri deepLink = intent.getData();
                    if ( callbackContext != null && deepLink != null ){
                        callbackContext.success(deepLink.toString());
                    }else{
                        runHandleOpenURLJs(deepLink.toString(), intent.getScheme());
                    }
                });

    }

    // Taken from commons StringEscapeUtils
    private static void escapeJavaStyleString(Writer out, String str, boolean escapeSingleQuote,  boolean escapeForwardSlash) throws IOException {

        if (out == null) {
            throw new IllegalArgumentException("The Writer must not be null");
        }
        if (str == null) {
            return;
        }
        int sz;
        sz = str.length();
        for (int i = 0; i < sz; i++) {
            char ch = str.charAt(i);

            // handle unicode
            if (ch > 0xfff) {
                out.write("\\u" + hex(ch));
            } else if (ch > 0xff) {
                out.write("\\u0" + hex(ch));
            } else if (ch > 0x7f) {
                out.write("\\u00" + hex(ch));
            } else if (ch < 32) {
                switch (ch) {
                    case '\b':
                        out.write('\\');
                        out.write('b');
                        break;
                    case '\n':
                        out.write('\\');
                        out.write('n');
                        break;
                    case '\t':
                        out.write('\\');
                        out.write('t');
                        break;
                    case '\f':
                        out.write('\\');
                        out.write('f');
                        break;
                    case '\r':
                        out.write('\\');
                        out.write('r');
                        break;
                    default:
                        if (ch > 0xf) {
                            out.write("\\u00" + hex(ch));
                        } else {
                            out.write("\\u000" + hex(ch));
                        }
                        break;
                }
            } else {
                switch (ch) {
                    case '\'':
                        if (escapeSingleQuote) {
                            out.write('\\');
                        }
                        out.write('\'');
                        break;
                    case '"':
                        out.write('\\');
                        out.write('"');
                        break;
                    case '\\':
                        out.write('\\');
                        out.write('\\');
                        break;
                    case '/':
                        if (escapeForwardSlash) {
                            out.write('\\');
                        }
                        out.write('/');
                        break;
                    default:
                        out.write(ch);
                        break;
                }
            }
        }
    }

    private static String hex(char ch) {
        return Integer.toHexString(ch).toUpperCase(Locale.ENGLISH);
    }

    // DEPRECTED - alias of getToken
    private void getInstanceId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String token = FirebaseInstanceId.getInstance().getToken();
                    callbackContext.success(token);
                } catch (Exception e) {
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void getId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    String id = FirebaseInstanceId.getInstance().getId();
                    callbackContext.success(id);
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void hasPermission(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Context context = cordova.getActivity();
                    NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(context);
                    boolean areNotificationsEnabled = notificationManagerCompat.areNotificationsEnabled();
                    JSONObject object = new JSONObject();
                    object.put("isEnabled", areNotificationsEnabled);
                    callbackContext.success(object);
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setBadgeNumber(final CallbackContext callbackContext, final int number) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Context context = cordova.getActivity();
                    SharedPreferences.Editor editor = context.getSharedPreferences(KEY, Context.MODE_PRIVATE).edit();
                    editor.putInt(KEY, number);
                    editor.apply();
                    ShortcutBadger.applyCount(context, number);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void getBadgeNumber(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Context context = cordova.getActivity();
                    SharedPreferences settings = context.getSharedPreferences(KEY, Context.MODE_PRIVATE);
                    int number = settings.getInt(KEY, 0);
                    callbackContext.success(number);
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void parseDataBundle(Bundle bundle, String key, Object value) throws JSONException{
        if ( value instanceof  Float ){
            bundle.putFloat(key, ((Number) value).floatValue());
        } else if (value instanceof Integer ){
            bundle.putInt(key, ((Number) value).intValue() );
        } else if ( value instanceof Double) {
            bundle.putDouble(key, ((Number) value).doubleValue() );
        } else if ( value instanceof  Long ){
            bundle.putLong(key, ((Number) value).longValue() );
        } else if ( value instanceof JSONArray ){
            ArrayList aList = new ArrayList();
            JSONArray ja    = (JSONArray)value;

            for (int i=0; i < ja.length(); i++){
                aList.add( this.makeBundle(ja.getJSONObject(i)) );
            }

            bundle.putParcelableArrayList(key, aList);

        }else if ( value instanceof  JSONObject ){
            bundle.putBundle(key, this.makeBundle( (JSONObject)value ) );
        }else {
            bundle.putString(key, value.toString());
        }
    }

    private Bundle makeBundle(JSONObject params) throws JSONException{
        final Bundle bundle = new Bundle();
        Iterator iter = params.keys();
        while (iter.hasNext()) {
            String key = (String) iter.next();
            Object value = params.get(key);

            this.parseDataBundle(bundle, key, value);

        }
        return bundle;
    }

    private void logEvent(final CallbackContext callbackContext, final String name, final JSONObject params)
            throws JSONException {

        final Bundle bundle = this.makeBundle(params);

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.logEvent(name, bundle);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void logError(final CallbackContext callbackContext, final String message) throws JSONException {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Crashlytics.logException(new Exception(message));
                    callbackContext.success(1);
                } catch (Exception e) {
                    Crashlytics.log(e.getMessage());
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setCrashlyticsUserId(final CallbackContext callbackContext, final String userId) {
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                try {
                    Crashlytics.setUserIdentifier(userId);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setScreenName(final CallbackContext callbackContext, final String name) {
        // This must be called on the main thread
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.setCurrentScreen(cordova.getActivity(), name, null);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                            Crashlytics.logException(e);
                            callbackContext.error(e.getMessage());
                        }
                    });
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void getByteArray(final CallbackContext callbackContext, final String key, final String namespace) {
      cordova.getThreadPool().execute(new Runnable() {
        public void run() {
            try {
                byte[] bytes = namespace == null ? FirebaseRemoteConfig.getInstance().getByteArray(key)
                        : FirebaseRemoteConfig.getInstance().getByteArray(key, namespace);
                JSONObject object = new JSONObject();
                object.put("base64", Base64.encodeToString(bytes, Base64.DEFAULT));
                object.put("array", new JSONArray(bytes));
                callbackContext.success(object);
            } catch (Exception e) {
                Crashlytics.logException(e);
                callbackContext.error(e.getMessage());
            }
        }
      });
    }

    private void getValue(final CallbackContext callbackContext, final String key, final String namespace) {
      cordova.getThreadPool().execute(new Runnable() {
        public void run() {
            try {
                FirebaseRemoteConfigValue value = namespace == null
                        ? FirebaseRemoteConfig.getInstance().getValue(key)
                        : FirebaseRemoteConfig.getInstance().getValue(key, namespace);
                callbackContext.success(value.asString());
            } catch (Exception e) {
                Crashlytics.logException(e);
                callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setDefaults(final CallbackContext callbackContext, final JSONObject defaults, final String namespace) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    if (namespace == null)
                        FirebaseRemoteConfig.getInstance().setDefaults(defaultsToMap(defaults));
                    else
                        FirebaseRemoteConfig.getInstance().setDefaults(defaultsToMap(defaults), namespace);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
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

    private PhoneAuthProvider.OnVerificationStateChangedCallbacks mCallbacks;

    public void verifyPhoneNumber(
            final CallbackContext callbackContext,
            final String number,
            final int timeOutDuration
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

                            JSONObject returnResults = new JSONObject();
                            try {
                                String verificationId = null;
                                String code = null;

                                Field[] fields = credential.getClass().getDeclaredFields();
                                for (Field field : fields) {
                                    Class type = field.getType();
                                    if(type == String.class){
                                        String value = getPrivateField(credential, field);
                                        if(value == null) continue;
                                        if(value.length() > 100) verificationId = value;
                                        else if(value.length() >= 4 && value.length() <= 6) code = value;
                                    }
                                }
                                returnResults.put("verified", verificationId != null && code != null);
                                returnResults.put("verificationId", verificationId);
                                returnResults.put("code", code);
                                returnResults.put("instantVerification", true);
                            } catch(JSONException e){
                                Crashlytics.logException(e);
                                callbackContext.error(e.getMessage());
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

                            String errorMsg = "unknown error verifying number";
                            errorMsg += " Error instance: " + e.getClass().getName();

                            if (e instanceof FirebaseAuthInvalidCredentialsException) {
                                // Invalid request
                                errorMsg = "Invalid phone number";
                            } else if (e instanceof FirebaseTooManyRequestsException) {
                                // The SMS quota for the project has been exceeded
                                errorMsg = "The SMS quota for the project has been exceeded";
                            }

                            Crashlytics.logException(e);
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
                                Crashlytics.logException(e);
                                callbackContext.error(e.getMessage());
                                return;
                            }
                            PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, returnResults);
                            pluginresult.setKeepCallback(true);
                            callbackContext.sendPluginResult(pluginresult);
                        }
                    };

                    PhoneAuthProvider.getInstance().verifyPhoneNumber(number, // Phone number to verify
                            timeOutDuration, // Timeout duration
                            TimeUnit.SECONDS, // Unit of timeout
                            cordova.getActivity(), // Activity (for callback binding)
                            mCallbacks); // OnVerificationStateChangedCallbacks
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private static String getPrivateField(PhoneAuthCredential credential, Field field) {
        try {
            field.setAccessible(true);
            return (String) field.get(credential);
        } catch (IllegalAccessException e) {
            return null;
        }
    }

    //
    // Firebase Performace
    //

    private HashMap<String, Trace> traces           = new HashMap<String, Trace>();
    private  HashMap<String, HttpMetric> httpTraces = new HashMap<String, HttpMetric>();


    private void isPerformanceEnabled(final CallbackContext callbackContext){
        FirebasePerformance fp = FirebasePerformance.getInstance();
        callbackContext.success( fp.isPerformanceCollectionEnabled() ? "true" : "false" );
    }

    private void enabeldPerformance(final CallbackContext callbackContext, Boolean enabled){
        FirebasePerformance.getInstance().setPerformanceCollectionEnabled( enabled );
        callbackContext.success();
    }

    private void startTrace(final CallbackContext callbackContext, final String name) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    FirebasePerformance fp = FirebasePerformance.getInstance();
                    if (!fp.isPerformanceCollectionEnabled()){
                        callbackContext.error("Firebase Performance is not enabled");
                    }


                    Trace myTrace = null;
                    if (self.traces.containsKey(name)) {
                        myTrace = self.traces.get(name);
                    }

                    if (myTrace == null) {
                        myTrace = fp.newTrace(name);
                        myTrace.start();
                        self.traces.put(name, myTrace);
                    }

                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void incrementMetric(final CallbackContext callbackContext, final String name, final String metricNamed){
        this.incrementMetric(callbackContext, name, metricNamed, 1);
    }

    private void incrementMetric(final CallbackContext callbackContext, final String name, final String metricNamed, final long incrementBy) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    Trace myTrace = null;
                    if (self.traces.containsKey(name)) {
                        myTrace = self.traces.get(name);
                    }

                    if (myTrace != null && myTrace instanceof Trace) {
                        myTrace.incrementMetric(metricNamed, incrementBy);
                        callbackContext.success();
                    } else {
                        callbackContext.error("Trace not found");
                    }
                } catch (Exception e) {
                    Crashlytics.logException(e);
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
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
                    Crashlytics.logException(e);
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void startTraceHTTP(final CallbackContext callbackContext, final String url, final String method, final long payloadSize){

        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    FirebasePerformance fp = FirebasePerformance.getInstance();
                    if (!fp.isPerformanceCollectionEnabled()){
                        callbackContext.error("Firebase Performance is not enabled");
                    }


                    HttpMetric myTrace = null;
                    String aMethod = null;

                    switch (method.toUpperCase()){
                        case "GET":
                            aMethod = FirebasePerformance.HttpMethod.GET;
                            break;
                        case "PUT":
                            aMethod = FirebasePerformance.HttpMethod.PUT;
                            break;
                        case "POST":
                            aMethod = FirebasePerformance.HttpMethod.POST;
                            break;
                        case "DELETE":
                            aMethod = FirebasePerformance.HttpMethod.DELETE;
                            break;
                        case "HEAD":
                            aMethod = FirebasePerformance.HttpMethod.HEAD;
                            break;
                        case "PATCH":
                            aMethod = FirebasePerformance.HttpMethod.PATCH;
                            break;
                        case "OPTIONS":
                            aMethod = FirebasePerformance.HttpMethod.OPTIONS;
                            break;
                        case "TRACE":
                            aMethod = FirebasePerformance.HttpMethod.TRACE;
                            break;
                        case "CONNECT":
                            aMethod = FirebasePerformance.HttpMethod.CONNECT;
                            break;
                    }

                    if ( aMethod == null){
                        callbackContext.error("The HTTP method is not compatible");
                        return;
                    }


                    myTrace = fp.newHttpMetric(url, aMethod);

                    if ( payloadSize > 0 )
                        myTrace.setRequestPayloadSize(payloadSize);

                    myTrace.start();

                    String traceName = myTrace.toString();
                    self.httpTraces.put(traceName, myTrace);

                    callbackContext.success(traceName);


                } catch (Exception e) {
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });

    }

    private void stopTraceHTTP(final CallbackContext callbackContext, final String traceId, final int responseCode, final String contentType, final long payLoadSize){
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {

                    HttpMetric myTrace = null;
                    if (self.httpTraces.containsKey(traceId)) {
                        myTrace = self.httpTraces.get(traceId);
                    }

                    if (myTrace != null) { //

                        myTrace.setResponseContentType(contentType);
                        myTrace.setResponsePayloadSize(payLoadSize);
                        myTrace.setHttpResponseCode(responseCode);
                        myTrace.stop();

                        self.httpTraces.remove(traceId);
                        callbackContext.success();

                    } else {
                        callbackContext.error("Trace not found");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }


    // End performace

    private void setAnalyticsCollectionEnabled(final CallbackContext callbackContext, final boolean enabled) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    mFirebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.log(e.getMessage());
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void setPerformanceCollectionEnabled(final CallbackContext callbackContext, final boolean enabled) {
        final FirebasePlugin self = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebasePerformance.getInstance().setPerformanceCollectionEnabled(enabled);
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.log(e.getMessage());
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    public void clearAllNotifications(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    Context context = cordova.getActivity();
                    NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                    nm.cancelAll();
                    callbackContext.success();
                } catch (Exception e) {
                    Crashlytics.log(e.getMessage());
                }
            }
        });
    }
}

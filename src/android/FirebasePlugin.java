package org.apache.cordova.firebase;

import android.content.Context;
import android.content.Intent;
import android.util.Base64;
import android.util.Log;
import android.os.Bundle;
import android.content.Context;
import android.content.SharedPreferences;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigInfo;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.messaging.FirebaseMessaging;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.ArrayList;

import me.leolin.shortcutbadger.ShortcutBadger;


public class FirebasePlugin extends CordovaPlugin {

    private FirebaseAnalytics mFirebaseAnalytics;
    private final String TAG = "FirebasePlugin";
    protected static final String KEY = "badge";

    private static boolean inBackground = true;
    private static ArrayList<Bundle> notificationStack = null;
    private static CallbackContext notificationCallbackContext;
    private static CallbackContext tokenRefreshCallbackContext;

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
        if (action.equals("getInstanceId")) {
            this.getInstanceId(callbackContext);
            return true;
        } else if (action.equals("getToken")) {
            this.getToken(callbackContext);
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
        } else if (action.equals("onNotificationOpen")) {
            this.onNotificationOpen(callbackContext);
            return true;
        } else if (action.equals("onTokenRefresh")) {
            this.onTokenRefresh(callbackContext);
            return true;
        } else if (action.equals("logEvent")) {
            this.logEvent(callbackContext, args.getString(0), args.getJSONObject(1));
            return true;
        } else if (action.equals("setUserId")) {
            this.setUserId (callbackContext, args.getString(0));
            return true;
        } else if (action.equals("setUserProperty")) {
            this.setUserProperty(callbackContext, args.getString(0), args.getString(1));
            return true;
        } else if (action.equals("activateFetched")) {
            this.activateFetched(callbackContext);
            return true;
        } else if (action.equals("fetch")) {
            if (args.length() > 0) this.fetch(callbackContext, args.getLong(0));
            else this.fetch(callbackContext);
            return true;
        } else if (action.equals("getByteArray")) {
            if (args.length() > 1) this.getByteArray(callbackContext, args.getString(0), args.getString(1));
            else this.getByteArray(callbackContext, args.getString(0), null);
            return true;
        } else if (action.equals("getValue")) {
            if (args.length() > 1) this.getValue(callbackContext, args.getString(0), args.getString(1));
            else this.getValue(callbackContext, args.getString(0), null);
            return true;
        } else if (action.equals("getInfo")) {
            this.getInfo(callbackContext);
            return true;
        } else if (action.equals("setConfigSettings")) {
            this.setConfigSettings(callbackContext, args.getJSONObject(0));
            return true;
        } else if (action.equals("setDefaults")) {
            if (args.length() > 1) this.setDefaults(callbackContext, args.getJSONObject(0), args.getString(1));
            else this.setDefaults(callbackContext, args.getJSONObject(0), null);
            return true;
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
    }

    private void onNotificationOpen(final CallbackContext callbackContext) {
        FirebasePlugin.notificationCallbackContext = callbackContext;
        if (FirebasePlugin.notificationStack != null) {
            for (Bundle bundle : FirebasePlugin.notificationStack) {
                FirebasePlugin.sendNotification(bundle);
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
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    public static void sendNotification(Bundle bundle) {
        if(!FirebasePlugin.hasNotificationsCallback()) {
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
        if(FirebasePlugin.tokenRefreshCallbackContext == null) {
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
        FirebasePlugin.sendNotification(intent.getExtras());
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

    private void getToken(final CallbackContext callbackContext) {
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
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void logEvent(final CallbackContext callbackContext, final String name, final JSONObject params) throws JSONException {
        final Bundle bundle = new Bundle();
        Iterator iter = params.keys();
        while(iter.hasNext()){
            String key = (String)iter.next();
            Object value = params.get(key);

            if (value instanceof Integer || value instanceof Double) {
                bundle.putFloat(key, ((Number)value).floatValue());
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
                    task.addOnCompleteListener(new OnCompleteListener<Void>() {
                        @Override
                        public void onComplete(Task<Void> task) {
                            callbackContext.success();
                        }
                    }).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(Exception e) {
                            callbackContext.error(e.getMessage());
                        }
                    });
                } catch (Exception e) {
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
                    callbackContext.error(e.getMessage());
                }
            }
        });
    }

    private void getValue(final CallbackContext callbackContext, final String key, final String namespace) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    FirebaseRemoteConfigValue value = namespace == null ? FirebaseRemoteConfig.getInstance().getValue(key)
                            : FirebaseRemoteConfig.getInstance().getValue(key, namespace);
                    callbackContext.success(value.asString());
                } catch (Exception e) {
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
}
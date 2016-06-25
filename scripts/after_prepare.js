#!/usr/bin/env node
'use strict';

var fs = require('fs');

var getPreferenceValue = function(config, name) {
    var value = config.match(new RegExp('name="' + name + '" value="(.*?)"', "i"))
    if(value && value[1]) {
        return value[1]
    } else {
        return null
    }
}

var getValue = function(config, name) {
    var value = config.match(new RegExp('<' + name + '>(.*?)</' + name + '>', "i"))
    if(value && value[1]) {
        return value[1]
    } else {
        return null
    }
}

var config = fs.readFileSync("config.xml").toString()
var name = getValue(config, "name")

//ios
try {
    var IOS_AD_UNIT_ID_FOR_BANNER_TEST = getPreferenceValue(config, "IOS_AD_UNIT_ID_FOR_BANNER_TEST")
    var IOS_AD_UNIT_ID_FOR_INTERSTITIAL_TEST = getPreferenceValue(config, "IOS_AD_UNIT_ID_FOR_INTERSTITIAL_TEST")
    var IOS_CLIENT_ID = getPreferenceValue(config, "IOS_CLIENT_ID")
    var IOS_REVERSED_CLIENT_ID = getPreferenceValue(config, "IOS_REVERSED_CLIENT_ID")
    var IOS_API_KEY = getPreferenceValue(config, "IOS_API_KEY")
    var IOS_GCM_SENDER_ID = getPreferenceValue(config, "IOS_GCM_SENDER_ID")
    var IOS_BUNDLE_ID = getPreferenceValue(config, "IOS_BUNDLE_ID")
    var IOS_PROJECT_ID = getPreferenceValue(config, "IOS_PROJECT_ID")
    var IOS_STORAGE_BUCKET = getPreferenceValue(config, "IOS_STORAGE_BUCKET")
    var IOS_IS_ADS_ENABLED = getPreferenceValue(config, "IOS_IS_ADS_ENABLED")
    var IOS_IS_ANALYTICS_ENABLED = getPreferenceValue(config, "IOS_IS_ANALYTICS_ENABLED")
    var IOS_IS_APPINVITE_ENABLED = getPreferenceValue(config, "IOS_IS_APPINVITE_ENABLED")
    var IOS_IS_GCM_ENABLED = getPreferenceValue(config, "IOS_IS_GCM_ENABLED")
    var IOS_IS_SIGNIN_ENABLED = getPreferenceValue(config, "IOS_IS_SIGNIN_ENABLED")
    var IOS_GOOGLE_APP_ID = getPreferenceValue(config, "IOS_GOOGLE_APP_ID")
    var IOS_DATABASE_URL = getPreferenceValue(config, "IOS_DATABASE_URL")

    var contents = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
"<plist version=\"1.0\">\n" +
"<dict>\n" +
"    <key>AD_UNIT_ID_FOR_BANNER_TEST</key>\n" +
"    <string>" + IOS_AD_UNIT_ID_FOR_BANNER_TEST + "</string>\n" +
"    <key>AD_UNIT_ID_FOR_INTERSTITIAL_TEST</key>\n" +
"    <string>" + IOS_AD_UNIT_ID_FOR_INTERSTITIAL_TEST + "</string>\n" +
"    <key>CLIENT_ID</key>\n" +
"    <string>" + IOS_CLIENT_ID + "</string>\n" +
"    <key>REVERSED_CLIENT_ID</key>\n" +
"    <string>" + IOS_REVERSED_CLIENT_ID + "</string>\n" +
"    <key>API_KEY</key>\n" +
"    <string>" + IOS_API_KEY + "</string>\n" +
"    <key>GCM_SENDER_ID</key>\n" +
"    <string>" + IOS_GCM_SENDER_ID + "</string>\n" +
"    <key>PLIST_VERSION</key>\n" +
"    <string>1</string>\n" +
"    <key>BUNDLE_ID</key>\n" +
"    <string>" + IOS_BUNDLE_ID + "</string>\n" +
"    <key>PROJECT_ID</key>\n" +
"    <string>" + IOS_PROJECT_ID + "</string>\n" +
"    <key>STORAGE_BUCKET</key>\n" +
"    <string>" + IOS_STORAGE_BUCKET + "</string>\n" +
"    <key>IS_ADS_ENABLED</key>\n" +
"    <" + IOS_IS_ADS_ENABLED + "/>\n" +
"    <key>IS_ANALYTICS_ENABLED</key>\n" +
"    <" + IOS_IS_ANALYTICS_ENABLED + "/>\n" +
"    <key>IS_APPINVITE_ENABLED</key>\n" +
"    <" + IOS_IS_APPINVITE_ENABLED + "/>\n" +
"    <key>IS_GCM_ENABLED</key>\n" +
"    <" + IOS_IS_GCM_ENABLED + "/>\n" +
"    <key>IS_SIGNIN_ENABLED</key>\n" +
"    <" + IOS_IS_SIGNIN_ENABLED + "/>\n" +
"    <key>GOOGLE_APP_ID</key>\n" +
"    <string>" + IOS_GOOGLE_APP_ID + "</string>\n" +
"    <key>DATABASE_URL</key>\n" +
"    <string>" + IOS_DATABASE_URL + "</string>\n" +
"</dict>\n" +
"</plist>\n"

    fs.writeFileSync("platforms/ios/" + name + "/Resources/GoogleService-Info.plist", contents)
} catch(err) {}

//android
try {
    var ANDROID_AD_UNIT_ID_FOR_BANNER_TEST = getPreferenceValue(config, "ANDROID_AD_UNIT_ID_FOR_BANNER_TEST")
    var ANDROID_AD_UNIT_ID_FOR_INTERSTITIAL_TEST = getPreferenceValue(config, "ANDROID_AD_UNIT_ID_FOR_INTERSTITIAL_TEST")
    var ANDROID_CLIENT_ID = getPreferenceValue(config, "ANDROID_CLIENT_ID")
    var ANDROID_REVERSED_CLIENT_ID = getPreferenceValue(config, "ANDROID_REVERSED_CLIENT_ID")
    var ANDROID_API_KEY = getPreferenceValue(config, "ANDROID_API_KEY")
    var ANDROID_GCM_SENDER_ID = getPreferenceValue(config, "ANDROID_GCM_SENDER_ID")
    var ANDROID_BUNDLE_ID = getPreferenceValue(config, "ANDROID_BUNDLE_ID")
    var ANDROID_PROJECT_ID = getPreferenceValue(config, "ANDROID_PROJECT_ID")
    var ANDROID_STORAGE_BUCKET = getPreferenceValue(config, "ANDROID_STORAGE_BUCKET")
    var ANDROID_IS_ADS_ENABLED = getPreferenceValue(config, "ANDROID_IS_ADS_ENABLED")
    var ANDROID_IS_ANALYTICS_ENABLED = getPreferenceValue(config, "ANDROID_IS_ANALYTICS_ENABLED")
    var ANDROID_IS_APPINVITE_ENABLED = getPreferenceValue(config, "ANDROID_IS_APPINVITE_ENABLED")
    var ANDROID_IS_GCM_ENABLED = getPreferenceValue(config, "ANDROID_IS_GCM_ENABLED")
    var ANDROID_IS_SIGNIN_ENABLED = getPreferenceValue(config, "ANDROID_IS_SIGNIN_ENABLED")
    var ANDROID_GOOGLE_APP_ID = getPreferenceValue(config, "ANDROID_GOOGLE_APP_ID")
    var ANDROID_DATABASE_URL = getPreferenceValue(config, "ANDROID_DATABASE_URL")

    var contents = {
      "project_info": {
        "project_number": String(ANDROID_GCM_SENDER_ID),
        "firebase_url": ANDROID_DATABASE_URL,
        "project_id": ANDROID_PROJECT_ID,
        "storage_bucket": ANDROID_STORAGE_BUCKET
      },
      "client": [
        {
          "client_info": {
            "mobilesdk_app_id": ANDROID_GOOGLE_APP_ID,
            "android_client_info": {
              "package_name": ANDROID_BUNDLE_ID
            }
          },
          "oauth_client": [
            {
              "client_id": ANDROID_REVERSED_CLIENT_ID,
              "client_type": 3
            }
          ],
          "api_key": [
            {
              "current_key": ANDROID_API_KEY
            }
          ],
          "services": {
            "analytics_service": {
              "status": ANDROID_IS_ANALYTICS_ENABLED ? 2 : 1
            },
            "appinvite_service": {
              "status": ANDROID_IS_APPINVITE_ENABLED ? 2 : 1,
              "other_platform_oauth_client": []
            },
            "ads_service": {
              "status": ANDROID_IS_ADS_ENABLED ? 2 : 1,
            }
          }
        }
      ],
      "configuration_version": "1"
    }
    fs.writeFileSync("platforms/android/google-services.json", JSON.stringify(contents))
} catch(err) {}

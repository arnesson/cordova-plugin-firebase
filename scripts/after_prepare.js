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
var AD_UNIT_ID_FOR_BANNER_TEST = getPreferenceValue(config, "AD_UNIT_ID_FOR_BANNER_TEST")
var AD_UNIT_ID_FOR_INTERSTITIAL_TEST = getPreferenceValue(config, "AD_UNIT_ID_FOR_INTERSTITIAL_TEST")
var CLIENT_ID = getPreferenceValue(config, "CLIENT_ID")
var REVERSED_CLIENT_ID = getPreferenceValue(config, "REVERSED_CLIENT_ID")
var API_KEY = getPreferenceValue(config, "API_KEY")
var GCM_SENDER_ID = getPreferenceValue(config, "GCM_SENDER_ID")
var BUNDLE_ID = getPreferenceValue(config, "BUNDLE_ID")
var PROJECT_ID = getPreferenceValue(config, "PROJECT_ID")
var STORAGE_BUCKET = getPreferenceValue(config, "STORAGE_BUCKET")
var IS_ADS_ENABLED = getPreferenceValue(config, "IS_ADS_ENABLED")
var IS_ANALYTICS_ENABLED = getPreferenceValue(config, "IS_ANALYTICS_ENABLED")
var IS_APPINVITE_ENABLED = getPreferenceValue(config, "IS_APPINVITE_ENABLED")
var IS_GCM_ENABLED = getPreferenceValue(config, "IS_GCM_ENABLED")
var IS_SIGNIN_ENABLED = getPreferenceValue(config, "IS_SIGNIN_ENABLED")
var GOOGLE_APP_ID = getPreferenceValue(config, "GOOGLE_APP_ID")
var DATABASE_URL = getPreferenceValue(config, "DATABASE_URL")

try {
    var contents = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
"<plist version=\"1.0\">\n" +
"<dict>\n" +
"    <key>AD_UNIT_ID_FOR_BANNER_TEST</key>\n" +
"    <string>" + AD_UNIT_ID_FOR_BANNER_TEST + "</string>\n" +
"    <key>AD_UNIT_ID_FOR_INTERSTITIAL_TEST</key>\n" +
"    <string>" + AD_UNIT_ID_FOR_INTERSTITIAL_TEST + "</string>\n" +
"    <key>CLIENT_ID</key>\n" +
"    <string>" + CLIENT_ID + "</string>\n" +
"    <key>REVERSED_CLIENT_ID</key>\n" +
"    <string>" + REVERSED_CLIENT_ID + "</string>\n" +
"    <key>API_KEY</key>\n" +
"    <string>" + API_KEY + "</string>\n" +
"    <key>GCM_SENDER_ID</key>\n" +
"    <string>" + GCM_SENDER_ID + "</string>\n" +
"    <key>PLIST_VERSION</key>\n" +
"    <string>1</string>\n" +
"    <key>BUNDLE_ID</key>\n" +
"    <string>" + BUNDLE_ID + "</string>\n" +
"    <key>PROJECT_ID</key>\n" +
"    <string>" + PROJECT_ID + "</string>\n" +
"    <key>STORAGE_BUCKET</key>\n" +
"    <string>" + STORAGE_BUCKET + "</string>\n" +
"    <key>IS_ADS_ENABLED</key>\n" +
"    <" + IS_ADS_ENABLED + "/>\n" +
"    <key>IS_ANALYTICS_ENABLED</key>\n" +
"    <" + IS_ANALYTICS_ENABLED + "/>\n" +
"    <key>IS_APPINVITE_ENABLED</key>\n" +
"    <" + IS_APPINVITE_ENABLED + "/>\n" +
"    <key>IS_GCM_ENABLED</key>\n" +
"    <" + IS_GCM_ENABLED + "/>\n" +
"    <key>IS_SIGNIN_ENABLED</key>\n" +
"    <" + IS_SIGNIN_ENABLED + "/>\n" +
"    <key>GOOGLE_APP_ID</key>\n" +
"    <string>" + GOOGLE_APP_ID + "</string>\n" +
"    <key>DATABASE_URL</key>\n" +
"    <string>" + DATABASE_URL + "</string>\n" +
"</dict>\n" +
"</plist>\n"

    fs.writeFileSync("platforms/ios/" + name + "/GoogleService-Info.plist", contents)
} catch(err) {}

try {
    var contents = {
      "project_info": {
        "project_number": String(GCM_SENDER_ID),
        "firebase_url": DATABASE_URL,
        "project_id": PROJECT_ID,
        "storage_bucket": STORAGE_BUCKET
      },
      "client": [
        {
          "client_info": {
            "mobilesdk_app_id": GOOGLE_APP_ID,
            "android_client_info": {
              "package_name": BUNDLE_ID
            }
          },
          "oauth_client": [
            {
              "client_id": REVERSED_CLIENT_ID,
              "client_type": 3
            }
          ],
          "api_key": [
            {
              "current_key": API_KEY
            }
          ],
          "services": {
            "analytics_service": {
              "status": IS_ANALYTICS_ENABLED ? 2 : 1
            },
            "appinvite_service": {
              "status": IS_APPINVITE_ENABLED ? 2 : 1,
              "other_platform_oauth_client": []
            },
            "ads_service": {
              "status": IS_ADS_ENABLED ? 2 : 1,
            }
          }
        }
      ],
      "configuration_version": "1"
    }
    fs.writeFileSync("platforms/android/google-services.json", JSON.stringify(contents))
} catch(err) {}

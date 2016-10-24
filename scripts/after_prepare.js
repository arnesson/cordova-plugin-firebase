#!/usr/bin/env node
'use strict';

var fs = require('fs');
var path = require('path');

var getValue = function(config, name) {
    var value = config.match(new RegExp('<' + name + '>(.*?)</' + name + '>', "i"))
    if(value && value[1]) {
        return value[1]
    } else {
        return null
    }
}

function fileExists(path) {
  try  {
    return fs.statSync(path).isFile();
  }
  catch (e) {
    return false;
  }
}

function directoryExists(path) {
  try  {
    return fs.statSync(path).isDirectory();
  }
  catch (e) {
    return false;
  }
}

var config = fs.readFileSync("config.xml").toString()
var name = getValue(config, "name")

if (directoryExists("platforms/ios")) {
  var paths = ["GoogleService-Info.plist", "platforms/ios/www/GoogleService-Info.plist"];

  for (var i = 0; i < paths.length; i++) {
    if (fileExists(paths[i])) {
      try {
        var contents = fs.readFileSync(paths[i]).toString();
        fs.writeFileSync("platforms/ios/" + name + "/Resources/GoogleService-Info.plist", contents)
      } catch(err) {
        process.stdout.write(err);
      }

      break;
    }
  }
}

if (directoryExists("platforms/android")) {
  var paths = ["google-services.json", "platforms/android/assets/www/google-services.json"];

  for (var i = 0; i < paths.length; i++) {
    if (fileExists(paths[i])) {
      try {
        var contents = fs.readFileSync(paths[i]).toString();
        fs.writeFileSync("platforms/android/google-services.json", contents);

        var json = JSON.parse(contents);
        var strings = fs.readFileSync("platforms/android/res/values/strings.xml").toString();

        // strip non-default value
        strings = strings.replace(new RegExp('<string name="google_app_id">([^\@<]+?)</string>', "i"), '')

        // strip non-default value
        strings = strings.replace(new RegExp('<string name="google_api_key">([^\@<]+?)</string>', "i"), '')

        // strip empty lines
        strings = strings.replace(new RegExp('(\r\n|\n|\r)[ \t]*(\r\n|\n|\r)', "gm"), '$1')

        // replace the default value
        strings = strings.replace(new RegExp('<string name="google_app_id">([^<]+?)</string>', "i"), '<string name="google_app_id">' + json.client[0].client_info.mobilesdk_app_id + '</string>')

        // replace the default value
        strings = strings.replace(new RegExp('<string name="google_api_key">([^<]+?)</string>', "i"), '<string name="google_api_key">' + json.client[0].api_key[0].current_key + '</string>')

        fs.writeFileSync("platforms/android/res/values/strings.xml", strings);
      } catch(err) {
        process.stdout.write(err);
      }

      break;
    }
  }

  if (directoryExists('resources/android/notification_icon')) {
      copyNotificationIcons();
  }
}

function copyNotificationIcons() {
    var filestocopy = [{
        "resources/android/notification_icon/res/drawable-hdpi-v11/notification_icon.png": "platforms/android/res/drawable-hdpi/notification_icon.png"
    }, {
        "resources/android/notification_icon/res/drawable-xhdpi-v11/notification_icon.png": "platforms/android/res/drawable-xhdpi/notification_icon.png"
    }, {
        "resources/android/notification_icon/res/drawable-xxhdpi-v11/notification_icon.png": "platforms/android/res/drawable-xxhdpi/notification_icon.png"
    }, {
        "resources/android/notification_icon/res/drawable-xxxhdpi-v11/notification_icon.png": "platforms/android/res/drawable-xxxhdpi/notification_icon.png"
    }, {
        "resources/android/notification_icon/res/drawable-mdpi-v11/notification_icon.png": "platforms/android/res/drawable-mdpi/notification_icon.png"
    }];

    filestocopy.forEach(function(obj) {
        Object.keys(obj).forEach(function(key) {
            var val = obj[key];
            var destdir = path.dirname(val);
            if (fs.existsSync(key) && fs.existsSync(destdir)) {
                fs.createReadStream(key).pipe(
                    fs.createWriteStream(val));
            }
        });
    });
}

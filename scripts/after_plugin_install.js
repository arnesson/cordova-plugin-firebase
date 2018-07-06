#!/usr/bin/env node
'use strict';

var fs = require('fs');

fs.unlinkSync('./plugins/cordova-plugin-firebase/src/ios/GoogleService-Info.plist');

fs.writeFileSync('./plugins/cordova-plugin-firebase/src/ios/GoogleService-Info.plist', fs.readFileSync('./GoogleService-Info.plist'));

module.exports = function (context) {
  require('./after_prepare')(context);
};

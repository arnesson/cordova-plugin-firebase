#!/usr/bin/env node
'use strict';

var fs = require('fs');

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

try {
    fs.writeFileSync("platforms/ios/" + name + "/Resources/GoogleService-Info.plist", fs.readFileSync("GoogleService-Info.plist"))
} catch(err) {}

try {
    fs.writeFileSync("platforms/android/google-services.json", fs.readFileSync("google-services.json"))
} catch(err) {}

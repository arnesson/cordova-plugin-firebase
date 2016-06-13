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

try {
	var contents = fs.readFileSync("ios/GoogleService-Info.plist").toString()
    fs.writeFileSync("platforms/ios/" + name + "/GoogleService-Info.plist", contents)
} catch(err) {}

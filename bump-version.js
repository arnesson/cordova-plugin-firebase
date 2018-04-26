#!/usr/bin/env node

var fs = require('fs');
const version = require('./package.json').version;

let data = fs.readFileSync('./plugin.xml', "utf8");
console.log(data);
data = data.replace(/plugin id="cordova-plugin-firebase" version="[^"]+"/, `plugin id="cordova-plugin-firebase" version="${version}"`);
console.log(data);
fs.writeFileSync('./plugin.xml', data);

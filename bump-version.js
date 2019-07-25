#!/usr/bin/env node

const fs = require('fs');
const version = require('./package.json').version;

let data = fs.readFileSync('./plugin.xml', "utf8");
data = data.replace(/plugin id="cordova-plugin-firebase-lib" version="[^"]+"/, `plugin id="cordova-plugin-firebase-lib" version="${version}"`);
fs.writeFileSync('./plugin.xml', data);

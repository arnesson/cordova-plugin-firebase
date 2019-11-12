/**
 * Utilities and shared functionality for the build hooks.
 */
var fs = require('fs');
var path = require("path");
var parser = require('xml-js');

var _configXml, _pluginXml;

var Utilities = {};

fs.ensureDirSync = function(dir){
    if(!fs.existsSync(dir)){
        dir.split(path.sep).reduce(function(currentPath, folder){
            currentPath += folder + path.sep;
            if(!fs.existsSync(currentPath)){
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
};

Utilities.parsePackageJson = function(){
    return JSON.parse(fs.readFileSync('./package.json'));
};

Utilities.parseConfigXml = function(){
    if(_configXml) return _configXml;
    _configXml = Utilities.parseXmlFileToJson("config.xml");
    return _configXml;
};

Utilities.parsePluginXml = function(){
    if(_pluginXml) return _pluginXml;
    _pluginXml = Utilities.parseXmlFileToJson("plugins/"+Utilities.getPluginId()+"/plugin.xml");
    return _pluginXml;
};

Utilities.parseXmlFileToJson = function(filepath, parseOpts){
    parseOpts = parseOpts || {compact: true};
    return JSON.parse(parser.xml2json(fs.readFileSync(filepath, 'utf-8'), parseOpts));
};

Utilities.writeJsonToXmlFile = function(jsonObj, filepath, parseOpts){
    parseOpts = parseOpts || {compact: true, spaces: 4};
    var xmlStr = parser.json2xml(JSON.stringify(jsonObj), parseOpts);
    fs.writeFileSync(filepath, xmlStr);
};

/**
 * Used to get the name of the application as defined in the config.xml.
 */
Utilities.getAppName = function(){
    return Utilities.parseConfigXml().widget.name._text.toString().trim();
};

/**
 * The ID of the plugin; this should match the ID in plugin.xml.
 */
Utilities.getPluginId = function(){
    return "cordova-plugin-firebasex";
};

Utilities.copyKey = function(platform){
    for(var i = 0; i < platform.src.length; i++){
        var file = platform.src[i];
        if(this.fileExists(file)){
            try{
                var contents = fs.readFileSync(file).toString();

                try{
                    var destinationPath = platform.dest;
                    var folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                    fs.ensureDirSync(folder);
                    fs.writeFileSync(destinationPath, contents);
                }catch(e){
                    // skip
                }
            }catch(err){
                console.log(err);
            }

            break;
        }
    }
};

Utilities.fileExists = function(path){
    try{
        return fs.statSync(path).isFile();
    }catch(e){
        return false;
    }
};

Utilities.directoryExists = function(path){
    try{
        return fs.statSync(path).isDirectory();
    }catch(e){
        return false;
    }
};

Utilities.log = function(msg){
    console.log(Utilities.getPluginId()+': '+msg);
};

module.exports = Utilities;

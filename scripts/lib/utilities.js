/**
 * Utilities and shared functionality for the build hooks.
 */
var fs = require('fs');
var path = require("path");
var parser = require('xml-js');

var _configXml, _pluginXml, _context, _pluginVariables;

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

Utilities.setContext = function(context){
    _context = context;
};

Utilities.parsePackageJson = function(){
    return JSON.parse(fs.readFileSync(path.resolve('./package.json')));
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
    return JSON.parse(parser.xml2json(fs.readFileSync(path.resolve(filepath), 'utf-8'), parseOpts));
};

Utilities.writeJsonToXmlFile = function(jsonObj, filepath, parseOpts){
    parseOpts = parseOpts || {compact: true, spaces: 4};
    var xmlStr = parser.json2xml(JSON.stringify(jsonObj), parseOpts);
    fs.writeFileSync(path.resolve(filepath), xmlStr);
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
    // if(!_context) throw "Cannot retrieve plugin ID as hook context is not set";
    return _context.opts.plugin.id;
};

Utilities.parsePluginVariables = function(){
    if(_pluginVariables) return _pluginVariables;

    var pluginVariables = {};

    // Parse plugin.xml
    var plugin = Utilities.parsePluginXml();
    var prefs = [];
    if(plugin.plugin.preference){
        prefs = prefs.concat(plugin.plugin.preference);
    }
    if(typeof plugin.plugin.platform.length === 'undefined') plugin.plugin.platform = [plugin.plugin.platform];
    plugin.plugin.platform.forEach(function(platform){
        if(platform.preference){
            prefs = prefs.concat(platform.preference);
        }
    });
    prefs.forEach(function(pref){
        if (pref._attributes){
            pluginVariables[pref._attributes.name] = pref._attributes.default;
        }
    });

    // Parse config.xml
    var config = Utilities.parseConfigXml();
    (config.widget.plugin ? [].concat(config.widget.plugin) : []).forEach(function(plugin){
        (plugin.variable ? [].concat(plugin.variable) : []).forEach(function(variable){
            if((plugin._attributes.name === Utilities.getPluginId() || plugin._attributes.id === Utilities.getPluginId()) && variable._attributes.name && variable._attributes.value){
                pluginVariables[variable._attributes.name] = variable._attributes.value;
            }
        });
    });

    // Parse package.json
    var packageJSON = Utilities.parsePackageJson();
    if(packageJSON.cordova && packageJSON.cordova.plugins){
        for(const pluginId in packageJSON.cordova.plugins){
            if(pluginId === Utilities.getPluginId()){
                for(const varName in packageJSON.cordova.plugins[pluginId]){
                    var varValue = packageJSON.cordova.plugins[pluginId][varName];
                    pluginVariables[varName] = varValue;
                }
            }
        }
    }

    _pluginVariables = pluginVariables;
    return pluginVariables;
};

Utilities.copyKey = function(platform){
    for(var i = 0; i < platform.src.length; i++){
        var file = platform.src[i];
        if(this.fileExists(file)){
            try{
                var contents = fs.readFileSync(path.resolve(file)).toString();

                try{
                    var destinationPath = platform.dest;
                    var folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                    fs.ensureDirSync(folder);
                    fs.writeFileSync(path.resolve(destinationPath), contents);
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

Utilities.fileExists = function(filePath){
    try{
        return fs.statSync(path.resolve(filePath)).isFile();
    }catch(e){
        return false;
    }
};

Utilities.directoryExists = function(dirPath){
    try{
        return fs.statSync(path.resolve(dirPath)).isDirectory();
    }catch(e){
        return false;
    }
};

Utilities.log = function(msg){
    console.log(Utilities.getPluginId()+': '+msg);
};

module.exports = Utilities;

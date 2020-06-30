var execSync = require('child_process').execSync;
var semver = require('semver');

var minCocoapodsVersion = "^1.9.0";

module.exports = function(context) {
    checkCocoapodsVersion();
};

function checkCocoapodsVersion(){
    var stdout;
    try{
        stdout = execSync('pod --version', {encoding: 'utf8'}).trim();
    }catch(err){
        throw new Error("cocoapods not found - please install cocoapods >="+minCocoapodsVersion);
    }

    if(!semver.valid(stdout)){
        throw new Error("cocoapods version is invalid - please reinstall cocoapods@"+minCocoapodsVersion + ": "+stdout);
    }else if(!semver.satisfies(stdout, minCocoapodsVersion)){
        throw new Error("cocoapods version is out-of-date - please update to cocoapods@"+minCocoapodsVersion + " - current version: "+stdout);
    }
}
var fs          = require("fs");
var path        = require("path");
var parseString = require("xml2js").parseString;

var buildGradleFile = path.join("platforms", "android", "app", "build.gradle");

function rootBuildGradleExists() {
	return fs.existsSync(buildGradleFile);
}

/*
 * Helper function to read the build.gradle that sits at the root of the project
 */
function readRootBuildGradle() {
	return fs.readFileSync(buildGradleFile, "utf-8");
}

/*
 * Added a dependency on 'com.google.gms' based on the position of the know 'com.android.tools.build' dependency in the build.gradle
 */
function addDependencies(buildGradle, useDependency) {
	if ( !useDependency[0] || buildGradle.indexOf('classpath \'com.google.gms:google-services:') > -1 )
		return buildGradle;
	// find the known line to match
	var match      = buildGradle.match(/^(\s*)classpath 'com.android.tools.build(.*)/m);
	var whitespace = match[1];

	var modifiedLine = '';
	var comment = '';
	useDependency.forEach(function(dependency){
		comment = '// dependency from cordova-plugin-firebase';
		if ( dependency.indexOf('com.android.tools.build:gradle') > -1 )
			comment = '';
		modifiedLine += whitespace + 'classpath \'' + dependency + '\' '+comment+'\n';
	});

	modifiedLine = modifiedLine.substr(0, modifiedLine.length-1 );

	// modify the actual line
	return buildGradle.replace(/^(\s*)classpath 'com.android.tools.build(.*)/m, modifiedLine);
}

/*
 * Add 'google()' and Crashlytics to the repository repo list
 */
function addRepos(buildGradle) {
	// find the known line to match
	var match = buildGradle.match(/^(\s*)jcenter\(\)/m);
	var whitespace = match[1];

	// modify the line to add the necessary repo
	// Crashlytics goes under buildscripts which is the first grouping in the file

	if ( buildGradle.indexOf('Fabrics Maven repository from cordova-plugin-firebase') == -1 ){
		var fabricMavenRepo = whitespace + 'maven { url \'https://maven.fabric.io/public\' } // Fabrics Maven repository from cordova-plugin-firebase'
		var modifiedLine = fabricMavenRepo + '\n' + match[0];
		// modify the actual line
		buildGradle = buildGradle.replace(/^(\s*)jcenter\(\)/m, modifiedLine);
	}

	if ( buildGradle.indexOf('Google\'s Maven repository from cordova-plugin-firebase') > -1 )
		return buildGradle;

	// update the all projects grouping
	var allProjectsIndex = buildGradle.indexOf('allprojects');
	if (allProjectsIndex > 0) {
		// split the string on allprojects because jcenter is in both groups and we need to modify the 2nd instance
		var firstHalfOfFile = buildGradle.substring(0, allProjectsIndex);
		var secondHalfOfFile = buildGradle.substring(allProjectsIndex);

		// Add google() to the allprojects section of the string
		match = secondHalfOfFile.match(/^(\s*)jcenter\(\)/m);
		var googlesMavenRepo = whitespace + 'google() // Google\'s Maven repository from cordova-plugin-firebase';
		modifiedLine =  googlesMavenRepo + '\n' + match[0];
		// modify the part of the string that is after 'allprojects'
		secondHalfOfFile = secondHalfOfFile.replace(/^(\s*)jcenter\(\)/m, modifiedLine);

		// recombine the modified line
		buildGradle = firstHalfOfFile + secondHalfOfFile;
	} else {
		// this should not happen, but if it does, we should try to add the dependency to the buildscript
		match = buildGradle.match(/^(\s*)jcenter\(\)/m);
		var googlesMavenRepo = whitespace + 'google() // Google\'s Maven repository from cordova-plugin-firebase';
		modifiedLine = googlesMavenRepo + '\n' + match[0];
		// modify the part of the string that is after 'allprojects'
		buildGradle = buildGradle.replace(/^(\s*)jcenter\(\)/m, modifiedLine);
	}

	return buildGradle;
}

/*
 * Add the frameworks
 */
function addFrameworks(buildGradle, useFrameworks){

	// Remove Firebase's frameworks
	buildGradle = buildGradle.replace(/ *\/\/ FIREBASE FRAMEWORKS START[^)]*FIREBASE FRAMEWORKS END */g, '');

	var match      = buildGradle.match(/^(\s*)\/\/ SUB-PROJECT DEPENDENCIES END(.*)/m);
	var whitespace = match[1];

	var index1 = buildGradle.search(whitespace+"\/\/ SUB-PROJECT DEPENDENCIES END");
	var index2 = buildGradle.search(/}*def promptForReleaseKeyPassword()/);

	buildGradle = buildGradle.substring(0, index1) + "==STR_REPLACE==\n}\n\n"+buildGradle.substring(index2,buildGradle.length);

		var lines = whitespace+'\/\/ SUB-PROJECT DEPENDENCIES END'
			+'\n'
		+'\n'+whitespace+'\/\/ FIREBASE FRAMEWORKS START'
		+'\n'+whitespace+'implementation \'me.leolin:ShortcutBadger:1.1.4@aar\'';

	useFrameworks.forEach(function(framework){
		lines += '\n'+whitespace+'implementation \''+ framework +'\'';
	});

	lines += '\n'+whitespace+'\/\/ FIREBASE FRAMEWORKS END';

	return buildGradle.replace(/==STR_REPLACE==/i, lines);
	// return buildGradle.replace(/^(\s*)\/\/ SUB-PROJECT DEPENDENCIES END(.*)/m, lines);
}

/*
 * Helper function to write to the build.gradle that sits at the root of the project
 */
function writeRootBuildGradle(contents) {
	fs.writeFileSync(buildGradleFile, contents);
}

/*
 * Load Android Frameworks
 */
function loadAndroidDependencyAndFrameworks(context, callback){
	var useFrameworks = [];
	var useDependency  = [];
	var pluginXML     = fs.readFileSync(context.opts.plugin.pluginInfo.filepath,{encoding: 'utf8'});
	var configXML     = null;
	try{
		configXML = fs.readFileSync(path.join(context.opts.projectRoot,'config.xml'),{encoding: 'utf8'});
	}catch(e){
		var configXML     = null;
	}
	readConfigXML(pluginXML, function(pluginDependency, pluginFrameworks){
		// console.log(pluginFrameworks);
		readConfigXML(configXML, function(configDependency, configFrameworks){
			// console.log(configFrameworks);
			// the framework written in config xml takes precedence
			pluginFrameworks.forEach(function(framework){
				if ( typeof framework == 'string' ){
					var fname = framework.split(/:|@/);
					fname     = fname[0] + ( typeof fname[1] == 'string' ?  ":" + fname[1] : "");
					useFrameworks.push( configFrameworks.find(function(element){ return element.indexOf(fname) > -1 }) || framework) ;
				}
			});

			pluginDependency.forEach(function(dependecy){
				if ( typeof dependecy == 'string' ){
					var fname = dependecy.split(/:|@/);
					fname     = fname[0] + ( typeof fname[1] == 'string' ?  ":" + fname[1] : "");
					useDependency.push( configDependency.find(function(element){ return element.indexOf(fname) > -1 }) || dependecy) ;
				}
			});

			// DONE
			callback(useDependency, useFrameworks);
		});
	});
}


/*
 * Reads the specifications for the frameworks
 */
function readConfigXML(xml, callback){
	parseString(xml, function (err, result) {
		var frameworks = [];
		var dependency  = [];
		var platforms  = [];
		if ( result && result.plugin && result.plugin.platform){
			platforms = result.plugin.platform;
		}else if ( result && result.widget && result.widget.platform ){
			platforms = result.widget.platform;
		}

		var platform;
		platforms.forEach(function(anPlatform){
			if ( anPlatform && anPlatform.$ && anPlatform.$.name == 'android'){
				platform = anPlatform;
			}
		});

		if (platform && platform["framework-implementation"] && platform["framework-implementation"].length > 0 ){
			platform["framework-implementation"].forEach(function(framework){
				if ( framework && framework.$ && framework.$.name){
					frameworks.push(framework.$.name);
				}
			});
		}
		if (platform && platform["dependency-classpath"] && platform["dependency-classpath"].length > 0 ){
			platform["dependency-classpath"].forEach(function(d){
				if ( d && d.$ && d.$.name){
					dependency.push(d.$.name);
				}
			});
		}

		callback(dependency, frameworks);
	});
}

module.exports = {

	modifyRootBuildGradle: function(context) {
		// be defensive and don't crash if the file doesn't exist
		if (!rootBuildGradleExists) {
			return;
		}

		loadAndroidDependencyAndFrameworks(context, function(useDependency, useFrameworks){
			var buildGradle = readRootBuildGradle();

			// Add Google Play Services Dependency
			buildGradle = addDependencies(buildGradle, useDependency);

			// Add Google's Maven Repo
			buildGradle = addRepos(buildGradle);

			//  Append plugins
			var firebasePlugins =
				'apply plugin: \'com.android.application\'\n'+
				'apply plugin: \'com.google.gms.google-services\' // from cordova-plugin-firebase\n'+
				'apply plugin: \'io.fabric\' // from cordova-plugin-firebase\n'+
				'apply plugin: \'com.google.firebase.firebase-perf\' // from cordova-plugin-firebase\n';

			buildGradle = buildGradle.replace(/apply plugin: \'com.android.application\'\n/m, firebasePlugins);

			// Add framework dependecy
			buildGradle = addFrameworks(buildGradle, useFrameworks);

			writeRootBuildGradle(buildGradle);
		});


	},

  restoreRootBuildGradle: function(context) {
	// be defensive and don't crash if the file doesn't exist
    if (!rootBuildGradleExists) {
      return;
    }


    var buildGradle = readRootBuildGradle();

	// Remove Firebase's frameworks
	buildGradle = buildGradle.replace(/ *\/\/ FIREBASE FRAMEWORKS START[^)]*FIREBASE FRAMEWORKS END */g, '');

    // remove any lines we added
    buildGradle = buildGradle.replace(/(?:^|\r?\n)(.*)cordova-plugin-firebase*?(?=$|\r?\n)/g, '');

    writeRootBuildGradle(buildGradle);
  }
};

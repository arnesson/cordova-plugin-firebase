cordova.define("cordova-plugin-firebase.firebase", function(require, exports, module) {
	var exec = require('cordova/exec');

	exports.coolMethod = function(arg0, success, error) {
	    exec(success, error, "FirebasePlugin", "coolMethod", [arg0]);
	};
});

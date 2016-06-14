cordova.define("cordova-plugin-firebase.FirebasePlugin", function(require, exports, module) {
	var exec = require('cordova/exec');

	exports.getRegistrationId = function(success, error) {
	    exec(success, error, "FirebasePlugin", "getRegistrationId", []);
	};
});

rm -rf .test

cordova create .test com.example.hello HelloWorld

cd .test

cordova platform add ios
cordova platform add android

cordova plugin add ..

cordova prepare

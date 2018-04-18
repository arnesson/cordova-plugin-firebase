rm -rf .build-ios

./node_modules/.bin/cordova create .build-ios com.example.hello HelloWorld

cd .build-ios

../node_modules/.bin/cordova platform add ios@4.5.4

../node_modules/.bin/cordova plugin add ..

../node_modules/.bin/cordova build ios

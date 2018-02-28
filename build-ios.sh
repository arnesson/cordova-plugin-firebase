rm -rf .build-ios

cordova create .build-ios com.example.hello HelloWorld

cd .build-ios

cordova platform add ios

cordova plugin add ..

cordova build ios

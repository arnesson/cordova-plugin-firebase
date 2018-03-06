rm -rf .build-android

cordova create .build-android com.example.hello HelloWorld

cd .build-android

cordova platform add android

cordova plugin add ..

cordova build android

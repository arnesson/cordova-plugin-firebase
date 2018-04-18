rm -rf .build-browser

./node_modules/.bin/cordova create .build-browser com.example.hello HelloWorld

cd .build-browser

../node_modules/.bin/cordova platform add browser@5.0.3

../node_modules/.bin/cordova plugin add ..

../node_modules/.bin/cordova build browser

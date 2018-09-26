# Contribution Guidelines

# Find a bug?

No one is perfect and we aren't any different.  If you find an issue, please take a few minutes to let us know.  

1. Take a look at the current issues (there's a handy search feature) to see if someone already reported the issue.  If they have, there might be work arounds or proposed fixes posted in the issue which could save you time.
2. If the issue have not been reported, please open an issue.
3. Look for questions or updates to your issue as we might need additioanl information.  The faster we get the information, the faster we can resolve your issue.
4. The fastest way to fix your issue is to fix the bug yourself.  See the "Have a fix or want to get your hands dirty?" section below to find out how to show off your awesome developer skills!

## Help Wanted flag

This plugin is maintained by a community of developers.  We do this in our spare time and don't have unlimited time to implement features or fix bugs.  As such, we look to others who can submit pull requests to fix bugs or make enhancements.

# Have a fix or want to get your hands dirty?

It's really not that hard!  If you have questions please don't hesitate to ask in an issue as we can try to help point you in the right direction. 

## Where is the code?

### Javascript APIs

You can find the Javscipt APIs in [firebase.js](www/firebase.js) file. This file typically redirects calls to the FirebasePlugin implementation for the platform, but if you need to add APIs, this is where you do it.

### Android

There are a number of files that make up the Android platform code, but the main file is [Firebase.java](src/android/FirebasePlugin.java).  That is the best place to start.

### iOS

Again, there are multiple files that make up the iOS platform, but most of the code is split between [FirebasePlugin.m](src/ios/FirebasePlugin.m) and [AppDelegate+FirebasePlugin.m](src/ios/AppDelegate+FirebasePlugin.m).

## I found the code, but now what?

Submitting a bug fix or feature takes only a few minutes.

1. Fork the repository.
2. Create a new branch.
3. Make the code change.
4. Create a commit and push it to your repo.
5. See the Pull Request section to let us know your code is ready to be merged into the main repo.

MAKE SURE THE CODE WORKS WITHOUT MODIFYING OR CHECKING IN ANY PLATFORM FILES.  Any changes to platform files (like build scripts, config files or anything in the /platform directory) should be made by the plugin.  Since Cordova 4.3.0, the [platform management feature](https://cordova.apache.org/docs/en/latest/platform_plugin_versioning_ref/) allows you to build your project without checking in any platform files.  

# Pull Requests

* Fill in [the required template](PULL_REQUEST_TEMPLATE.md)
* Include one feature/bug fix per Pull Request.  Multiple issues in one PR can increase the complexity of the review and could delay the merging of your code.
* Maintain the formatting (specifically white spacing) in the files you are modifying
* Reference the Issue number in the PR if there's a related issue
* If you are adding new APIs or changing behavior, include entries in the README.md so new users know how to interact with the new features.  We want everyone to use your work!

## Need to test a PR?
We rely on the community to help test out fixes and enhancements to this plugin. You can test out a PR by running the following commands:
1. `cordova plugin remove cordova-plugin-firebase`
2. `cordova plugin add https://github.com/<username>/cordova-plugin-firebase.git#<branch>`
   * replace `<username>` with the name of user/org where the branch resides
   * replace `<branch>` with the name of the branch used to create the PR
3. `cordova prepare`

For example, to test the fix made by PR [#832](https://github.com/arnesson/cordova-plugin-firebase/pull/832#issuecomment-420386486), you would use the url `https://github.com/briantq/cordova-plugin-firebase.git#revert-lazy-init` since `briantq` is the name of the user and `revert-lazy-init` is the name of the branch.  This information is available at the top of each PR.  For this specific PR, the following information is displayed:
* briantq wants to merge 2 commits into arnesson:master from briantq:revert-lazy-init

The last part being the vital information as it tells you exactly what to use in the url.

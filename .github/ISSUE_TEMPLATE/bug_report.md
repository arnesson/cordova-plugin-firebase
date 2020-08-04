---
name: Bug report
about: Report a problem
title: ''
labels: ''
assignees: ''

---

<!--
IMPORTANT: PLEASE READ

WARNING: Failure to follow the issue template guidelines below will result in the issue being immediately closed.
-->

<!-- Fill out the relevant sections below and delete irrelevant sections. -->

# Bug report

<!-- COMPLETE THIS CHECKLIST -->
**CHECKLIST**
- [ ] I have read the [issue reporting guidelines](https://github.com/dpa99c/cordova-plugin-firebasex#reporting-issues)

- [ ] I confirm this is a suspected bug or issue that will affect other users
<!-- i.e. this is not a request for support in using/integrating the plugin into your specific project -->

- [ ] I have reproduced the issue using the [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test) or provided the necessary information to reproduce the issue.
<!-- necessary information e.g. exact steps, FCM notification message content, test case project repo -->

- [ ] I have read [the documentation](https://github.com/dpa99c/cordova-plugin-firebasex) thoroughly and it does not help solve my issue.
<!-- e.g. if you're having a build issue ensure you've read through the build environment notes -->

- [ ] I have checked that no similar issues (open or closed) already exist.
<!-- Duplicates or near-duplicates will be closed immediately. -->



**Current behavior:**

<!-- Describe how the bug manifests. -->

<!-- Explain how you're sure there is an issue with this plugin rather than your own code:
 - If this plugin has an example project, have you been able to reproduce the issue within it?
 - Have you created a clean test Cordova project containing only this plugin to eliminate the potential for interference with other plugins/code?
 -->

**Expected behavior:**
<!-- Describe what the behavior should be without the bug. -->

**Steps to reproduce:**
<!-- If you are able to illustrate the bug with an example, please provide steps to reproduce. -->

**Screenshots**
<!-- If applicable, add screenshots to help explain your problem. -->

**Environment information**
<!-- Please supply full details of your development environment including: -->
- Cordova CLI version 
	- `cordova -v`
- Cordova platform version
	- `cordova platform ls`
- Plugins & versions installed in project (including this plugin)
    - `cordova plugin ls`
- Dev machine OS and version, e.g.
    - OSX
        - `sw_vers`
    - Windows 10
        - `winver`
        
_Runtime issue_
- Device details
    - _e.g. iPhone X, Samsung Galaxy S8, iPhone X Simulator, Pixel XL Emulator_
- OS details
    - _e.g. iOS 12.2, Android 9.0_	
	
_Android build issue:_	
- Node JS version
    - `node -v`
- Gradle version
	- `ls platforms/android/.gradle`
- Target Android SDK version
	- `android:targetSdkVersion` in `AndroidManifest.xml`
- Android SDK details
	- `sdkmanager --list | sed -e '/Available Packages/q'`
	
_iOS build issue:_
- Node JS version
    - `node -v`
- XCode version


**Related code:**
```
insert any relevant code here such as plugin API calls / input parameters
```

**Console output**
<details>
<summary>console output</summary>

```

// Paste any relevant JS/native console output here

```

</details><br/><br/>

**Other information:**

<!-- List any other information that is relevant to your issue. Stack traces, related issues, suggestions on how to fix, Stack Overflow links, forum links, etc. -->





<!--
A POLITE REMINDER

- This is free, open-source software. 
- Although the author makes every effort to maintain it, no guarantees are made as to the quality or reliability, and reported issues will be addressed if and when the author has time. 
- Help/support will not be given by the author, so forums (e.g. Ionic) or Stack Overflow should be used. Any issues requesting help/support will be closed immediately.
- If you have urgent need of a bug fix/feature, the author can be engaged for PAID contract work to do so: please contact dave@workingedge.co.uk
- Rude or abusive comments/issues will not be tolerated, nor will opening multiple issues if those previously closed are deemed unsuitable. Any of the above will result in you being BANNED from ALL of my Github repositories.
-->

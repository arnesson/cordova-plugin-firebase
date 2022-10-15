#import "AppDelegate+FirebasePlugin.h"
#import "FirebasePlugin.h"
#import "Firebase.h"
#import <objc/runtime.h>


@import UserNotifications;
@import FirebaseFirestore;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices running iOS 10 and above.
// Implement FIRMessagingDelegate to receive data message via FCM for devices running iOS 10 and above.
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end

#define kApplicationInBackgroundKey @"applicationInBackground"

@implementation AppDelegate (FirebasePlugin)

static AppDelegate* instance;
static id <UNUserNotificationCenterDelegate> _previousDelegate;

+ (AppDelegate*) instance {
    return instance;
}

static NSDictionary* mutableUserInfo;
static FIRAuthStateDidChangeListenerHandle authStateChangeListener;
static bool authStateChangeListenerInitialized = false;

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:swizzledDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
}

- (void)setApplicationInBackground:(NSNumber *)applicationInBackground {
    objc_setAssociatedObject(self, kApplicationInBackgroundKey, applicationInBackground, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)applicationInBackground {
    return objc_getAssociatedObject(self, kApplicationInBackgroundKey);
}

- (BOOL)application:(UIApplication *)application swizzledDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application swizzledDidFinishLaunchingWithOptions:launchOptions];
    
    @try{
        instance = self;
        
        bool isFirebaseInitializedWithPlist = false;
        if(![FIRApp defaultApp]) {
            // get GoogleService-Info.plist file path
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
            
            // if file is successfully found, use it
            if(filePath){
                [FirebasePlugin.firebasePlugin _logMessage:@"GoogleService-Info.plist found, setup: [FIRApp configureWithOptions]"];
                // create firebase configure options passing .plist as content
                FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];

                // configure FIRApp with options
                [FIRApp configureWithOptions:options];
                
                isFirebaseInitializedWithPlist = true;
            }else{
                // no .plist found, try default App
                [FirebasePlugin.firebasePlugin _logError:@"GoogleService-Info.plist NOT FOUND, setup: [FIRApp defaultApp]"];
                [FIRApp configure];
            }
        }else{
            // Firebase SDK has already been initialised:
            // Assume that another call (probably from another plugin) did so with the plist
            isFirebaseInitializedWithPlist = true;
        }
    
        // Set UNUserNotificationCenter delegate
        if ([UNUserNotificationCenter currentNotificationCenter].delegate != nil) {
            _previousDelegate = [UNUserNotificationCenter currentNotificationCenter].delegate;
        }
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;

        // Set FCM messaging delegate
        [FIRMessaging messaging].delegate = self;
        
        // Setup Firestore
        [FirebasePlugin setFirestore:[FIRFirestore firestore]];
        
        
        authStateChangeListener = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
            @try {
                if(!authStateChangeListenerInitialized){
                    authStateChangeListenerInitialized = true;
                }else{
                    [FirebasePlugin.firebasePlugin executeGlobalJavascript:[NSString stringWithFormat:@"FirebasePlugin._onAuthStateChange(%@)", (user != nil ? @"true": @"false")]];
                }
            }@catch (NSException *exception) {
                [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
            }
        }];


        self.applicationInBackground = @(YES);
        
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.applicationInBackground = @(NO);
    [FirebasePlugin.firebasePlugin _logMessage:@"Enter foreground"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.applicationInBackground = @(YES);
    [FirebasePlugin.firebasePlugin _logMessage:@"Enter background"];
}


# pragma mark - FIRMessagingDelegate
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    @try{
        [FirebasePlugin.firebasePlugin _logMessage:[NSString stringWithFormat:@"didReceiveRegistrationToken: %@", fcmToken]];
        [FirebasePlugin.firebasePlugin sendToken:fcmToken];
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
    [FirebasePlugin.firebasePlugin _logMessage:[NSString stringWithFormat:@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken]];
    [FirebasePlugin.firebasePlugin sendApnsToken:[FirebasePlugin.firebasePlugin hexadecimalStringFromData:deviceToken]];
}

//Tells the app that a remote notification arrived that indicates there is data to be fetched.
// Called when a message arrives in the foreground and remote notifications permission has been granted
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    @try{
        [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
        mutableUserInfo = [userInfo mutableCopy];
        NSDictionary* aps = [mutableUserInfo objectForKey:@"aps"];
        bool isContentAvailable = false;
        if([aps objectForKey:@"alert"] != nil){
            
            if([aps objectForKey:@"content-available"] != nil){
                NSNumber* contentAvailable = (NSNumber*) [aps objectForKey:@"content-available"];
                isContentAvailable = [contentAvailable isEqualToNumber:[NSNumber numberWithInt:1]];
            }
            [mutableUserInfo setValue:@"notification" forKey:@"messageType"];
            NSString* tap;
            if([self.applicationInBackground isEqual:[NSNumber numberWithBool:YES]] && !isContentAvailable){
                tap = @"background";
            }
            [mutableUserInfo setValue:tap forKey:@"tap"];
        }else{
            [mutableUserInfo setValue:@"data" forKey:@"messageType"];
        }

        [FirebasePlugin.firebasePlugin _logMessage:[NSString stringWithFormat:@"didReceiveRemoteNotification: %@", mutableUserInfo]];
        
        completionHandler(UIBackgroundFetchResultNewData);
        if([self.applicationInBackground isEqual:[NSNumber numberWithBool:YES]] && isContentAvailable){
            [FirebasePlugin.firebasePlugin _logError:@"didReceiveRemoteNotification: omitting foreground notification as content-available:1 so system notification will be shown"];
        }else{
            [self processMessageForForegroundNotification:mutableUserInfo];
        }
        if([self.applicationInBackground isEqual:[NSNumber numberWithBool:YES]] || !isContentAvailable){
            [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
        }
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}

// Scans a message for keys which indicate a notification should be shown.
// If found, extracts relevant keys and uses then to display a local notification
-(void)processMessageForForegroundNotification:(NSDictionary*)messageData {
    bool showForegroundNotification = [messageData objectForKey:@"notification_foreground"];
    if(!showForegroundNotification){
        return;
    }
    
    NSString* title = nil;
    NSString* body = nil;
    NSString* sound = nil;
    NSNumber* badge = nil;
    
    // Extract APNS notification keys
    NSDictionary* aps = [messageData objectForKey:@"aps"];
    if([aps objectForKey:@"alert"] != nil){
        NSDictionary* alert = [aps objectForKey:@"alert"];
        if([alert objectForKey:@"title"] != nil){
            title = [alert objectForKey:@"title"];
        }
        if([alert objectForKey:@"body"] != nil){
            body = [alert objectForKey:@"body"];
        }
        if([aps objectForKey:@"sound"] != nil){
            sound = [aps objectForKey:@"sound"];
        }
        if([aps objectForKey:@"badge"] != nil){
            badge = [aps objectForKey:@"badge"];
        }
    }
    
    // Extract data notification keys
    if([messageData objectForKey:@"notification_title"] != nil){
        title = [messageData objectForKey:@"notification_title"];
    }
    if([messageData objectForKey:@"notification_body"] != nil){
        body = [messageData objectForKey:@"notification_body"];
    }
    if([messageData objectForKey:@"notification_ios_sound"] != nil){
        sound = [messageData objectForKey:@"notification_ios_sound"];
    }
    if([messageData objectForKey:@"notification_ios_badge"] != nil){
        badge = [messageData objectForKey:@"notification_ios_badge"];
    }
   
    if(title == nil || body == nil){
        return;
    }
    
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        @try{
            if (settings.alertSetting == UNNotificationSettingEnabled) {
                UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
                objNotificationContent.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
                objNotificationContent.body = [NSString localizedUserNotificationStringForKey:body arguments:nil];
                
                NSDictionary* alert = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       title, @"title",
                                       body, @"body"
                                       , nil];
                NSMutableDictionary* aps = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     alert, @"alert",
                                     nil];
                
                if(![sound isKindOfClass:[NSString class]] || [sound isEqualToString:@"default"]){
                    objNotificationContent.sound = [UNNotificationSound defaultSound];
                    [aps setValue:sound forKey:@"sound"];
                }else if(sound != nil){
                    objNotificationContent.sound = [UNNotificationSound soundNamed:sound];
                    [aps setValue:sound forKey:@"sound"];
                }
                
                if(badge != nil){
                    [aps setValue:badge forKey:@"badge"];
                }
                
                NSString* messageType = @"data";
                if([mutableUserInfo objectForKey:@"messageType"] != nil){
                    messageType = [mutableUserInfo objectForKey:@"messageType"];
                }
                
                NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @"true", @"notification_foreground",
                                          messageType, @"messageType",
                                          aps, @"aps"
                                          , nil];
                
                objNotificationContent.userInfo = userInfo;
                
                UNTimeIntervalNotificationTrigger *trigger =  [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1f repeats:NO];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"local_notification" content:objNotificationContent trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        [FirebasePlugin.firebasePlugin _logMessage:@"Local Notification succeeded"];
                    } else {
                        [FirebasePlugin.firebasePlugin _logError:[NSString stringWithFormat:@"Local Notification failed: %@", error.description]];
                    }
                }];
            }else{
                [FirebasePlugin.firebasePlugin _logError:@"processMessageForForegroundNotification: cannot show notification as permission denied"];
            }
        }@catch (NSException *exception) {
            [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [FirebasePlugin.firebasePlugin _logError:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description]];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification
{
    @try {
        [FirebasePlugin.firebasePlugin sendOpenNotificationSettings];
    } @catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}


// Asks the delegate how to handle a notification that arrived while the app was running in the foreground
// Called when an APS notification arrives when app is in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    @try{

        if (![notification.request.trigger isKindOfClass:UNPushNotificationTrigger.class] && ![notification.request.trigger isKindOfClass:UNTimeIntervalNotificationTrigger.class]){
            if (_previousDelegate) {
                // bubbling notification
                [_previousDelegate userNotificationCenter:center
                          willPresentNotification:notification
                            withCompletionHandler:completionHandler];
                return;
            } else {
                [FirebasePlugin.firebasePlugin _logError:@"willPresentNotification: aborting as not a supported UNNotificationTrigger"];
                return;
            }
        }
        
        [[FIRMessaging messaging] appDidReceiveMessage:notification.request.content.userInfo];
        
        mutableUserInfo = [notification.request.content.userInfo mutableCopy];
        
        NSString* messageType = [mutableUserInfo objectForKey:@"messageType"];
        if(![messageType isEqualToString:@"data"]){
            [mutableUserInfo setValue:@"notification" forKey:@"messageType"];
        }

        // Print full message.
        [FirebasePlugin.firebasePlugin _logMessage:[NSString stringWithFormat:@"willPresentNotification: %@", mutableUserInfo]];

        
        NSDictionary* aps = [mutableUserInfo objectForKey:@"aps"];
        bool isContentAvailable = [[aps objectForKey:@"content-available"] isEqualToNumber:[NSNumber numberWithInt:1]];
        if(isContentAvailable){
            [FirebasePlugin.firebasePlugin _logError:@"willPresentNotification: aborting as content-available:1 so system notification will be shown"];
            return;
        }
        
        bool showForegroundNotification = [mutableUserInfo objectForKey:@"notification_foreground"];
        bool hasAlert = [aps objectForKey:@"alert"] != nil;
        bool hasBadge = [aps objectForKey:@"badge"] != nil;
        bool hasSound = [aps objectForKey:@"sound"] != nil;

        if(showForegroundNotification){
            [FirebasePlugin.firebasePlugin _logMessage:[NSString stringWithFormat:@"willPresentNotification: foreground notification alert=%@, badge=%@, sound=%@", hasAlert ? @"YES" : @"NO", hasBadge ? @"YES" : @"NO", hasSound ? @"YES" : @"NO"]];
            if(hasAlert && hasBadge && hasSound){
                completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionBadge + UNNotificationPresentationOptionSound);
            }else if(hasAlert && hasBadge){
                completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionBadge);
            }else if(hasAlert && hasSound){
                completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound);
            }else if(hasBadge && hasSound){
                completionHandler(UNNotificationPresentationOptionBadge + UNNotificationPresentationOptionSound);
            }else if(hasAlert){
                completionHandler(UNNotificationPresentationOptionAlert);
            }else if(hasBadge){
                completionHandler(UNNotificationPresentationOptionBadge);
            }else if(hasSound){
                completionHandler(UNNotificationPresentationOptionSound);
            }
        }else{
            [FirebasePlugin.firebasePlugin _logMessage:@"willPresentNotification: foreground notification not set"];
        }
        
        if(![messageType isEqualToString:@"data"]){
            [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
        }
        
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}

// Asks the delegate to process the user's response to a delivered notification.
// Called when user taps on system notification
- (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    @try{
        
        if (![response.notification.request.trigger isKindOfClass:UNPushNotificationTrigger.class] && ![response.notification.request.trigger isKindOfClass:UNTimeIntervalNotificationTrigger.class]){
            if (_previousDelegate) {
                // bubbling event
                [_previousDelegate userNotificationCenter:center
                               didReceiveNotificationResponse:response
                            withCompletionHandler:completionHandler];
                return;
            } else {
                [FirebasePlugin.firebasePlugin _logMessage:@"didReceiveNotificationResponse: aborting as not a supported UNNotificationTrigger"];
                return;
            }
        }

        [[FIRMessaging messaging] appDidReceiveMessage:response.notification.request.content.userInfo];
        
        mutableUserInfo = [response.notification.request.content.userInfo mutableCopy];
        
        NSString* tap;
        if([self.applicationInBackground isEqual:[NSNumber numberWithBool:YES]]){
            tap = @"background";
        }else{
            tap = @"foreground";
            
        }
        [mutableUserInfo setValue:tap forKey:@"tap"];
        if([mutableUserInfo objectForKey:@"messageType"] == nil){
            [mutableUserInfo setValue:@"notification" forKey:@"messageType"];
        }
        
        // Dynamic Actions
        if (response.actionIdentifier && ![response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier]) {
            [mutableUserInfo setValue:response.actionIdentifier forKey:@"action"];
        }
        
        // Print full message.
        [FirebasePlugin.firebasePlugin _logInfo:[NSString stringWithFormat:@"didReceiveNotificationResponse: %@", mutableUserInfo]];

        [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];

        completionHandler();
        
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}


// Apple Sign In
- (void)authorizationController:(ASAuthorizationController *)controller
   didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    @try{
        CDVPluginResult* pluginResult;
        NSString* errorMessage = nil;
        FIROAuthCredential *credential;
        
        if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
            ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
            NSString *rawNonce = [FirebasePlugin appleSignInNonce];
            if(rawNonce == nil){
                errorMessage = @"Invalid state: A login callback was received, but no login request was sent.";
            }else if (appleIDCredential.identityToken == nil) {
                errorMessage = @"Unable to fetch identity token.";
            }else{
                NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken
                                                          encoding:NSUTF8StringEncoding];
                if (idToken == nil) {
                    errorMessage = [NSString stringWithFormat:@"Unable to serialize id token from data: %@", appleIDCredential.identityToken];
                }else{
                    // Initialize a Firebase credential.
                    credential = [FIROAuthProvider credentialWithProviderID:@"apple.com"
                        IDToken:idToken
                        rawNonce:rawNonce];
                    
                    NSNumber* key = [[FirebasePlugin firebasePlugin] saveAuthCredential:credential];
                    NSString *authorizationCode = [[NSString alloc] initWithData:appleIDCredential.authorizationCode
                                                                        encoding:NSUTF8StringEncoding];
                    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                    [result setValue:@"true" forKey:@"instantVerification"];
                    [result setValue:key forKey:@"id"];
                    if(authorizationCode != nil){
                        [result setValue:authorizationCode forKey:@"authorizationCode"];
                    }
                    if(appleIDCredential.fullName != nil){
                        if(appleIDCredential.fullName.givenName != nil){
                            [result setValue:appleIDCredential.fullName.givenName forKey:@"givenName"];
                        }
                        if(appleIDCredential.fullName.familyName != nil){
                            [result setValue:appleIDCredential.fullName.familyName forKey:@"familyName"];
                        }
                    }
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                }
            }
            if(errorMessage != nil){
                [FirebasePlugin.firebasePlugin _logError:errorMessage];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
            }
            if ([FirebasePlugin firebasePlugin].appleSignInCallbackId != nil) {
                [[FirebasePlugin firebasePlugin].commandDelegate sendPluginResult:pluginResult callbackId:[FirebasePlugin firebasePlugin].appleSignInCallbackId];
            }
        }
    }@catch (NSException *exception) {
        [FirebasePlugin.firebasePlugin handlePluginExceptionWithoutContext:exception];
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSString* errorMessage = [NSString stringWithFormat:@"Sign in with Apple errored: %@", error];
    [FirebasePlugin.firebasePlugin _logError:errorMessage];
    if ([FirebasePlugin firebasePlugin].appleSignInCallbackId != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [[FirebasePlugin firebasePlugin].commandDelegate sendPluginResult:pluginResult callbackId:[FirebasePlugin firebasePlugin].appleSignInCallbackId];
    }
}

- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:(nonnull ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    return self.viewController.view.window;
}

@end

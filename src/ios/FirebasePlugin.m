#import "FirebasePlugin.h"
#import "FirebasePluginMessageReceiverManager.h"
#import "AppDelegate+FirebasePlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <GoogleSignIn/GoogleSignIn.h>
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;
@import FirebaseRemoteConfig;
@import FirebasePerformance;
@import FirebaseAuth;
@import UserNotifications;
@import CommonCrypto;
@import AuthenticationServices;

@implementation FirebasePlugin

@synthesize notificationCallbackId;
@synthesize tokenRefreshCallbackId;
@synthesize apnsTokenRefreshCallbackId;
@synthesize googleSignInCallbackId;
@synthesize appleSignInCallbackId;
@synthesize notificationStack;
@synthesize traces;

static NSString*const LOG_TAG = @"FirebasePlugin[native]";
static NSInteger const kNotificationStackSize = 10;
static NSString*const FIREBASE_CRASHLYTICS_COLLECTION_ENABLED = @"FIREBASE_CRASHLYTICS_COLLECTION_ENABLED";
static NSString*const FIREBASE_ANALYTICS_COLLECTION_ENABLED = @"FIREBASE_ANALYTICS_COLLECTION_ENABLED";
static NSString*const FIREBASE_PERFORMANCE_COLLECTION_ENABLED = @"FIREBASE_PERFORMANCE_COLLECTION_ENABLED";

static FirebasePlugin* firebasePlugin;
static BOOL registeredForRemoteNotifications = NO;
static BOOL isCrashlyticsEnabled = NO;
static NSMutableDictionary* authCredentials;
static NSString* currentNonce; // used for Apple Sign In
static FIRFirestore* firestore;
static NSUserDefaults* preferences;
static NSDictionary* googlePlist;


+ (FirebasePlugin*) firebasePlugin {
    return firebasePlugin;
}

+ (NSString*) appleSignInNonce {
    return currentNonce;
}

+ (void) setFirestore:(FIRFirestore*) firestoreInstance{
    firestore = firestoreInstance;
}

// @override abstract
- (void)pluginInitialize {
    NSLog(@"Starting Firebase plugin");
    firebasePlugin = self;
    
    @try {
        preferences = [NSUserDefaults standardUserDefaults];
        googlePlist = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"]];
        
        if(![self getGooglePlistFlagWithDefaultValue:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED defaultValue:YES]){
            isCrashlyticsEnabled = [self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED];
        }else{
            isCrashlyticsEnabled = YES;
            [self setPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED flag:YES];
        }
        
        if([self getGooglePlistFlagWithDefaultValue:FIREBASE_ANALYTICS_COLLECTION_ENABLED defaultValue:YES]){
            [self setPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED flag:YES];
        }
        
        if([self getGooglePlistFlagWithDefaultValue:FIREBASE_PERFORMANCE_COLLECTION_ENABLED defaultValue:YES]){
            [self setPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED flag:YES];
        }
        
        // Check for permission and register for remote notifications if granted
        [self _hasPermission:^(BOOL result) {}];
        
        [GIDSignIn sharedInstance].presentingViewController = self.viewController;
        
        authCredentials = [[NSMutableDictionary alloc] init];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithoutContext:exception];
    }
}

// @override abstract
- (void)handleOpenURL:(NSNotification*)notification{
    NSURL* url = [notification object];
    [[GIDSignIn sharedInstance] handleURL:url];
}

- (void)setAutoInitEnabled:(CDVInvokedUrlCommand *)command {
    @try {
        bool enabled = [[command.arguments objectAtIndex:0] boolValue];
        [self runOnMainThread:^{
            @try {
                [FIRMessaging messaging].autoInitEnabled = enabled;

                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)isAutoInitEnabled:(CDVInvokedUrlCommand *)command {
    @try {

        [self runOnMainThread:^{
            @try {
                 bool enabled =[FIRMessaging messaging].isAutoInitEnabled;

                 CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:enabled];
                 [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

/*
 * Remote notifications
 */

- (void)getId:(CDVInvokedUrlCommand *)command {
    __block CDVPluginResult *pluginResult;

    FIRInstanceIDHandler handler = ^(NSString *_Nullable instID, NSError *_Nullable error) {
        @try {
            if (error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:instID];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    };

    @try {
        [[FIRInstanceID instanceID] getIDWithHandler:handler];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)getToken:(CDVInvokedUrlCommand *)command {
    @try {
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                            NSError * _Nullable error) {
            CDVPluginResult* pluginResult;
            if (error == nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result.token];
            }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)getAPNSToken:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self getAPNSToken]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *)getAPNSToken {
    NSString* hexToken = nil;
    NSData* apnsToken = [FIRMessaging messaging].APNSToken;
    if (apnsToken) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        // [deviceToken description] Starting with iOS 13 device token is like "{length = 32, bytes = 0xd3d997af 967d1f43 b405374a 13394d2f ... 28f10282 14af515f }"
        hexToken = [self hexadecimalStringFromData:apnsToken];
#else
        hexToken = [[apnsToken.description componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet]invertedSet]]componentsJoinedByString:@""];
#endif
    }
    return hexToken;
}

- (NSString *)hexadecimalStringFromData:(NSData *)data
{
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
      
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    @try {
        [self _hasPermission:^(BOOL enabled) {
            CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:enabled];
            [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

-(void)_hasPermission:(void (^)(BOOL result))completeBlock {
    @try {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            @try {
                BOOL enabled = NO;
                if (settings.alertSetting == UNNotificationSettingEnabled) {
                    enabled = YES;
                    [self registerForRemoteNotifications];
                }
                NSLog(@"_hasPermission: %@", enabled ? @"YES" : @"NO");
                completeBlock(enabled);
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithoutContext:exception];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithoutContext:exception];
    }
}

- (void)grantPermission:(CDVInvokedUrlCommand *)command {
    NSLog(@"grantPermission");
    @try {
        [self _hasPermission:^(BOOL enabled) {
            @try {
                if(enabled){
                    NSString* message = @"Permission is already granted - call hasPermission() to check before calling grantPermission()";
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }else{
                    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate> _Nullable) self;
                    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge;
                    [[UNUserNotificationCenter currentNotificationCenter]
                     requestAuthorizationWithOptions:authOptions
                     completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        @try {
                            NSLog(@"requestAuthorizationWithOptions: granted=%@", granted ? @"YES" : @"NO");
                            CDVPluginResult* pluginResult;
                            if (error == nil) {
                                if(granted){
                                    [self registerForRemoteNotifications];
                                }
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:granted];
                            }else{
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                            }
                            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                        }@catch (NSException *exception) {
                            [self handlePluginExceptionWithContext:exception :command];
                        }
                    }
                     ];
                }
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)registerForRemoteNotifications {
    NSLog(@"registerForRemoteNotifications");
    if(registeredForRemoteNotifications) return;
    
    [self runOnMainThread:^{
        @try {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithoutContext:exception];
        }
        registeredForRemoteNotifications = YES;
    }];
}

- (void)setBadgeNumber:(CDVInvokedUrlCommand *)command {
    @try {
        int number = [[command.arguments objectAtIndex:0] intValue];
        [self runOnMainThread:^{
            @try {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)getBadgeNumber:(CDVInvokedUrlCommand *)command {
    [self runOnMainThread:^{
        @try {
            long badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:badge];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* topic = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]];

        [[FIRMessaging messaging] subscribeToTopic: topic];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)unsubscribe:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* topic = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]];

        [[FIRMessaging messaging] unsubscribeFromTopic: topic];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)unregister:(CDVInvokedUrlCommand *)command {
    @try {
        [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
            CDVPluginResult* pluginResult;
            if (error == nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}



- (void)onMessageReceived:(CDVInvokedUrlCommand *)command {
    @try {
        self.notificationCallbackId = command.callbackId;

        if (self.notificationStack != nil && [self.notificationStack count]) {
            for (NSDictionary *userInfo in self.notificationStack) {
                [self sendNotification:userInfo];
            }
            [self.notificationStack removeAllObjects];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)onTokenRefresh:(CDVInvokedUrlCommand *)command {
    self.tokenRefreshCallbackId = command.callbackId;
    @try {
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                            NSError * _Nullable error) {
            @try {
                if (error == nil) {
                    if (result.token != nil && error == nil) {
                        [self sendToken:result.token];
                    }
                }else{
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)onApnsTokenReceived:(CDVInvokedUrlCommand *)command {
    self.apnsTokenRefreshCallbackId = command.callbackId;
    @try {
        NSString* apnsToken = [self getAPNSToken];
        if(apnsToken != nil){
            [self sendApnsToken:apnsToken];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)sendNotification:(NSDictionary *)userInfo {
    @try {
        if([FirebasePluginMessageReceiverManager sendNotification:userInfo]){
            [self _logMessage:@"Message handled by custom receiver"];
            return;
        }
        if (self.notificationCallbackId != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.notificationCallbackId];
        } else {
            if (!self.notificationStack) {
                self.notificationStack = [[NSMutableArray alloc] init];
            }

            // stack notifications until a callback has been registered
            [self.notificationStack addObject:userInfo];

            if ([self.notificationStack count] >= kNotificationStackSize) {
                [self.notificationStack removeLastObject];
            }
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :self.commandDelegate];
    }
}

- (void)sendToken:(NSString *)token {
    @try {
        if (self.tokenRefreshCallbackId != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.tokenRefreshCallbackId];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :self.commandDelegate];
    }
}

- (void)sendApnsToken:(NSString *)token {
    @try {
        if (self.apnsTokenRefreshCallbackId != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.apnsTokenRefreshCallbackId];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :self.commandDelegate];
    }
}

- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command {
    [self runOnMainThread:^{
        @try {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/*
 * Authentication
 */
- (void)verifyPhoneNumber:(CDVInvokedUrlCommand *)command {
    NSString* number = [command.arguments objectAtIndex:0];

    @try {
        [[FIRPhoneAuthProvider provider]
        verifyPhoneNumber:number
               UIDelegate:nil
               completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {

            @try {
                CDVPluginResult* pluginResult;
                if (error) {
                    // Verification code not sent.
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                } else {
                    // Successful.
                    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
                    [result setValue:@"false" forKey:@"instantVerification"];
                    [result setValue:verificationID forKey:@"verificationId"];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithContext:exception :command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)createUserWithEmailAndPassword:(CDVInvokedUrlCommand*)command {
    @try {
        NSString* email = [command.arguments objectAtIndex:0];
        NSString* password = [command.arguments objectAtIndex:1];
        [[FIRAuth auth] createUserWithEmail:email
                                   password:password
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
          @try {
              [self handleAuthResult:authResult error:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)signInUserWithEmailAndPassword:(CDVInvokedUrlCommand*)command {
    @try {
        NSString* email = [command.arguments objectAtIndex:0];
        NSString* password = [command.arguments objectAtIndex:1];
        [[FIRAuth auth] signInWithEmail:email
                                   password:password
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
          @try {
              [self handleAuthResult:authResult error:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)authenticateUserWithGoogle:(CDVInvokedUrlCommand*)command{
    @try {
        self.googleSignInCallbackId = command.callbackId;
        [[GIDSignIn sharedInstance] signIn];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)authenticateUserWithApple:(CDVInvokedUrlCommand*)command{
    @try {
        CDVPluginResult *pluginResult;
        if (@available(iOS 13.0, *)) {
            self.appleSignInCallbackId = command.callbackId;
            [self startSignInWithAppleFlow];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallbackAsBool:YES];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"OS version is too low - Apple Sign In requires iOS 13.0+"];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)signInWithCredential:(CDVInvokedUrlCommand*)command {
    @try {
        FIRAuthCredential* credential = [self obtainAuthCredential:[command.arguments objectAtIndex:0] command:command];
        if(credential == nil) return;
        
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            [self handleAuthResult:authResult error:error command:command];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)reauthenticateWithCredential:(CDVInvokedUrlCommand*)command{
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        FIRAuthCredential* credential = [self obtainAuthCredential:[command.arguments objectAtIndex:0] command:command];
        if(credential == nil) return;
        
        [user reauthenticateWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            [self handleAuthResult:authResult error:error command:command];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)linkUserWithCredential:(CDVInvokedUrlCommand*)command {
    @try {
        FIRAuthCredential* credential = [self obtainAuthCredential:[command.arguments objectAtIndex:0] command:command];
        if(credential == nil) return;
        
        [[FIRAuth auth].currentUser linkWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            [self handleAuthResult:authResult error:error command:command];
        }];
        
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)isUserSignedIn:(CDVInvokedUrlCommand*)command {
    @try {
        bool isSignedIn = [FIRAuth auth].currentUser ? true : false;
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isSignedIn] callbackId:command.callbackId];
        
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)signOutUser:(CDVInvokedUrlCommand*)command {
    @try {
        bool isSignedIn = [FIRAuth auth].currentUser ? true : false;
        if(!isSignedIn){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        NSError *signOutError;
        BOOL status = [[FIRAuth auth] signOut:&signOutError];
        if (!status) {
          [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"Error signing out: %@", signOutError]] callbackId:command.callbackId];
        }else{
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)getCurrentUser:(CDVInvokedUrlCommand *)command {
    
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        NSMutableDictionary* userInfo = [NSMutableDictionary new];
        [userInfo setValue:user.displayName forKey:@"name"];
        [userInfo setValue:user.email forKey:@"email"];
        [userInfo setValue:@(user.isEmailVerified ? true : false) forKey:@"emailIsVerified"];
        [userInfo setValue:user.phoneNumber forKey:@"phoneNumber"];
        [userInfo setValue:user.photoURL ? user.photoURL.absoluteString : nil forKey:@"photoUrl"];
        [userInfo setValue:user.uid forKey:@"uid"];
        [userInfo setValue:user.providerID forKey:@"providerId"];
        [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
            [userInfo setValue:token forKey:@"idToken"];
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo] callbackId:command.callbackId];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)updateUserProfile:(CDVInvokedUrlCommand*)command {
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        NSDictionary* profile = [command.arguments objectAtIndex:0];
        
        FIRUserProfileChangeRequest* changeRequest = [user profileChangeRequest];
        if([profile objectForKey:@"name"] != nil){
            changeRequest.displayName = [profile objectForKey:@"name"];
        }
        if([profile objectForKey:@"photoUri"] != nil){
            changeRequest.photoURL = [NSURL URLWithString:[profile objectForKey:@"photoUri"]];
        }
        
        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)updateUserEmail:(CDVInvokedUrlCommand*)command {
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        NSString* email = [command.arguments objectAtIndex:0];
        [user updateEmail:email completion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)sendUserEmailVerification:(CDVInvokedUrlCommand*)command{
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        [user sendEmailVerificationWithCompletion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)updateUserPassword:(CDVInvokedUrlCommand*)command{
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        NSString* password = [command.arguments objectAtIndex:0];
        [user updatePassword:password completion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)sendUserPasswordResetEmail:(CDVInvokedUrlCommand*)command{
    @try {
        NSString* email = [command.arguments objectAtIndex:0];
        [[FIRAuth auth] sendPasswordResetWithEmail:email completion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)deleteUser:(CDVInvokedUrlCommand*)command{
    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        
        [user deleteWithCompletion:^(NSError *_Nullable error) {
          @try {
              [self handleResultWithPotentialError:error command:command];
          }@catch (NSException *exception) {
              [self handlePluginExceptionWithContext:exception :command];
          }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)startSignInWithAppleFlow API_AVAILABLE(ios(13.0)){
  NSString *nonce = [self randomNonce:32];
  currentNonce = nonce;
  ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
  ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
  request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
  request.nonce = [self stringBySha256HashingString:nonce];

  ASAuthorizationController *authorizationController =
      [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
  authorizationController.delegate = [AppDelegate instance];
  authorizationController.presentationContextProvider = [AppDelegate instance];
  [authorizationController performRequests];
}

- (NSString *)stringBySha256HashingString:(NSString *)input {
  const char *string = [input UTF8String];
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(string, (CC_LONG)strlen(string), result);

  NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hashed appendFormat:@"%02x", result[i]];
  }
  return hashed;
}

// Generates random nonce for Apple Sign In
- (NSString *)randomNonce:(NSInteger)length {
  NSAssert(length > 0, @"Expected nonce to have positive length");
  NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
  NSMutableString *result = [NSMutableString string];
  NSInteger remainingLength = length;

  while (remainingLength > 0) {
    NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
      uint8_t random = 0;
      int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
      NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);

      [randoms addObject:@(random)];
    }

    for (NSNumber *random in randoms) {
      if (remainingLength == 0) {
        break;
      }

      if (random.unsignedIntValue < characterSet.length) {
        unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
        [result appendFormat:@"%C", character];
        remainingLength--;
      }
    }
  }

  return result;
}

/*
 * Analytics
 */
- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
            BOOL enabled = [[command argumentAtIndex:0] boolValue];
            CDVPluginResult* pluginResult;
            if([self getGooglePlistFlagWithDefaultValue:FIREBASE_ANALYTICS_COLLECTION_ENABLED defaultValue:YES]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set Analytics data collection at runtime as it's hard-coded to ENABLED at build-time in the plist"];
            }else if(enabled && [self getPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Analytics data collection is already set to enabled"];
            }else if(!enabled && ![self getPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Analytics data collection is already set to disabled"];
            }else{
                [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
                [self setPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED flag:enabled];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)isAnalyticsCollectionEnabled:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self getPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* name = [command.arguments objectAtIndex:0];
            NSDictionary *parameters = [command argumentAtIndex:1];

            [FIRAnalytics logEventWithName:name parameters:parameters];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)setScreenName:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* name = [command.arguments objectAtIndex:0];

        [FIRAnalytics setScreenName:name screenClass:NULL];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)setUserId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* id = [command.arguments objectAtIndex:0];

            [FIRAnalytics setUserID:id];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)setUserProperty:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* name = [command.arguments objectAtIndex:0];
            NSString* value = [command.arguments objectAtIndex:1];

            [FIRAnalytics setUserPropertyString:value forName:name];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/*
 * Crashlytics
 */
- (BOOL) _shouldEnableCrashlytics {
    return ![self getGooglePlistFlagWithDefaultValue:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED defaultValue:YES] && [self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED];
}

- (void)setCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             BOOL enabled = [[command argumentAtIndex:0] boolValue];
             CDVPluginResult* pluginResult;
             if([self getGooglePlistFlagWithDefaultValue:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED defaultValue:YES]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set Crashlytics data collection at runtime as it's hard-coded to ENABLED at build-time in the plist"];
             }else if(enabled && [self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Crashlytics data collection is already set to enabled"];
             }else if(!enabled && ![self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Crashlytics data collection is already set to disabled"];
             }else{
                 [self setPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED flag:enabled];
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             }
             
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)isCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)isCrashlyticsCollectionCurrentlyEnabled:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isCrashlyticsEnabled];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)logError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* errorMessage = [command.arguments objectAtIndex:0];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        @try {
            if(!isCrashlyticsEnabled){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot log error - Crashlytics collection is disabled"];
            }
            // We can optionally be passed a stack trace from stackTrace.js which we'll put in userInfo.
            else if ([command.arguments count] > 1) {
                NSArray* stackFrames = [command.arguments objectAtIndex:1];
                
                NSString* message = errorMessage;
                NSString* name = @"Uncaught Javascript exception";
                NSMutableArray *customFrames = [[NSMutableArray alloc] init];
                
                for (NSDictionary* stackFrame in stackFrames) {
                    CLSStackFrame *customFrame = [CLSStackFrame stackFrame];
                    [customFrame setSymbol:stackFrame[@"functionName"]];
                    [customFrame setFileName:stackFrame[@"fileName"]];
                    [customFrame setLibrary:stackFrame[@"source"]];
                    [customFrame setOffset:(uint64_t) [stackFrame[@"columnNumber"] intValue]];
                    [customFrame setLineNumber:(uint32_t) [stackFrame[@"lineNumber"] intValue]];
                    [customFrames addObject:customFrame];
                }
                [[Crashlytics sharedInstance] recordCustomExceptionName:name reason:message frameArray:customFrames];
            }else{
                //TODO detect and handle non-stack userInfo and pass to recordError
                NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
                NSError *error = [NSError errorWithDomain:errorMessage code:0 userInfo:userInfo];
                [CrashlyticsKit recordError:error];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    
    }];
}

- (void)logMessage:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* message = [command argumentAtIndex:0 withDefault:@""];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            if(!isCrashlyticsEnabled){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot log message - Crashlytics collection is disabled"];
            }else if(message){
                CLSNSLog(@"%@",message);
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)sendCrash:(CDVInvokedUrlCommand*)command{
    [[Crashlytics sharedInstance] crash];
}

- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* userId = [command.arguments objectAtIndex:0];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        if(!isCrashlyticsEnabled){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set user ID - Crashlytics collection is disabled"];
        }else{
            [CrashlyticsKit setUserIdentifier:userId];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

/*
 * Remote config
 */
- (void)fetch:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
          FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];

          if ([command.arguments count] > 0) {
              int expirationDuration = [[command.arguments objectAtIndex:0] intValue];

              [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (error != nil) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                  }else if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          } else {
              [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (error != nil) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                  }else if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          }
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)activateFetched:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
             [remoteConfig activateWithCompletionHandler:^(NSError * _Nullable error) {
                 CDVPluginResult *pluginResult;
                 if (error != nil) {
                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                 } else {
                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                 }
                 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             }];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)getValue:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* key = [command.arguments objectAtIndex:0];
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
            NSString* value = remoteConfig[key].stringValue;
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/*
 * Performance
 */
- (void)setPerformanceCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             BOOL enabled = [[command argumentAtIndex:0] boolValue];
             CDVPluginResult* pluginResult;
             if([self getGooglePlistFlagWithDefaultValue:FIREBASE_PERFORMANCE_COLLECTION_ENABLED defaultValue:YES]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set Performance data collection at runtime as it's hard-coded to ENABLED at build-time in the plist"];
             }else if(enabled && [self getPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Performance data collection is already set to enabled"];
             }else if(!enabled && ![self getPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED]){
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Performance data collection is already set to disabled"];
             }else{
                 [[FIRPerformance sharedInstance] setDataCollectionEnabled:enabled];
                 [self setPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED flag:enabled];
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             }

             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)isPerformanceCollectionEnabled:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self getPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)startTrace:(CDVInvokedUrlCommand *)command {

    [self.commandDelegate runInBackground:^{
        @try {
            NSString* traceName = [command.arguments objectAtIndex:0];
            FIRTrace *trace = [self.traces objectForKey:traceName];

            if ( self.traces == nil) {
                self.traces = [NSMutableDictionary new];
            }

            if (trace == nil) {
                trace = [FIRPerformance startTraceWithName:traceName];
                [self.traces setObject:trace forKey:traceName ];

            }

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)incrementCounter:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* traceName = [command.arguments objectAtIndex:0];
            NSString* counterNamed = [command.arguments objectAtIndex:1];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            FIRTrace *trace = (FIRTrace*)[self.traces objectForKey:traceName];

            if (trace != nil) {
                [trace incrementMetric:counterNamed byInt:1];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Trace not found"];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)stopTrace:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* traceName = [command.arguments objectAtIndex:0];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            FIRTrace *trace = [self.traces objectForKey:traceName];

            if (trace != nil) {
                [trace stop];
                [self.traces removeObjectForKey:traceName];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Trace not found"];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/*
* Firestore
*/

- (void)addDocumentToFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSDictionary* document = [command.arguments objectAtIndex:0];
            NSString* collection = [command.arguments objectAtIndex:1];
            __block FIRDocumentReference *ref =
            [[firestore collectionWithPath:collection] addDocumentWithData:document completion:^(NSError * _Nullable error) {
              if (error != nil) {
                  [self sendPluginError:error.localizedDescription:command];
              } else {
                  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ref.documentID];
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)setDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSDictionary* document = [command.arguments objectAtIndex:1];
            NSString* collection = [command.arguments objectAtIndex:2];
            
            [[[firestore collectionWithPath:collection] documentWithPath:documentId] setData:document completion:^(NSError * _Nullable error) {
              if (error != nil) {
                [self sendPluginError:error.localizedDescription:command];
              } else {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
              }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)updateDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSDictionary* document = [command.arguments objectAtIndex:1];
            NSString* collection = [command.arguments objectAtIndex:2];
            
            FIRDocumentReference* docRef = [[firestore collectionWithPath:collection] documentWithPath:documentId];
            if(docRef != nil){
                [docRef updateData:document completion:^(NSError * _Nullable error) {
                    if (error != nil) {
                        [self sendPluginError:error.localizedDescription:command];
                    } else {
                        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
                    }
                }];
            }else{
                [self sendPluginError:@"Document not found in collection":command];
            }
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)deleteDocumentFromFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSString* collection = [command.arguments objectAtIndex:1];

            [[[firestore collectionWithPath:collection] documentWithPath:documentId]
                deleteDocumentWithCompletion:^(NSError * _Nullable error) {
                  if (error != nil) {
                    [self sendPluginError:error.localizedDescription:command];
                  } else {
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
                  }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)fetchDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSString* collection = [command.arguments objectAtIndex:1];
            
            FIRDocumentReference* docRef = [[firestore collectionWithPath:collection] documentWithPath:documentId];
            if(docRef != nil){
                [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
                    if (error != nil) {
                        [self sendPluginError:error.localizedDescription:command];
                    } else {
                        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:snapshot.data] callbackId:command.callbackId];
                    }
                }];
            }else{
                [self sendPluginError:@"Document not found in collection":command];
            }
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)fetchFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* collection = [command.arguments objectAtIndex:0];

            [[firestore collectionWithPath:collection] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
                if (error != nil) {
                    [self sendPluginError:error.localizedDescription:command];
                } else {
                    NSMutableDictionary* documents = [[NSMutableDictionary alloc] init];;
                    for (FIRDocumentSnapshot *document in snapshot.documents) {
                        [documents setObject:document.data forKey:document.documentID];
                    }
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:documents] callbackId:command.callbackId];
                }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/********************************/
#pragma mark - utility functions
/********************************/
- (void) sendPluginError: (NSString*) errorMessage :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    [self _logError:errorMessage];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) handlePluginExceptionWithContext: (NSException*) exception :(CDVInvokedUrlCommand*)command
{
    [self handlePluginExceptionWithoutContext:exception];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) handlePluginExceptionWithoutContext: (NSException*) exception
{
    [self _logError:[NSString stringWithFormat:@"EXCEPTION: %@", exception.reason]];
}

- (void)executeGlobalJavascript: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

- (void)_logError: (NSString*)msg
{
    NSLog(@"%@ ERROR: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.error(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logInfo: (NSString*)msg
{
    NSLog(@"%@ INFO: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.info(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logMessage: (NSString*)msg
{
    NSLog(@"%@ LOG: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.log(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
    [self executeGlobalJavascript:jsString];
}

- (NSString*)escapeDoubleQuotes: (NSString*)str
{
    NSString *result =[str stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
    return result;
}

- (void)runOnMainThread:(void (^)(void))completeBlock {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                completeBlock();
            }@catch (NSException *exception) {
                [self handlePluginExceptionWithoutContext:exception];
            }
        });
    } else {
        @try {
            completeBlock();
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithoutContext:exception];
        }
    }
}

- (FIRAuthCredential*)obtainAuthCredential:(NSDictionary*)credential command:(CDVInvokedUrlCommand *)command {
    FIRAuthCredential* authCredential = nil;
    
    if(credential == nil){
        NSString* errMsg = @"credential object must be passed as first and only argument";
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errMsg] callbackId:command.callbackId];
        return authCredential;
    }
    
    NSString* key = [credential objectForKey:@"id"];
    NSString* verificationId = [credential objectForKey:@"verificationId"];
    NSString* code = [credential objectForKey:@"code"];
    
    if(key != nil){
        authCredential = [authCredentials objectForKey:key];
        if(authCredential == nil){
            NSString* errMsg = [NSString stringWithFormat:@"no native auth credential exists for specified id '%@'", key];
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errMsg] callbackId:command.callbackId];
        }
    }else if(verificationId != nil && code != nil){
        authCredential = [[FIRPhoneAuthProvider provider]
        credentialWithVerificationID:verificationId
                    verificationCode:code];
    }else{
        NSString* errMsg = @"credential object must either specify the id key of an existing native auth credential or the verificationId/code keys must be specified for a phone number authentication";
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errMsg] callbackId:command.callbackId];
    }

    return authCredential;
}

- (void) handleAuthResult:(FIRAuthDataResult*) authResult error:(NSError*) error command:(CDVInvokedUrlCommand*)command {
    @try {
           CDVPluginResult* pluginResult;
         if (error) {
           pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
         }else if (authResult == nil) {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User not signed in"];
         }else{
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         }
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }@catch (NSException *exception) {
         [self handlePluginExceptionWithContext:exception :command];
     }
}

- (int) saveAuthCredential: (FIRAuthCredential*) authCredential {
    int key = -1;
    while (key < 0 || [authCredentials objectForKey:[NSNumber numberWithInt:key]] != nil) {
        key = arc4random_uniform(100000);
    }
    
    [authCredentials setObject:authCredential forKey:[NSNumber numberWithInt:key]];

    return key;
}

- (void) handleResultWithPotentialError:(NSError*) error command:(CDVInvokedUrlCommand*)command {
     CDVPluginResult* pluginResult;
     if (error) {
       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
     }else{
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     }
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setPreferenceFlag:(NSString*) name flag:(BOOL)flag {
    [preferences setBool:flag forKey:name];
    [preferences synchronize];
}

- (BOOL) getPreferenceFlag:(NSString*) name {
    if([preferences objectForKey:name] == nil){
        return false;
    }
    return [preferences boolForKey:name];
}

- (BOOL) getGooglePlistFlagWithDefaultValue:(NSString*) name defaultValue:(BOOL)defaultValue {
    if([googlePlist objectForKey:name] == nil){
        return defaultValue;
    }
    return [[googlePlist objectForKey:name] isEqualToString:@"true"];
}


# pragma mark - Stubs
- (void)createChannel:(CDVInvokedUrlCommand *)command {
	[self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setDefaultChannel:(CDVInvokedUrlCommand *)command {
	[self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)deleteChannel:(CDVInvokedUrlCommand *)command {
	[self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)listChannels:(CDVInvokedUrlCommand *)command {
	[self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
@end

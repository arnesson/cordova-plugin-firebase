#import "FirebasePlugin.h"
#import "FirebasePluginMessageReceiverManager.h"
#import "AppDelegate+FirebasePlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;
@import FirebaseRemoteConfig;
@import FirebasePerformance;
@import FirebaseAuth;
@import FirebaseFunctions;
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
static NSString*const FIREBASE_CRASHLYTICS_COLLECTION_ENABLED = @"FIREBASE_CRASHLYTICS_COLLECTION_ENABLED"; //preference
static NSString*const FirebaseCrashlyticsCollectionEnabled = @"FirebaseCrashlyticsCollectionEnabled"; //plist
static NSString*const FIREBASE_ANALYTICS_COLLECTION_ENABLED = @"FIREBASE_ANALYTICS_COLLECTION_ENABLED";
static NSString*const FIREBASE_PERFORMANCE_COLLECTION_ENABLED = @"FIREBASE_PERFORMANCE_COLLECTION_ENABLED";

static FirebasePlugin* firebasePlugin;
static BOOL registeredForRemoteNotifications = NO;
static NSMutableDictionary* authCredentials;
static NSString* currentNonce; // used for Apple Sign In
static FIRFirestore* firestore;
static NSUserDefaults* preferences;
static NSDictionary* googlePlist;
static NSMutableDictionary* firestoreListeners;
static NSString* currentInstallationId;


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

        if([self getGooglePlistFlagWithDefaultValue:FirebaseCrashlyticsCollectionEnabled defaultValue:YES]){
            [self setPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED flag:YES];
        }

        if([self getGooglePlistFlagWithDefaultValue:FIREBASE_ANALYTICS_COLLECTION_ENABLED defaultValue:YES]){
            [self setPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED flag:YES];
        }

        if([self getGooglePlistFlagWithDefaultValue:FIREBASE_PERFORMANCE_COLLECTION_ENABLED defaultValue:YES]){
            [self setPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED flag:YES];
        }

        // Set actionable categories if pn-actions.json exist in bundle
        [self setActionableNotifications];

        // Check for permission and register for remote notifications if granted
        [self _hasPermission:^(BOOL result) {}];

        [GIDSignIn sharedInstance].presentingViewController = self.viewController;

        authCredentials = [[NSMutableDictionary alloc] init];
        firestoreListeners = [[NSMutableDictionary alloc] init];
        self.traces = [NSMutableDictionary new];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithoutContext:exception];
    }
}


// Dynamic actions from pn-actions.json
- (void)setActionableNotifications {
    @try {
        // Parse JSON
        NSString *path = [[NSBundle mainBundle] pathForResource:@"pn-actions" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if(data == nil) return;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

        // Assign actions for categories
        NSMutableSet *categories = [[NSMutableSet alloc] init];
        NSArray *actionsArray = [dict objectForKey:@"PushNotificationActions"];
        for (NSDictionary *item in actionsArray) {
            NSMutableArray *buttons = [NSMutableArray new];
            NSString *category = [item objectForKey:@"category"];

            NSArray *actions = [item objectForKey:@"actions"];
            for (NSDictionary *action in actions) {
                NSString *actionId = [action objectForKey:@"id"];
                NSString *actionTitle = [action objectForKey:@"title"];
                UNNotificationActionOptions options = UNNotificationActionOptionNone;

                id mode = [action objectForKey:@"foreground"];
                if (mode != nil && (([mode isKindOfClass:[NSString class]] && [mode isEqualToString:@"true"]) || [mode boolValue])) {
                    options |= UNNotificationActionOptionForeground;
                }
                id destructive = [action objectForKey:@"destructive"];
                if (destructive != nil && (([destructive isKindOfClass:[NSString class]] && [destructive isEqualToString:@"true"]) || [destructive boolValue])) {
                    options |= UNNotificationActionOptionDestructive;
                }

                [buttons addObject:[UNNotificationAction actionWithIdentifier:actionId
                    title:NSLocalizedString(actionTitle, nil) options:options]];
            }

            [categories addObject:[UNNotificationCategory categoryWithIdentifier:category
                        actions:buttons intentIdentifiers:@[] options:UNNotificationCategoryOptionNone]];
        }

        // Initialize categories
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
        
        // Initialize installation ID change listner
        __weak __auto_type weakSelf = self;
        self.installationIDObserver = [[NSNotificationCenter defaultCenter]
                addObserverForName: FIRInstallationIDDidChangeNotification
                            object:nil
                             queue:nil
                        usingBlock:^(NSNotification * _Nonnull notification) {
            [weakSelf sendNewInstallationId];
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithoutContext:exception];
    }
}

// @override abstract
- (void)handleOpenURL:(NSNotification*)notification{
    NSURL* url = [notification object];
    [[GIDSignIn sharedInstance] handleURL:url];
}

/*************************************************/
#pragma mark - plugin API
/*************************************************/
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
            [self handleStringResultWithPotentialError:error command:command result:instID];
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
        	NSString* token = nil;
            if (error == nil && result != nil && result.token != nil) {
                token = result.token;
            }
            [self handleStringResultWithPotentialError:error command:command result:token];
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
                            if (error == nil && granted) {
                                [self registerForRemoteNotifications];
                            }
                            [self handleBoolResultWithPotentialError:error command:command result:granted];

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

        [[FIRMessaging messaging] subscribeToTopic: topic completion:^(NSError * _Nullable error) {
            [self handleEmptyResultWithPotentialError:error command:command];
        }];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)unsubscribe:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* topic = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]];

        [[FIRMessaging messaging] unsubscribeFromTopic: topic completion:^(NSError * _Nullable error) {
            [self handleEmptyResultWithPotentialError:error command:command];
        }];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)unregister:(CDVInvokedUrlCommand *)command {
    @try {
        [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
            [self handleEmptyResultWithPotentialError:error command:command];
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
                if (result.token != nil && error == nil) {
                    [self sendToken:result.token];
                }else{
                    [self handleStringResultWithPotentialError:error command:command result:result.token];
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
            [self sendPluginDictionaryResultAndKeepCallback:userInfo command:self.commandDelegate callbackId:self.notificationCallbackId];
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
            [self sendPluginStringResultAndKeepCallback:token command:self.commandDelegate callbackId:self.tokenRefreshCallbackId];
        }
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :self.commandDelegate];
    }
}

- (void)sendApnsToken:(NSString *)token {
    @try {
        if (self.apnsTokenRefreshCallbackId != nil) {
            [self sendPluginStringResultAndKeepCallback:token command:self.commandDelegate callbackId:self.apnsTokenRefreshCallbackId];
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

- (void)setLanguageCode:(CDVInvokedUrlCommand *)command {
    NSString* lang = [command.arguments objectAtIndex:0];
    @try {
         [FIRAuth auth].languageCode = lang;
         NSLog(@"Language code setted to %@!", lang);
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

- (void)authenticateUserWithEmailAndPassword:(CDVInvokedUrlCommand*)command {
    @try {
        NSString* email = [command.arguments objectAtIndex:0];
        NSString* password = [command.arguments objectAtIndex:1];
        FIRAuthCredential* authCredential = [FIREmailAuthProvider credentialWithEmail:email password:password];
        NSNumber* key = [self saveAuthCredential:authCredential];

        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setValue:@"true" forKey:@"instantVerification"];
        [result setValue:key forKey:@"id"];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)signInUserWithCustomToken:(CDVInvokedUrlCommand*)command {
    @try {
        NSString* customToken = [command.arguments objectAtIndex:0];
        [[FIRAuth auth] signInWithCustomToken:customToken
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

- (void)signInUserAnonymously:(CDVInvokedUrlCommand*)command {
    @try {
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult,
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

        [self sendPluginNoResultAndKeepCallback:command callbackId:command.callbackId];
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

        // Sign out of Google
        if([[GIDSignIn sharedInstance] currentUser] != nil){
            [[GIDSignIn sharedInstance] signOut];
        }

        // Sign out of Firebase
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
        [self extractAndReturnUserInfo:command];

    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void)reloadCurrentUser:(CDVInvokedUrlCommand *)command {

    @try {
        FIRUser* user = [FIRAuth auth].currentUser;
        if(!user){
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user is currently signed"] callbackId:command.callbackId];
            return;
        }
        [user reloadWithCompletion:^(NSError * _Nullable error) {
            if (error != nil) {
                [self handleEmptyResultWithPotentialError:error command:command];
            }else {
                [self extractAndReturnUserInfo:command];
            }
        }];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

- (void) extractAndReturnUserInfo:(CDVInvokedUrlCommand *)command {
    FIRUser* user = [FIRAuth auth].currentUser;
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setValue:user.displayName forKey:@"name"];
    [userInfo setValue:user.email forKey:@"email"];
    [userInfo setValue:@(user.isEmailVerified ? true : false) forKey:@"emailIsVerified"];
    [userInfo setValue:user.phoneNumber forKey:@"phoneNumber"];
    [userInfo setValue:user.photoURL ? user.photoURL.absoluteString : nil forKey:@"photoUrl"];
    [userInfo setValue:user.uid forKey:@"uid"];
    [userInfo setValue:@(user.isAnonymous ? true : false) forKey:@"isAnonymous"];
    [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
        if(error == nil){
            [userInfo setValue:token forKey:@"idToken"];
        }
        [user getIDTokenResultWithCompletion:^(FIRAuthTokenResult * _Nullable tokenResult, NSError * _Nullable error) {
            if(error == nil){
                [userInfo setValue:tokenResult.signInProvider forKey:@"providerId"];
            }
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo] callbackId:command.callbackId];
        }];
    }];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
              [self handleEmptyResultWithPotentialError:error command:command];
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
            [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
            [self setPreferenceFlag:FIREBASE_ANALYTICS_COLLECTION_ENABLED flag:enabled];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

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

- (void)setCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             BOOL enabled = [[command argumentAtIndex:0] boolValue];
             CDVPluginResult* pluginResult;
             [[FIRCrashlytics crashlytics] setCrashlyticsCollectionEnabled:enabled];
             [self setPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED flag:enabled];
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)isCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self isCrashlyticsEnabled]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

-(BOOL)isCrashlyticsEnabled{
    return [self getPreferenceFlag:FIREBASE_CRASHLYTICS_COLLECTION_ENABLED];
}

-(void)didCrashOnPreviousExecution:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

            if(![self isCrashlyticsEnabled]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot query didCrashOnPreviousExecution - Crashlytics collection is disabled"];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[[FIRCrashlytics crashlytics] didCrashDuringPreviousExecution]];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)logError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* errorMessage = [command.arguments objectAtIndex:0];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            if(![self isCrashlyticsEnabled]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot log error - Crashlytics collection is disabled"];
            }else if([command.arguments objectAtIndex:0] == [NSNull null]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot log error - error message is empty"];
            }
            // We can optionally be passed a stack trace from stackTrace.js which we'll put in userInfo.
            else if ([command.arguments count] > 1) {
                NSArray* stackFrames = [command.arguments objectAtIndex:1];

                NSString* message = errorMessage;
                NSString* name = @"Uncaught Javascript exception";
                NSMutableArray *customFrames = [[NSMutableArray alloc] init];
                FIRExceptionModel *exceptionModel = [FIRExceptionModel exceptionModelWithName:name reason:message];

                for (NSDictionary* stackFrame in stackFrames) {
                    FIRStackFrame *customFrame = [FIRStackFrame stackFrameWithSymbol:stackFrame[@"functionName"] file:stackFrame[@"fileName"] line:(uint32_t) [stackFrame[@"lineNumber"] intValue]];
                    [customFrames addObject:customFrame];
                }
                exceptionModel.stackTrace = customFrames;
                [[FIRCrashlytics crashlytics] recordExceptionModel:exceptionModel];
            }else{
                //TODO detect and handle non-stack userInfo and pass to recordError
                NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
                NSError *error = [NSError errorWithDomain:errorMessage code:0 userInfo:userInfo];
                [[FIRCrashlytics crashlytics] recordError:error];
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
            if(![self isCrashlyticsEnabled]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot log message - Crashlytics collection is disabled"];
            }else if(message){
                [[FIRCrashlytics crashlytics] logWithFormat:@"%@", message];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)setCrashlyticsCustomKey:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* key = [command argumentAtIndex:0 withDefault:@""];
            NSString* value = [command argumentAtIndex:1 withDefault:@""];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

            if(![self isCrashlyticsEnabled]){
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set custom key/valuee - Crashlytics collection is disabled"];
            }else {
                [[FIRCrashlytics crashlytics] setCustomValue: value forKey: key];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)sendCrash:(CDVInvokedUrlCommand*)command{
    assert(NO);
}

- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand *)command {
    @try {
        NSString* userId = [command.arguments objectAtIndex:0];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        if(![self isCrashlyticsEnabled]){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot set user ID - Crashlytics collection is disabled"];
        }else{
            [[FIRCrashlytics crashlytics] setUserID:userId];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
}

/*
 * Remote config
 */
- (void)setConfigSettings:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];

            FIRRemoteConfigSettings* settings = [[FIRRemoteConfigSettings alloc] init];

            if([command.arguments objectAtIndex:0] != [NSNull null]){
                settings.fetchTimeout = [[command.arguments objectAtIndex:0] longValue];
            }

            if([command.arguments objectAtIndex:1] != [NSNull null]){
                settings.minimumFetchInterval = [[command.arguments objectAtIndex:1] longValue];
            }

            remoteConfig.configSettings = settings;

            [self sendPluginSuccess:command];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)setDefaults:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSDictionary* defaults = [command.arguments objectAtIndex:0];
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
            [remoteConfig setDefaults:defaults];
            [self sendPluginSuccess:command];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)fetch:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
          FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];

          if ([command.arguments count] > 0) {
              int expirationDuration = [[command.arguments objectAtIndex:0] intValue];

              [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  if (status == FIRRemoteConfigFetchStatusSuccess && error == nil){
                      [self sendPluginSuccess:command];
                  }else if (error != nil) {
                      [self handleEmptyResultWithPotentialError:error command:command];
                  } else {
                      [self sendPluginError:command];
                  }
              }];
          } else {
              [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  if (status == FIRRemoteConfigFetchStatusSuccess && error == nil){
                      [self sendPluginSuccess:command];
                  }else if (error != nil) {
                      [self handleEmptyResultWithPotentialError:error command:command];
                  } else {
                      [self sendPluginError:command];
                  }
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
             [remoteConfig activateWithCompletion:^(BOOL changed, NSError* _Nullable error) {
                 [self handleBoolResultWithPotentialError:error command:command result:true];
             }];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)fetchAndActivate:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
            [remoteConfig fetchAndActivateWithCompletionHandler:^(FIRRemoteConfigFetchAndActivateStatus status, NSError * _Nullable error) {
                bool activated = (status == FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote || status == FIRRemoteConfigFetchAndActivateStatusSuccessUsingPreFetchedData);
                [self handleBoolResultWithPotentialError:error command:command result:activated];
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)resetRemoteConfig:(CDVInvokedUrlCommand*)command {
    [self sendPluginErrorWithMessage:@"resetRemoteConfig is not currently available on iOS" :command];
}

- (void)getAll:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
            NSArray* defaultKeys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault];
            NSArray* remoteKeys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote];
            NSArray* staticKeys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceStatic];
            NSArray* keys = defaultKeys;
            if([keys count] == 0){
                keys = remoteKeys;
            }
            if([keys count] == 0){
                keys = staticKeys;
            }
            NSMutableDictionary* result = [[NSMutableDictionary alloc] init];

            for (NSString* key in keys) {
                [result setObject:remoteConfig[key].stringValue forKey:key];
            }

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
            NSInteger minimumFetchInterval = remoteConfig.configSettings.minimumFetchInterval;
            NSInteger fetchTimeout = remoteConfig.configSettings.fetchTimeout;
            NSDate* lastFetchTime = remoteConfig.lastFetchTime;
            FIRRemoteConfigFetchStatus lastFetchStatus = remoteConfig.lastFetchStatus;

            NSDictionary* configSettings = @{
                @"minimumFetchInterval": [NSNumber numberWithInteger:minimumFetchInterval],
                @"fetchTimeout": [NSNumber numberWithInteger:fetchTimeout],
            };

            NSDictionary* infoObject = @{
                @"configSettings": configSettings,
                @"fetchTimeMillis": (lastFetchTime ? [NSNumber numberWithInteger:(lastFetchTime.timeIntervalSince1970 * 1000)] : [NSNull null]),
                @"lastFetchStatus": [NSNumber numberWithInteger:(lastFetchStatus)],
            };

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:infoObject];
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
             [[FIRPerformance sharedInstance] setDataCollectionEnabled:enabled];
             [self setPreferenceFlag:FIREBASE_PERFORMANCE_COLLECTION_ENABLED flag:enabled];
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

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
            FIRTrace* trace = [self.traces objectForKey:traceName];

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
                [self handleStringResultWithPotentialError:error command:command result:ref.documentID];
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
                [self handleEmptyResultWithPotentialError:error command:command];
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
                    [self handleEmptyResultWithPotentialError:error command:command];
                }];
            }else{
                [self sendPluginErrorWithMessage:@"Document not found in collection":command];
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
                    [self handleEmptyResultWithPotentialError:error command:command];
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)documentExistsInFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSString* collection = [command.arguments objectAtIndex:1];

            FIRDocumentReference* docRef = [[firestore collectionWithPath:collection] documentWithPath:documentId];
            if(docRef != nil){
                [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
                    BOOL docExists = snapshot.data != nil;
                    [self handleBoolResultWithPotentialError:error command:command result:docExists];
                }];
            }else{
                [self sendPluginErrorWithMessage:@"Collection not found":command];
            }
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
                        [self sendPluginErrorWithMessage:error.localizedDescription:command];
                    } else if(snapshot.data != nil) {
                        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:snapshot.data] callbackId:command.callbackId];
                    }else{
                        [self sendPluginErrorWithMessage:@"Document not found in collection":command];
                    }
                }];
            }else{
                [self sendPluginErrorWithMessage:@"Collection not found":command];
            }
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)listenToDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* documentId = [command.arguments objectAtIndex:0];
            NSString* collection = [command.arguments objectAtIndex:1];
            bool includeMetadata = [command.arguments objectAtIndex:2];

            id<FIRListenerRegistration> listener = [[[firestore collectionWithPath:collection] documentWithPath:documentId]
                addSnapshotListenerWithIncludeMetadataChanges:includeMetadata
                                                     listener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                @try {
                    if(snapshot != nil){
                        NSMutableDictionary* document = [[NSMutableDictionary alloc] init];;
                        [document setObject:@"change" forKey:@"eventType"];
                        if(snapshot.data != nil){
                            [document setObject:snapshot.data forKey:@"snapshot"];
                        }
                        if(snapshot.metadata != nil){
                            [document setObject:[NSNumber numberWithBool:snapshot.metadata.fromCache] forKey:@"fromCache"];
                            [document setObject:snapshot.metadata.hasPendingWrites ? @"local" : @"remote" forKey:@"source"];
                        }
                        [self sendPluginDictionaryResultAndKeepCallback:document command:command callbackId:command.callbackId];
                    }else{
                        [self sendPluginErrorWithError:error command:command];
                    }
                }@catch (NSException *exception) {
                    [self handlePluginExceptionWithContext:exception :command];
                }
            }];

            NSMutableDictionary* jsResult = [[NSMutableDictionary alloc] init];;
            [jsResult setObject:@"id" forKey:@"eventType"];
            NSNumber* key = [self saveFirestoreListener:listener];
            [jsResult setObject:key forKey:@"id"];
            [self sendPluginDictionaryResultAndKeepCallback:jsResult command:command callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)fetchFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* collection = [command.arguments objectAtIndex:0];
            NSArray* filters = nil;
            if([command.arguments objectAtIndex:1] != [NSNull null]){
                filters = [command.arguments objectAtIndex:1];
            }

            FIRQuery* query = [firestore collectionWithPath:collection];
            if(filters != nil){
                query = [self applyFiltersToFirestoreCollectionQuery:filters query:query];
            }

            [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
                if (error != nil) {
                    [self sendPluginErrorWithMessage:error.localizedDescription:command];
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

- (void)listenToFirestoreCollection:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* collection = [command.arguments objectAtIndex:0];
            NSArray* filters = nil;
            if([command.arguments objectAtIndex:1] != [NSNull null]){
                filters = [command.arguments objectAtIndex:1];
            }
            bool includeMetadata = [command.arguments objectAtIndex:2];

            FIRQuery* query = [firestore collectionWithPath:collection];
            if(filters != nil){
                query = [self applyFiltersToFirestoreCollectionQuery:filters query:query];
            }

            id<FIRListenerRegistration> listener = [query
                addSnapshotListenerWithIncludeMetadataChanges:includeMetadata
                listener:^(FIRQuerySnapshot *snapshot, NSError *error) {
                    @try {
                        if(snapshot != nil){
                            NSMutableDictionary* jsResult = [[NSMutableDictionary alloc] init];
                            [jsResult setObject:@"change" forKey:@"eventType"];

                            NSMutableDictionary* documents = [[NSMutableDictionary alloc] init];
                            bool hasDocuments = false;
                            for (FIRDocumentChange* dc in snapshot.documentChanges) {
                                hasDocuments = true;
                                NSMutableDictionary* document = [[NSMutableDictionary alloc] init];
                                if (dc.type == FIRDocumentChangeTypeAdded) {
                                    [document setObject:@"new" forKey:@"type"];
                                }else if (dc.type == FIRDocumentChangeTypeModified) {
                                    [document setObject:@"modified" forKey:@"type"];
                                }else if (dc.type == FIRDocumentChangeTypeRemoved) {
                                    [document setObject:@"removed" forKey:@"type"];
                                }else{
                                    [document setObject:@"metadata" forKey:@"type"];
                                }
                                if(dc.document.data != nil){
                                    [document setObject:dc.document.data forKey:@"snapshot"];
                                }
                                if(dc.document.metadata != nil){
                                    [document setObject:[NSNumber numberWithBool:dc.document.metadata.fromCache] forKey:@"fromCache"];
                                    [document setObject:dc.document.metadata.hasPendingWrites ? @"local" : @"remote" forKey:@"source"];
                                }
                                [documents setObject:document forKey:dc.document.documentID];
                            }
                            if(hasDocuments){
                                [jsResult setObject:documents forKey:@"documents"];
                            }
                            [self sendPluginDictionaryResultAndKeepCallback:jsResult command:command callbackId:command.callbackId];
                        }else{
                            [self sendPluginErrorWithError:error command:command];
                        }
                    }@catch (NSException *exception) {
                        [self handlePluginExceptionWithContext:exception :command];
                    }
                }
            ];

            NSMutableDictionary* jsResult = [[NSMutableDictionary alloc] init];;
            [jsResult setObject:@"id" forKey:@"eventType"];
            NSNumber* key = [self saveFirestoreListener:listener];
            [jsResult setObject:key forKey:@"id"];
            [self sendPluginDictionaryResultAndKeepCallback:jsResult command:command callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (FIRQuery*) applyFiltersToFirestoreCollectionQuery:(NSArray*)filters query:(FIRQuery*)query {
    for (int i = 0; i < [filters count]; i++) {
        NSArray* filter = [filters objectAtIndex:i];
        if ([[filter objectAtIndex:0] isEqualToString:@"where"]) {
                if ([[filter objectAtIndex:2] isEqualToString:@"=="]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] isEqualTo: [self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
                if ([[filter objectAtIndex:2] isEqualToString:@"<"]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] isLessThan:[self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
                if ([[filter objectAtIndex:2] isEqualToString:@">"]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] isGreaterThan:[self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
                if ([[filter objectAtIndex:2] isEqualToString:@"<="]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] isLessThanOrEqualTo:[self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
                if ([[filter objectAtIndex:2] isEqualToString:@">="]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] isGreaterThanOrEqualTo:[self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
                if ([[filter objectAtIndex:2] isEqualToString:@"array-contains"]) {
                    query = [query queryWhereField:[filter objectAtIndex:1] arrayContains:[self getFilterValueAsType:filter valueIndex:3 typeIndex:4]];
                }
            continue;
        }
        if ([[filter objectAtIndex:0] isEqualToString:@"orderBy"]) {
            query = [query queryOrderedByField:[filter objectAtIndex:1] descending:([[filter objectAtIndex:2] isEqualToString:@"desc"])];
            continue;
        }
        if ([[filter objectAtIndex:0] isEqualToString:@"startAt"]) {
            query = [query queryStartingAtValues:[self getFilterValueAsType:filter valueIndex:1 typeIndex:2]];
            continue;
        }
        if ([[filter objectAtIndex:0] isEqualToString:@"endAt"]) {
            query = [query queryEndingAtValues:[self getFilterValueAsType:filter valueIndex:1 typeIndex:2]];
            continue;
        }
        if ([[filter objectAtIndex:0] isEqualToString:@"limit"]) {
            query = [query queryLimitedTo:[(NSNumber *)[filter objectAtIndex:1] integerValue]];
            continue;
        }
    }
    return query;
}

- (id) getFilterValueAsType: (NSArray*)filter  valueIndex:(int)valueIndex typeIndex:(int)typeIndex{
    id typedValue = [filter objectAtIndex:valueIndex];

    NSString* type = @"string";
    if([filter objectAtIndex:typeIndex] != nil){
        type = [filter objectAtIndex:typeIndex];
    }

    if([type isEqual:@"boolean"]){
        if([typedValue isKindOfClass:[NSNumber class]]){
            typedValue = [NSNumber numberWithBool:typedValue];
        }else if([typedValue isKindOfClass:[NSString class]]){
            bool boolValue = [typedValue boolValue];
            typedValue = [NSNumber numberWithBool:boolValue];
        }
    } else if([type isEqual:@"integer"] || [type isEqual:@"long"]){
        if([typedValue isKindOfClass:[NSString class]]){
            NSInteger intValue = [typedValue integerValue];
            typedValue = [NSNumber numberWithInteger:intValue];
        }
    } else if([type isEqual:@"double"]){
        if([typedValue isKindOfClass:[NSString class]]){
            double doubleValue = [typedValue doubleValue];
            typedValue = [NSNumber numberWithDouble:doubleValue];
        }
    } else{ //string
        if([typedValue isKindOfClass:[NSNumber class]]){
            if([self isBoolNumber:typedValue]){
                bool boolValue = [typedValue boolValue];
                typedValue = boolValue ? @"true" : @"false";
            }else{
                typedValue = [typedValue stringValue];
            }
        }
    }

    return typedValue;
}

// https://stackoverflow.com/a/30223989/777265
- (BOOL) isBoolNumber:(NSNumber *)num
{
   CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
   CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
   return numID == boolID;
}

- (NSNumber*) saveFirestoreListener: (id<FIRListenerRegistration>) firestoreListener {
    @synchronized (firestoreListeners) {
        int id = [self generateId];
        NSNumber* key = [NSNumber numberWithInt:id];
        [firestoreListeners setObject:firestoreListener forKey:key];
        return key;
    }
}

- (void) removeFirestoreListener:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSNumber* listenerId = @([[command.arguments objectAtIndex:0] intValue]);
            bool removed = [self _removeFirestoreListener:listenerId];
            if(removed){
                [self sendPluginSuccess:command];
            }else{
                [self sendPluginErrorWithMessage:@"Listener ID not found" :command];
            }
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (bool) _removeFirestoreListener: (NSNumber*) key {
    @synchronized (firestoreListeners) {
        bool removed = false;
        if([firestoreListeners objectForKey:key] != nil){
            id<FIRListenerRegistration> firestoreListener = [firestoreListeners objectForKey:key];
            [firestoreListener remove];
            [firestoreListeners removeObjectForKey:key];
            removed = true;
        }
        return removed;
    }
}

/*
 * Functions
 */
- (void)functionsHttpsCallable:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            __weak __auto_type weakSelf = self;
            NSString* name = [command.arguments objectAtIndex:0];
            NSDictionary* arguments = [command.arguments objectAtIndex:1];
            [[[FIRFunctions functions] HTTPSCallableWithName:name] callWithObject:arguments
                                                                  completion:^(FIRHTTPSCallableResult* _Nullable result, NSError* _Nullable error) {
                if (error != nil) {
                    [weakSelf sendPluginErrorWithError:error command:command];
                } else {
                    [weakSelf sendPluginDictionaryResult:result.data command:command callbackId:command.callbackId];
                }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

/*
 * Installations
 */
- (void) getInstallationId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations] installationIDWithCompletion:^(NSString *identifier, NSError *error) {
                [self handleStringResultWithPotentialError:error command:command result:identifier];
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void) getInstallationToken:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {            
            [[FIRInstallations installations] authTokenForcingRefresh:true
                                                           completion:^(FIRInstallationsAuthTokenResult *result, NSError *error) {
              if (error != nil) {
                  [self sendPluginErrorWithError:error command:command];
              }else{
                  [self sendPluginStringResult:[result authToken] command:command callbackId:command.callbackId];
              }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void) deleteInstallationId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations] deleteWithCompletion:^(NSError *error) {
                [self handleEmptyResultWithPotentialError:error command:command];
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void) sendNewInstallationId {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations] installationIDWithCompletion:^(NSString *identifier, NSError *error) {
                if(error != nil){
                    [self handlePluginErrorWithoutContext:error];
                }else if(currentInstallationId != identifier){
                    [FirebasePlugin.firebasePlugin executeGlobalJavascript:[NSString stringWithFormat:@"FirebasePlugin._onInstallationIdChangeCallback('%@')", identifier]];
                    currentInstallationId = identifier;
                }
            }];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithoutContext:exception];
        }
    }];
}

/*************************************************/
#pragma mark - utility functions
/*************************************************/
- (void) sendPluginSuccess:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) sendPluginNoResult:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginNoResultAndKeepCallback:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginStringResult:(NSString*)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginStringResultAndKeepCallback:(NSString*)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginBoolResult:(BOOL)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginBoolResultAndKeepCallback:(BOOL)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginDictionaryResult:(NSDictionary*)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginDictionaryResultAndKeepCallback:(NSDictionary*)result command:(CDVInvokedUrlCommand*)command callbackId:(NSString*)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) sendPluginError:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void) sendPluginErrorWithMessage: (NSString*) errorMessage :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    [self _logError:errorMessage];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendPluginErrorWithError:(NSError*)error command:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description] callbackId:command.callbackId];
}

- (void) handleEmptyResultWithPotentialError:(NSError*) error command:(CDVInvokedUrlCommand*)command {
     if (error) {
         [self sendPluginErrorWithError:error command:command];
     }else{
         [self sendPluginSuccess:command];
     }
}

- (void) handleStringResultWithPotentialError:(NSError*) error command:(CDVInvokedUrlCommand*)command result:(NSString*)result {
     if (error) {
         [self sendPluginErrorWithError:error command:command];
     }else{
         [self sendPluginStringResult:result command:command callbackId:command.callbackId];
     }
}

- (void) handleBoolResultWithPotentialError:(NSError*) error command:(CDVInvokedUrlCommand*)command result:(BOOL)result {
     if (error) {
         [self sendPluginErrorWithError:error command:command];
     }else{
         [self sendPluginBoolResult:result command:command callbackId:command.callbackId];
     }
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

- (void) handlePluginErrorWithoutContext: (NSError*) error
{
    [self _logError:[NSString stringWithFormat:@"ERROR: %@", error.description]];
}

- (void)executeGlobalJavascript: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

- (void)_logError: (NSString*)msg
{
    NSLog(@"%@ ERROR: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.error(\"%@: %@\")", LOG_TAG, [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logInfo: (NSString*)msg
{
    NSLog(@"%@ INFO: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.info(\"%@: %@\")", LOG_TAG, [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logMessage: (NSString*)msg
{
    NSLog(@"%@ LOG: %@", LOG_TAG, msg);
    NSString* jsString = [NSString stringWithFormat:@"console.log(\"%@: %@\")", LOG_TAG, [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

- (NSString*)escapeJavascriptString: (NSString*)str
{
    NSString* result = [str stringByReplacingOccurrencesOfString: @"\\\"" withString: @"\""];
    result = [result stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
    result = [result stringByReplacingOccurrencesOfString: @"\n" withString: @"\\\n"];
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

- (NSNumber*) saveAuthCredential: (FIRAuthCredential*) authCredential {
    int id = [self generateId];
    NSNumber* key = [NSNumber numberWithInt:id];
    [authCredentials setObject:authCredential forKey:key];
    return key;
}

- (int) generateId {
    int key = -1;
    while (key < 0
       || [authCredentials objectForKey:[NSNumber numberWithInt:key]] != nil
       || [firestoreListeners objectForKey:[NSNumber numberWithInt:key]] != nil
    ) {
        key = arc4random_uniform(100000);
    }
    return key;
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

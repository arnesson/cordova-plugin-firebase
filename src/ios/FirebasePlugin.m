#import "FirebasePlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import "Firebase.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;
@import FirebaseRemoteConfig;
@import FirebasePerformance;
@import FirebaseAuth;
@import UserNotifications;

@implementation FirebasePlugin

@synthesize notificationCallbackId;
@synthesize tokenRefreshCallbackId;
@synthesize notificationStack;
@synthesize traces;

static NSString*const LOG_TAG = @"FirebasePlugin[native]";
static NSInteger const kNotificationStackSize = 10;
static FirebasePlugin *firebasePlugin;
static BOOL registeredForRemoteNotifications = NO;

+ (FirebasePlugin *) firebasePlugin {
    return firebasePlugin;
}

- (void)pluginInitialize {
    NSLog(@"Starting Firebase plugin");
    firebasePlugin = self;
    
    // Check for permission and register for remote notifications if granted
    [self _hasPermission:^(BOOL result) {}];
}

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
    NSData* apnsToken = [FIRMessaging messaging].APNSToken;
    CDVPluginResult *pluginResult;
    if (apnsToken) {
        NSString* hexToken = [[apnsToken.description componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet]invertedSet]]componentsJoinedByString:@""];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:hexToken];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

- (void)verifyPhoneNumber:(CDVInvokedUrlCommand *)command {
    [self getVerificationID:command];
}

- (void)getVerificationID:(CDVInvokedUrlCommand *)command {
    NSString* number = [command.arguments objectAtIndex:0];

    @try {
        [[FIRPhoneAuthProvider provider]
        verifyPhoneNumber:number
               UIDelegate:nil
               completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {

            @try {
                NSDictionary *message;
                if (error) {
                    // Verification code not sent.
                    message = @{
                        @"code": [NSNumber numberWithInteger:error.code],
                        @"description": error.description == nil ? [NSNull null] : error.description
                    };

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:message];

                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    // Successful.
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:verificationID];
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

- (void)sendNotification:(NSDictionary *)userInfo {
    @try {
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

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* name = [command.arguments objectAtIndex:0];
            NSDictionary *parameters;
            @try {
                NSString *description = NSLocalizedString([command argumentAtIndex:1 withDefault:@"No Message Provided"], nil);
                parameters = @{ NSLocalizedDescriptionKey: description };
            }
            @catch (NSException *execption) {
                parameters = [command argumentAtIndex:1];
            }

            [FIRAnalytics logEventWithName:name parameters:parameters];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }@catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception :command];
        }
    }];
}

- (void)logError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* errorMessage = [command.arguments objectAtIndex:0];
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        CDVCommandStatus status = CDVCommandStatus_OK;

        @try {
            // We can optionally be passed a stack trace from stackTrace.js which we'll put in userInfo.
            if ([command.arguments count] > 1) {
                NSArray *stack = [command.arguments objectAtIndex:1];
                int lineNum = 1;
                for (NSDictionary *entry in stack) {
                    NSString *key = [NSString stringWithFormat:@"Stack_line_%02d", lineNum++];
                    userInfo[key] = entry[@"source"];
                }
            }
        } @catch (NSException *exception) {
            CLSNSLog(@"Exception in logError: %@, original error: %@", exception.description, errorMessage);
            status = CDVCommandStatus_ERROR;
        }

        NSError *error = [NSError errorWithDomain:errorMessage code:0 userInfo:userInfo];
        [CrashlyticsKit recordError:error];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logMessage:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* message = [command argumentAtIndex:0 withDefault:@""];
            if(message)
            {
                CLSNSLog(@"%@",message);
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
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

        [CrashlyticsKit setUserIdentifier:userId];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }@catch (NSException *exception) {
        [self handlePluginExceptionWithContext:exception :command];
    }
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

# pragma mark - Performace
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

- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
            BOOL enabled = [[command argumentAtIndex:0] boolValue];

            [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)setPerformanceCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             BOOL enabled = [[command argumentAtIndex:0] boolValue];

             [[FIRPerformance sharedInstance] setDataCollectionEnabled:enabled];

             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
}

- (void)setCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         @try {
             [Fabric with:@[[Crashlytics class]]];
             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }@catch (NSException *exception) {
             [self handlePluginExceptionWithContext:exception :command];
         }
     }];
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

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
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:instID];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    [[FIRInstanceID instanceID] getIDWithHandler:handler];
}

- (void)getToken:(CDVInvokedUrlCommand *)command {
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result.token];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    [self _hasPermission:^(BOOL enabled) {
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:enabled];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}

-(void)_hasPermission:(void (^)(BOOL result))completeBlock {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        BOOL enabled = NO;
        if (settings.alertSetting == UNNotificationSettingEnabled) {
            enabled = YES;
            [self registerForRemoteNotifications];
        }
        NSLog(@"_hasPermission: %@", enabled ? @"YES" : @"NO");
        completeBlock(enabled);
    }];
}

- (void)grantPermission:(CDVInvokedUrlCommand *)command {
    NSLog(@"grantPermission");
    [self _hasPermission:^(BOOL enabled) {
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
                NSLog(@"requestAuthorizationWithOptions: granted=%@", granted ? @"YES" : @"NO");
                if(granted){
                    [self registerForRemoteNotifications];
                }
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:granted] callbackId:command.callbackId];
            }
             ];
        }
    }];
}

- (void)registerForRemoteNotifications {
    NSLog(@"registerForRemoteNotifications");
    if(registeredForRemoteNotifications) return;
    
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            registeredForRemoteNotifications = YES;
        });
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        registeredForRemoteNotifications = YES;
    }
}

- (void)verifyPhoneNumber:(CDVInvokedUrlCommand *)command {
    [self getVerificationID:command];
}

- (void)getVerificationID:(CDVInvokedUrlCommand *)command {
    NSString* number = [command.arguments objectAtIndex:0];

    [[FIRPhoneAuthProvider provider]
    verifyPhoneNumber:number
           UIDelegate:nil
           completion:^(NSString *_Nullable verificationID, NSError *_Nullable error) {

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
  }];
}

- (void)setBadgeNumber:(CDVInvokedUrlCommand *)command {
    int number = [[command.arguments objectAtIndex:0] intValue];

    dispatch_sync(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

- (void)getBadgeNumber:(CDVInvokedUrlCommand *)command {
    dispatch_sync(dispatch_get_main_queue(), ^{
        long badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:badge];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    NSString* topic = [NSString stringWithFormat:@"/topics/%@", [command.arguments objectAtIndex:0]];

    [[FIRMessaging messaging] subscribeToTopic: topic];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unsubscribe:(CDVInvokedUrlCommand *)command {
    NSString* topic = [NSString stringWithFormat:@"/topics/%@", [command.arguments objectAtIndex:0]];

    [[FIRMessaging messaging] unsubscribeFromTopic: topic];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unregister:(CDVInvokedUrlCommand *)command {
    [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
        if (error) {
            NSLog(@"Unable to delete instance");
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)onMessageReceived:(CDVInvokedUrlCommand *)command {
    self.notificationCallbackId = command.callbackId;

    if (self.notificationStack != nil && [self.notificationStack count]) {
        for (NSDictionary *userInfo in self.notificationStack) {
            [self sendNotification:userInfo];
        }
        [self.notificationStack removeAllObjects];
    }
}

- (void)onTokenRefresh:(CDVInvokedUrlCommand *)command {
    self.tokenRefreshCallbackId = command.callbackId;
    
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (result.token != nil && error == nil) {
            [self sendToken:result.token];
        }
    }];
}

- (void)sendNotification:(NSDictionary *)userInfo {
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
}

- (void)sendToken:(NSString *)token {
    if (self.tokenRefreshCallbackId != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.tokenRefreshCallbackId];
    }
}

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
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
    }];
}

- (void)logError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* message = [command argumentAtIndex:0 withDefault:@""];
        if(message)
        {
            NSDictionary* detail = @{@"message":message};
            NSError* error = [NSError errorWithDomain:@"Logged error" code:0 userInfo:detail];
            [CrashlyticsKit recordError:error];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)logMessage:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        NSString* message = [command argumentAtIndex:0 withDefault:@""];
        if(message)
        {
            CLSNSLog(@"%@",message);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)sendCrash:(CDVInvokedUrlCommand*)command{
    [[Crashlytics sharedInstance] crash];
}

- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand *)command {
    NSString* userId = [command.arguments objectAtIndex:0];

    [CrashlyticsKit setUserIdentifier:userId];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setScreenName:(CDVInvokedUrlCommand *)command {
    NSString* name = [command.arguments objectAtIndex:0];

    [FIRAnalytics setScreenName:name screenClass:NULL];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* id = [command.arguments objectAtIndex:0];

        [FIRAnalytics setUserID:id];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setUserProperty:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* name = [command.arguments objectAtIndex:0];
        NSString* value = [command.arguments objectAtIndex:1];

        [FIRAnalytics setUserPropertyString:value forName:name];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fetch:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
          FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];

          if ([command.arguments count] > 0) {
              int expirationDuration = [[command.arguments objectAtIndex:0] intValue];

              [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          } else {
              [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
                  CDVPluginResult *pluginResult;
                  if (status == FIRRemoteConfigFetchStatusSuccess) {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                  } else {
                      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                  }
                  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
              }];
          }
    }];
}

- (void)activateFetched:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
        FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
         [remoteConfig activateWithCompletionHandler:^(NSError * _Nullable error) {
             CDVPluginResult *pluginResult;
             if (error != nil) {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
             } else {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
             }
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }];
     }];
}

- (void)getValue:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* key = [command.arguments objectAtIndex:0];
        FIRRemoteConfig* remoteConfig = [FIRRemoteConfig remoteConfig];
        NSString* value = remoteConfig[key].stringValue;
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

# pragma mark - Performace
- (void)startTrace:(CDVInvokedUrlCommand *)command {

    [self.commandDelegate runInBackground:^{
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

    }];
}

- (void)incrementCounter:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
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

    }];
}

- (void)stopTrace:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
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
    }];
}

- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
        BOOL enabled = [[command argumentAtIndex:0] boolValue];

        [FIRAnalytics setAnalyticsCollectionEnabled:enabled];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)setPerformanceCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
         BOOL enabled = [[command argumentAtIndex:0] boolValue];

         [[FIRPerformance sharedInstance] setDataCollectionEnabled:enabled];

         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
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

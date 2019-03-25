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

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation FirebasePlugin

@synthesize notificationCallbackId;
@synthesize tokenRefreshCallbackId;
@synthesize notificationStack;
@synthesize traces;

static NSInteger const kNotificationStackSize = 10;
static FirebasePlugin *firebasePlugin;

+ (FirebasePlugin *) firebasePlugin {
    return firebasePlugin;
}

- (void)pluginInitialize {
    NSLog(@"Starting Firebase plugin");
    firebasePlugin = self;

	// For Crashlytics: this enables the browser to correctly detect the error stack
	// Ref: https://bugs.webkit.org/show_bug.cgi?id=154916
	// Ref: https://stackoverflow.com/questions/36013645/setting-disable-web-security-and-allow-file-access-from-files-in-ios-wkwebvi
	NSString* allowFileAccess = [self.commandDelegate.settings objectForKey:[@"FirebasePluginAllowFileAccess" lowercaseString]];
    if ([self.webView isKindOfClass:WKWebView.class] && [allowFileAccess isEqualToString:@"true"]){
        WKWebView *wkWebView = (WKWebView *) self.webView;
        [wkWebView.configuration.preferences setValue:@"true" forKey:@"allowFileAccessFromFileURLs"];
    }
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

// DEPRECATED - alias of getToken
- (void)getInstanceId:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[FIRInstanceID instanceID] token]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getToken:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[FIRInstanceID instanceID] token]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    BOOL enabled = NO;
    UIApplication *application = [UIApplication sharedApplication];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        enabled = application.currentUserNotificationSettings.types != UIUserNotificationTypeNone;
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        enabled = application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#pragma GCC diagnostic pop
    }

    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:1];
    [message setObject:[NSNumber numberWithBool:enabled] forKey:@"isEnabled"];
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)grantPermission:(CDVInvokedUrlCommand *)command {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        if ([[UIApplication sharedApplication]respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType notificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma GCC diagnostic pop
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:authOptions
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {

            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[FIRMessaging messaging] setDelegate:self];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: granted ? CDVCommandStatus_OK : CDVCommandStatus_ERROR];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                });
            } else {
                [[FIRMessaging messaging] setDelegate:self];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    ];
#else
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
#endif

    return;
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

    [self.commandDelegate runInBackground:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getBadgeNumber:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        long badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:badge];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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

- (void)onNotificationOpen:(CDVInvokedUrlCommand *)command {
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
    NSString* currentToken = [[FIRInstanceID instanceID] token];

    if (currentToken != nil) {
        [self sendToken:currentToken];
    }
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
		NSString* name           = [command.arguments objectAtIndex:0];
        NSDictionary* parameters = [command.arguments objectAtIndex:1];

         [FIRAnalytics logEventWithName:name parameters:parameters];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* errorMessage = [command.arguments objectAtIndex:0];
        CLSNSLog(@"%@", errorMessage);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logMessage:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        NSString* message = [command argumentAtIndex:0 withDefault:@""];
        if(message)
        {
            CLSNSLog(@"%@",message);
        }
    }];
}

-(void)sendNonFatalCrash:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        // Ref: https://firebase.google.com/docs/reference/swift/crashlytics/api/reference/Classes#/c:objc(cs)CLSStackFrame


        NSString *message = NSLocalizedString([command argumentAtIndex:0 withDefault:@"Unknown error"], nil);
        NSArray *lines    = [command argumentAtIndex:1 withDefault:[[NSArray alloc] init] ];
        NSString *domain  = NSLocalizedString([command argumentAtIndex:2 withDefault:[[NSBundle mainBundle] bundleIdentifier]], nil);


        NSMutableArray *stack = [[NSMutableArray alloc] init];

        for (NSDictionary *data in lines) {
            NSString *filename = [data valueForKey:@"fileName"];
            NSInteger *lineNumber = [[data valueForKey:@"lineNumber"] integerValue];
            NSInteger *offset  = [[data valueForKey:@"columnNumber"] integerValue];
            NSString *symbol  = [data valueForKey:@"source"];
            NSString *library = [data valueForKey:@"functionName"];
            // int *address = [data valueForKey:@"fileName"];

            // NSLog(filename);
            CLSStackFrame *line = [[CLSStackFrame alloc] init];
            line.fileName   = filename;
            line.lineNumber = (int) lineNumber;
            line.offset     = (int) offset;
            line.symbol     = symbol;
            line.library    = library;
            // line.address    = 0;

            [stack addObject:line];
        }

        [CrashlyticsKit recordCustomExceptionName:domain reason:message frameArray:stack];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];
}

- (void)recordError:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        // NSString *description = NSLocalizedString([command argumentAtIndex:0 withDefault:@"No Message Provided"], nil);
        // NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
        NSDictionary* userInfo = [command.arguments objectAtIndex:0];
        NSNumber *defaultCode = [NSNumber numberWithInt:-1];
        int code = [[command argumentAtIndex:1 withDefault:defaultCode] intValue];
        NSString *domain = NSLocalizedString([command argumentAtIndex:2 withDefault:[[NSBundle mainBundle] bundleIdentifier]], nil); // [[NSBundle mainBundle] bundleIdentifier];


        NSError *error = [NSError errorWithDomain: domain code: code userInfo: userInfo];

        [CrashlyticsKit recordError:error];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)sendCrash:(CDVInvokedUrlCommand*)command{
    [[Crashlytics sharedInstance] crash];
}

- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* userId = [command.arguments objectAtIndex:0];

        [CrashlyticsKit setUserIdentifier:userId];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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
         BOOL activated = [remoteConfig activateFetched];
         CDVPluginResult *pluginResult;

         if (activated) {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         } else {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
         }

         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

//
// Performace
//

- (void)isPerformanceEnabled:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: [FIRPerformance sharedInstance].isInstrumentationEnabled && [FIRPerformance sharedInstance].isDataCollectionEnabled ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enabeldPerformance:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSNumber *enabled = [command.arguments objectAtIndex:0];
        if([enabled isEqual: @(YES)]){
            [FIRPerformance sharedInstance].instrumentationEnabled = YES;
            [FIRPerformance sharedInstance].dataCollectionEnabled = YES;
        }else{
            [FIRPerformance sharedInstance].instrumentationEnabled = NO;
            [FIRPerformance sharedInstance].dataCollectionEnabled = NO;
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

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

- (void)incrementMetric:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
		NSString* traceName = [command.arguments objectAtIndex:0];
        NSString* counterNamed = [command.arguments objectAtIndex:1];
        int64_t* increment = (int64_t)[command.arguments objectAtIndex:2];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        FIRTrace *trace = (FIRTrace*)[self.traces objectForKey:traceName];

        if (trace != nil) {
            [trace incrementMetric:counterNamed byInt:increment];
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

-(void)startTraceHTTP:(CDVInvokedUrlCommand *)command{
    [self.commandDelegate runInBackground:^{

        if ( self.httpTraces == nil) {
            self.httpTraces = [NSMutableDictionary new];
        }

        NSString *url = [command.arguments objectAtIndex:0];
        NSString *method = [command.arguments objectAtIndex:1];
        long requestPayloadSize = [[command.arguments objectAtIndex:2] longValue];

        method = [method uppercaseString];
        FIRHTTPMethod aMethod = false;

        if ( [method isEqualToString:@"GET"] ){
            aMethod = FIRHTTPMethodGET;
        }else if ( [method isEqualToString:@"PUT"] ){
            aMethod = FIRHTTPMethodPUT;
        }else if ( [method isEqualToString:@"POST"] ){
            aMethod = FIRHTTPMethodPOST;
        }else if ( [method isEqualToString:@"DELETE"] ){
            aMethod = FIRHTTPMethodDELETE;
        }else if ( [method isEqualToString:@"HEAD"] ){
            aMethod = FIRHTTPMethodHEAD;
        }else if ( [method isEqualToString:@"PATCH"] ){
            aMethod = FIRHTTPMethodPATCH;
        }else if ( [method isEqualToString:@"OPTIONS"] ){
            aMethod = FIRHTTPMethodOPTIONS;
        }else if ( [method isEqualToString:@"TRACE"] ){
            aMethod = FIRHTTPMethodTRACE;
        }else if ( [method isEqualToString:@"CONNECT"] ){
            aMethod = FIRHTTPMethodCONNECT;
        }

        @try {
            FIRHTTPMetric *metric = [[FIRHTTPMetric alloc] initWithURL:[NSURL URLWithString:url] HTTPMethod:aMethod];
            if ( requestPayloadSize > 0 )
                [metric setRequestPayloadSize:requestPayloadSize];
            [metric start];

            NSString *traceName = [metric description];

            [self.httpTraces setObject:metric forKey:traceName ];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:traceName];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        @catch (NSException *exception) {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The HTTP method is not compatible"] callbackId:command.callbackId];
        }


    }];
}

-(void)stopTraceHTTP:(CDVInvokedUrlCommand *)command{
    [self.commandDelegate runInBackground:^{

        NSString *traceId = [command.arguments objectAtIndex:0];
        NSInteger statusCode = [[command.arguments objectAtIndex:1] integerValue];
        NSString *contentType = [command.arguments objectAtIndex:2];
        long responsePayloadSize = [[command.arguments objectAtIndex:3] longValue];

        FIRHTTPMetric *metric = [self.httpTraces objectForKey:traceId];
        if ( metric != nil ){
            [metric setResponseCode:statusCode];
            [metric setResponseContentType:contentType];
            if ( responsePayloadSize > 0 )
                [metric setResponsePayloadSize:responsePayloadSize];
            [metric stop];
            [self.httpTraces removeObjectForKey:traceId];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Trace not found"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }

    }];
}

- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand *)command {
     [self.commandDelegate runInBackground:^{
        BOOL enabled = [[command argumentAtIndex:0] boolValue];

        [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:enabled];
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
	[self.commandDelegate runInBackground:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
@end

#import "FirebasePlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import "Firebase.h"
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;


@implementation FirebasePlugin

CDVInvokedUrlCommand *onNotificationOpenCommand = nil;
NSMutableArray *onNotificationOpenBuffer;

- (void)pluginInitialize {
    NSLog(@"Starting Firebase plugin");
    
    onNotificationOpenBuffer = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) applicationDidFinishLaunching:(NSNotification *) notification {    
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [FIRApp configure];
}

- (void)applicationDidBecomeActive:(NSNotification *)application {
    [self connectToFcm];
}

- (void)applicationDidEnterBackground:(NSNotification *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

- (void)getInstanceId:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:
                    [[FIRInstanceID instanceID] token]];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)grantPermission:(CDVInvokedUrlCommand *)command {
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setBadgeNumber:(CDVInvokedUrlCommand *)command {
    int number    = [[command.arguments objectAtIndex:0] intValue];

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

- (void)onNotificationOpen:(CDVInvokedUrlCommand *)command {
    onNotificationOpenCommand = command;

    if ([onNotificationOpenBuffer count]) {
        for (NSDictionary *userInfo in onNotificationOpenBuffer) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }

        [onNotificationOpenBuffer removeAllObjects];
    }
}

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* name = [command.arguments objectAtIndex:0];
        NSDictionary* parameters = [command.arguments objectAtIndex:1];
        
        [FIRAnalytics logEventWithName:name parameters:parameters];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.

    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

    // Pring full message.
    NSLog(@"%@", userInfo);

    if (onNotificationOpenCommand != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:onNotificationOpenCommand.callbackId];
    } else {
        // buffer messages until a callback has been registered
        [onNotificationOpenBuffer addObject:userInfo];
    }

    completionHandler(UIBackgroundFetchResultNoData);
}

@end

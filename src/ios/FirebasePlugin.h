#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;
@import FirebaseRemoteConfig;
@import FirebaseAuth;

@interface FirebasePlugin : CDVPlugin <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
+ (FirebasePlugin *) firebasePlugin;
- (void)getVerificationID:(CDVInvokedUrlCommand*)command;
- (void)getInstanceId:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)grantPermission:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)unregister:(CDVInvokedUrlCommand*)command;
- (void)onNotificationOpen:(CDVInvokedUrlCommand*)command;
- (void)onTokenRefresh:(CDVInvokedUrlCommand*)command;
- (void)sendNotification:(NSDictionary*)userInfo;
- (void)sendToken:(NSString*)token;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)setScreenName:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand*)command;
- (void)setUserProperty:(CDVInvokedUrlCommand*)command;
- (void)fetch:(CDVInvokedUrlCommand*)command;
- (void)activateFetched:(CDVInvokedUrlCommand*)command;
- (void)getValue:(CDVInvokedUrlCommand*)command;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *tokenRefreshCallbackId;
@property (nonatomic, retain) NSMutableArray *notificationStack;

@end

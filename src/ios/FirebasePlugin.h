#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
+ (FirebasePlugin *) firebasePlugin;
- (void)initFirebase:(CDVInvokedUrlCommand*)command;
- (void)initCrashlytics:(CDVInvokedUrlCommand*)command;
- (void)initAnalytics:(CDVInvokedUrlCommand*)command;
- (void)initPerformance:(CDVInvokedUrlCommand*)command;
- (void)getVerificationID:(CDVInvokedUrlCommand*)command;
- (void)verifyPhoneNumber:(CDVInvokedUrlCommand*)command;
- (void)getInstanceId:(CDVInvokedUrlCommand*)command;
- (void)getId:(CDVInvokedUrlCommand*)command;
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
- (void)logError:(CDVInvokedUrlCommand*)command;
- (void)setScreenName:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand*)command;
- (void)setUserProperty:(CDVInvokedUrlCommand*)command;
- (void)fetch:(CDVInvokedUrlCommand*)command;
- (void)activateFetched:(CDVInvokedUrlCommand*)command;
- (void)getValue:(CDVInvokedUrlCommand*)command;
- (void)startTrace:(CDVInvokedUrlCommand*)command;
- (void)incrementCounter:(CDVInvokedUrlCommand*)command;
- (void)stopTrace:(CDVInvokedUrlCommand*)command;
- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)setPerformanceCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *tokenRefreshCallbackId;
@property (nonatomic, retain) NSMutableArray *notificationStack;
@property (nonatomic, readwrite) NSMutableDictionary* traces;
@property (atomic, assign) BOOL crashlyticsInit;
@property (atomic, assign) BOOL analyticsInit;
@property (atomic, assign) BOOL remoteconfigInit;
@property (atomic, assign) BOOL performanceInit;

@end

#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
+ (FirebasePlugin *) firebasePlugin;

- (void)verifyPhoneNumber:(CDVInvokedUrlCommand*)command;
- (void)signInWithCredential:(CDVInvokedUrlCommand*)command;
- (void)linkUserWithCredential:(CDVInvokedUrlCommand*)command;
- (void)getId:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)getAPNSToken:(CDVInvokedUrlCommand*)command;
- (NSString *)hexadecimalStringFromData:(NSData *)data;
- (void)grantPermission:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)unregister:(CDVInvokedUrlCommand*)command;
- (void)setAutoInitEnabled:(CDVInvokedUrlCommand*)command;
- (void)isAutoInitEnabled:(CDVInvokedUrlCommand*)command;
- (void)onMessageReceived:(CDVInvokedUrlCommand*)command;
- (void)onTokenRefresh:(CDVInvokedUrlCommand*)command;
- (void)onApnsTokenReceived:(CDVInvokedUrlCommand *)command;
- (void)sendNotification:(NSDictionary*)userInfo;
- (void)sendToken:(NSString*)token;
- (void)sendApnsToken:(NSString*)token;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)logError:(CDVInvokedUrlCommand*)command;
- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand*)command;
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
- (void)setCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command;
- (void)logMessage:(CDVInvokedUrlCommand*)command;
- (void)sendCrash:(CDVInvokedUrlCommand*)command;

- (void) handlePluginExceptionWithContext: (NSException*) exception :(CDVInvokedUrlCommand*)command;
- (void) handlePluginExceptionWithoutContext: (NSException*) exception;
- (void)_logError: (NSString*)msg;

- (void)createChannel:(CDVInvokedUrlCommand *)command;
- (void)setDefaultChannel:(CDVInvokedUrlCommand *)command;
- (void)deleteChannel:(CDVInvokedUrlCommand *)command;
- (void)listChannels:(CDVInvokedUrlCommand *)command;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *tokenRefreshCallbackId;
@property (nonatomic, copy) NSString *apnsTokenRefreshCallbackId;
@property (nonatomic, retain) NSMutableArray *notificationStack;
@property (nonatomic, readwrite) NSMutableDictionary* traces;

@end

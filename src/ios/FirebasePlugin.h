#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
+ (FirebasePlugin *) firebasePlugin;
- (void)getInstanceId:(CDVInvokedUrlCommand*)command;
- (void)grantPermission:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)onNotificationOpen:(CDVInvokedUrlCommand*)command;
- (void)sendNotification:(NSDictionary*)userInfo;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand*)command;
- (void)setUserProperty:(CDVInvokedUrlCommand*)command;

@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSMutableArray *notificationStack;

@end

#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
- (void)getInstanceId:(CDVInvokedUrlCommand*)command;
- (void)grantPermission:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)onNotificationOpen:(CDVInvokedUrlCommand*)command;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
@end

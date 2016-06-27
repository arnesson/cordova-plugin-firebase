#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
- (void)getInstanceId:(CDVInvokedUrlCommand*)command;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
@end

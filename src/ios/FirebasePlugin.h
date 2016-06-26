#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
- (void)getRegistrationId:(CDVInvokedUrlCommand*)command;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
@end

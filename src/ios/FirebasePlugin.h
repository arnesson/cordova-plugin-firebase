#import <Cordova/CDV.h>
#import "AppDelegate.h"

@interface FirebasePlugin : CDVPlugin
- (void)getRegistrationId:(CDVInvokedUrlCommand*)command;
@end

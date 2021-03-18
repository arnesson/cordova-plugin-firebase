#import "FirebasePluginMessageReceiver.h"

@interface FirebasePluginMessageReceiverManager : NSObject
+ (void) register:(FirebasePluginMessageReceiver *)receiver;
+ (bool) sendNotification:(NSDictionary *)userInfo;
@end

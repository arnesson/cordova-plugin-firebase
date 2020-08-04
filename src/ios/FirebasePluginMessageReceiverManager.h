#import "FirebasePluginMessageReceiver.h"

@interface FirebasePluginMessageReceiverManager
+ (void) register:(FirebasePluginMessageReceiver *)receiver;
+ (bool) sendNotification:(NSDictionary *)userInfo;
@end

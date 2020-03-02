#import <Foundation/Foundation.h>

@interface FirebasePluginMessageReceiver : NSObject {}
- (bool) sendNotification:(NSDictionary *)userInfo;
@end

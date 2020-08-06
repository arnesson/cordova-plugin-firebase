#import "FirebasePluginMessageReceiver.h"
#import "FirebasePluginMessageReceiverManager.h"

@implementation FirebasePluginMessageReceiver

- (id) init {
    [FirebasePluginMessageReceiverManager register:self];
    return self;
}

// Concrete subclasses should override this and return true if they handle the received message.
- (bool) sendNotification:(NSDictionary *)userInfo {
    NSAssert(false, @"You cannot call sendNotification on the FirebasePluginMessageReceiver class directly. Instead, you must override it using a subclass.");
    return false;
}

@end

#import "FirebasePluginMessageReceiverManager.h"

@implementation FirebasePluginMessageReceiverManager

static NSMutableArray* receivers;

+ (void) register:(FirebasePluginMessageReceiver*)receiver {
    if(receivers == nil){
        receivers = [[NSMutableArray alloc] init];
    }
    [receivers addObject:receiver];
}

+ (bool) sendNotification:(NSDictionary *)userInfo {
    bool handled = false;
    for(FirebasePluginMessageReceiver* receiver in receivers){
        bool wasHandled = [receiver sendNotification:userInfo];
        if(wasHandled){
            handled = true;
        }
    }
    return handled;
}
@end

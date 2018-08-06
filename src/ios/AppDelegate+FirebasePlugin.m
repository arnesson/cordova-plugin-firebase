#import "AppDelegate+FirebasePlugin.h"
#import "FirebasePlugin.h"
#import "Firebase.h"
#import <objc/runtime.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices running iOS 10 and above.
@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end
#else
// Implement FIRMessagingDelegate to receive data message via FCM for devices running iOS 9 and below.
@interface AppDelegate () <FIRMessagingDelegate>
@end
#endif

#define kApplicationInBackgroundKey @"applicationInBackground"
#define kDelegateKey @"delegate"

@implementation AppDelegate (FirebasePlugin)

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)setDelegate:(id)delegate {
    objc_setAssociatedObject(self, kDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)delegate {
    return objc_getAssociatedObject(self, kDelegateKey);
}

#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![FIRApp defaultApp] && FirebasePlugin.firebasePlugin.firebaseInit) {
        [FIRApp configure];
    }
    if ([FIRApp defaultApp]) {
      // Register for remote notifications. This shows a permission dialog on first run, to
      // show the dialog at a more appropriate time move this registration accordingly.
      // [START register_for_notifications]
      if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
      } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
      }
    }

    [application registerForRemoteNotifications];
    return YES;
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);

    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    [FirebasePlugin.firebasePlugin sendToken:refreshedToken];
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            NSString *refreshedToken = [[FIRInstanceID instanceID] token];
            NSLog(@"InstanceID token: %@", refreshedToken);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *mutableUserInfo = [userInfo mutableCopy];

    // Pring full message.
    NSLog(@"%@", mutableUserInfo);

    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    NSDictionary *mutableUserInfo = [userInfo mutableCopy];

    // Pring full message.
    NSLog(@"%@", mutableUserInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
}

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
    [FirebasePlugin.firebasePlugin sendNotification:remoteMessage.appData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Unable to register for remote notifications: %@", error);
}

// [END ios_10_data_message]
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    [self.delegate userNotificationCenter:center
              willPresentNotification:notification
                withCompletionHandler:completionHandler];

    if (![notification.request.trigger isKindOfClass:UNPushNotificationTrigger.class])
        return;

    NSDictionary *mutableUserInfo = [notification.request.content.userInfo mutableCopy];

    [mutableUserInfo setValue:self.applicationInBackground forKey:@"tap"];

    // Print full message.
    NSLog(@"%@", mutableUserInfo);

    completionHandler(UNNotificationPresentationOptionAlert);
    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
}

- (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    [self.delegate userNotificationCenter:center
       didReceiveNotificationResponse:response
                withCompletionHandler:completionHandler];

    if (![response.notification.request.trigger isKindOfClass:UNPushNotificationTrigger.class])
        return;

    NSDictionary *mutableUserInfo = [response.notification.request.content.userInfo mutableCopy];

    [mutableUserInfo setValue:@YES forKey:@"tap"];

    // Print full message.
    NSLog(@"Response %@", mutableUserInfo);

    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];

    completionHandler();
}

// Receive data message on iOS 10 devices.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
    NSLog(@"%@", [remoteMessage appData]);
}
#endif

@end

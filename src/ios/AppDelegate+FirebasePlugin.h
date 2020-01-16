#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>

@import UserNotifications;

@interface AppDelegate (FirebasePlugin) <UIApplicationDelegate, GIDSignInDelegate>
@property (nonatomic, strong) NSNumber * _Nonnull applicationInBackground;
@property (NS_NONATOMIC_IOSONLY, nullable, weak) id <UNUserNotificationCenterDelegate> delegate;
@end

#import "FIRCrashLog.h"

FIR_SWIFT_NAME(Crash)
@interface FIRCrash : NSObject

/**
 * FirebaseCrash instance using the default FIRApp.
 */
+ (FIRCrash *)sharedInstance NS_SWIFT_NAME(sharedInstance());

/**
 * Is crash reporting enabled? If crash reporting was previously enabled, the exception handler will
 * remain installed, but crashes will not be transmitted.
 *
 * This setting is persisted, and is applied on future invocations of your application. Once
 * explicitly set, it overrides any settings in your Info.plist.
 *
 * By default, crash reporting is enabled. If you need to change the default (for example, because
 * you want to prompt the user before collecting crashes) set firebase_crash_enabled to false in
 * your application's Info.plist.
 */
@property(nonatomic, assign, getter=isCrashCollectionEnabled) BOOL crashCollectionEnabled;

@end

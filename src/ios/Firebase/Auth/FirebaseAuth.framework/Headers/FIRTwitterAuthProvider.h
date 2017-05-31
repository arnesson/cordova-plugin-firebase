/** @file FIRTwitterAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/**
    @brief A string constant identifying the Twitter identity provider.
 */
extern NSString *const FIRTwitterAuthProviderID FIR_SWIFT_NAME(TwitterAuthProviderID);

/** @class FIRTwitterAuthProvider
    @brief Utility class for constructing Twitter credentials.
 */
FIR_SWIFT_NAME(TwitterAuthProvider)
@interface FIRTwitterAuthProvider : NSObject

/** @fn credentialWithToken:secret:
    @brief Creates an @c FIRAuthCredential for a Twitter sign in.

    @param token The Twitter OAuth token.
    @param secret The Twitter OAuth secret.
    @return A FIRAuthCredential containing the Twitter credential.
 */
+ (FIRAuthCredential *)credentialWithToken:(NSString *)token secret:(NSString *)secret;

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

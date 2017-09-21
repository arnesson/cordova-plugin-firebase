/** @file FIRFacebookAuthProvider.h
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
    @brief A string constant identifying the Facebook identity provider.
 */
extern NSString *const FIRFacebookAuthProviderID FIR_SWIFT_NAME(FacebookAuthProviderID);

/** @class FIRFacebookAuthProvider
    @brief Utility class for constructing Facebook credentials.
 */
FIR_SWIFT_NAME(FacebookAuthProvider)
@interface FIRFacebookAuthProvider : NSObject

/** @fn credentialWithAccessToken:
    @brief Creates an @c FIRAuthCredential for a Facebook sign in.

    @param accessToken The Access Token from Facebook.
    @return A FIRAuthCredential containing the Facebook credentials.
 */
+ (FIRAuthCredential *)credentialWithAccessToken:(NSString *)accessToken;

/** @fn init
    @brief This class should not be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

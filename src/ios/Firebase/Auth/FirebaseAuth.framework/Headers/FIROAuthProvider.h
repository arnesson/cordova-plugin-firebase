/** @file FIROAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @class FIROAuthProvider
    @brief A concrete implementation of @c FIRAuthProvider for generic OAuth Providers.
 */
FIR_SWIFT_NAME(OAuthProvider)
@interface FIROAuthProvider : NSObject

/** @fn credentialWithProviderID:IDToken:accessToken:
    @brief Creates an @c FIRAuthCredential for that OAuth 2 provider identified by providerID, ID
        token and access token.

    @param providerID The provider ID associated with the Auth credential being created.
    @param IDToken The IDToken associated with the Auth credential being created.
    @param accessToken The accessstoken associated with the Auth credential be created, if
        available.
    @return A FIRAuthCredential for the specified provider ID, ID token and access token.
 */
+ (FIRAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                        IDToken:(NSString *)IDToken
                                    accessToken:(nullable NSString *)accessToken;


/** @fn credentialWithProviderID:accessToken:
    @brief Creates an @c FIRAuthCredential for that OAuth 2 provider identified by providerID using
      an ID token.

    @param providerID The provider ID associated with the Auth credential being created.
    @param accessToken The accessstoken associated with the Auth credential be created
    @return A FIRAuthCredential.
 */
+ (FIRAuthCredential *)credentialWithProviderID:(NSString *)providerID
                                    accessToken:(NSString *)accessToken;

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

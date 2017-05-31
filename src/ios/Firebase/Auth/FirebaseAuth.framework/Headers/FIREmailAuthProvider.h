/** @file FIREmailAuthProvider.h
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
    @brief A string constant identifying the email & password identity provider.
 */
extern NSString *const FIREmailAuthProviderID FIR_SWIFT_NAME(EmailAuthProviderID);

/**
    @brief please use @c FIREmailAuthProviderID instead.
 */
extern NSString *const FIREmailPasswordAuthProviderID __attribute__((deprecated));

/** @class FIREmailAuthProvider
    @brief A concrete implementation of @c FIRAuthProvider for Email & Password Sign In.
 */
FIR_SWIFT_NAME(EmailAuthProvider)
@interface FIREmailAuthProvider : NSObject

/** @typedef FIREmailPasswordAuthProvider
    @brief Please use @c FIREmailAuthProvider instead.
 */
typedef FIREmailAuthProvider FIREmailPasswordAuthProvider __attribute__((deprecated));


/** @fn credentialWithEmail:password:
    @brief Creates an @c FIRAuthCredential for an email & password sign in.

    @param email The user's email address.
    @param password The user's password.
    @return A FIRAuthCredential containing the email & password credential.
 */
+ (FIRAuthCredential *)credentialWithEmail:(NSString *)email password:(NSString *)password;

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

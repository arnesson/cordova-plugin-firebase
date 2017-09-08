/** @file FIRUserInfo.h
    @brief Firebase Auth SDK
    @copyright Copyright 2015 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

NS_ASSUME_NONNULL_BEGIN

/**
    @brief Represents user data returned from an identity provider.
 */
FIR_SWIFT_NAME(UserInfo)
@protocol FIRUserInfo <NSObject>

/** @property providerID
    @brief The provider identifier.
 */
@property(nonatomic, copy, readonly) NSString *providerID;

/** @property uid
    @brief The provider's user ID for the user.
 */
@property(nonatomic, copy, readonly) NSString *uid;

/** @property displayName
    @brief The name of the user.
 */
@property(nonatomic, copy, readonly, nullable) NSString *displayName;

/** @property photoURL
    @brief The URL of the user's profile photo.
 */
@property(nonatomic, copy, readonly, nullable) NSURL *photoURL;

/** @property email
    @brief The user's email address.
 */
@property(nonatomic, copy, readonly, nullable) NSString *email;

/** @property phoneNumber
    @brief A phone number associated with the user.
    @remarks This property is only available for users authenticated via phone number auth.
 */
@property(nonatomic, readonly, nullable) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END

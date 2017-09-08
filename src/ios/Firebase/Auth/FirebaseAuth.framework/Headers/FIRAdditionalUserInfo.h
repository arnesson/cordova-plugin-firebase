/** @file FIRAdditionalUserInfo.h
    @brief Firebase Auth SDK
    @copyright Copyright 2017 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
    https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

@class FIRVerifyAssertionResponse;

NS_ASSUME_NONNULL_BEGIN

/** @class FIRAdditionalUserInfo
    @brief Represents additional user data returned from an identity provider.
 */
FIR_SWIFT_NAME(AdditionalUserInfo)
@interface FIRAdditionalUserInfo : NSObject

/** @fn init
    @brief This class should not be initialized manually. @c FIRAdditionalUserInfo can be retrieved
        from @c FIRAuthDataResult .
 */
- (instancetype)init NS_UNAVAILABLE;

/** @property providerID
    @brief The provider identifier.
 */
@property(nonatomic, readonly) NSString *providerID;

/** @property profile
    @brief profile Dictionary containing the additional IdP specific information.
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSObject *> *profile;

/** @property username
    @brief username The name of the user.
 */
@property(nonatomic, readonly, nullable) NSString *username;

/** @property newUser
    @brief Indicates whether or not the current user was signed in for the first time.
 */
@property(nonatomic, readonly, getter=isNewUser) BOOL newUser;

@end

NS_ASSUME_NONNULL_END

/** @file FIRAuthDataResult.h
    @brief Firebase Auth SDK
    @copyright Copyright 2017 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
    https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

@class FIRAdditionalUserInfo;
@class FIRUser;

NS_ASSUME_NONNULL_BEGIN

/** @class FIRAuthDataResult
    @brief Helper object that contains the result of a successful sign-in, link and reauthenticate.
        It contains a reference to a @c FIRUser and @c FIRAdditionalUserInfo.
 */
FIR_SWIFT_NAME(AuthDataResult)
@interface FIRAuthDataResult : NSObject

/** @fn init
    @brief This class should not be initialized manually. @c FIRAuthDataResult instance is
        returned as part of @c FIRAuthDataResultCallback .
 */
- (instancetype)init NS_UNAVAILABLE;

/** @property user
    @brief The signed in user.
 */
@property(nonatomic, readonly) FIRUser *user;

/** @property additionalUserInfo
    @brief If available contains the additional IdP specific information about signed in user.
 */
@property(nonatomic, readonly, nullable) FIRAdditionalUserInfo *additionalUserInfo;

@end

NS_ASSUME_NONNULL_END

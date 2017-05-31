/** @file FIRPhoneAuthCredential.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthCredential.h"
#import "FIRAuthSwiftNameSupport.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FIRPhoneAuthCredential
    @brief Implementation of FIRAuthCredential for Phone Auth credentials.
 */
FIR_SWIFT_NAME(PhoneAuthCredential)
@interface FIRPhoneAuthCredential : FIRAuthCredential

/** @fn init
    @brief This class is not supposed to be instantiated directly.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

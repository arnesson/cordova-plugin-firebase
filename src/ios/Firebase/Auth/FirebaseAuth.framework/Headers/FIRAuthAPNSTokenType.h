/** @file FIRAuthAPNSTokenType.h
    @brief Firebase Auth SDK
    @copyright Copyright 2017 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import "FIRAuthSwiftNameSupport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief The APNs token type for the app.
 */
typedef NS_ENUM(NSInteger, FIRAuthAPNSTokenType) {

  /** Unknown token type.
      The actual token type will be detected from the provisioning profile in the app's bundle.
   */
  FIRAuthAPNSTokenTypeUnknown,

  /** Sandbox token type.
   */
  FIRAuthAPNSTokenTypeSandbox,

  /** Production token type.
   */
  FIRAuthAPNSTokenTypeProd,
} FIR_SWIFT_NAME(AuthAPNSTokenType);

NS_ASSUME_NONNULL_END

//
//  FIRInvitesError.h
//  Firebase Invites SDK
//
//  Copyright 2016 Google Inc.
//
//  Use of this SDK is subject to the Google APIs Terms of Service:
//  https://developers.google.com/terms
//
//  Detailed instructions to use this SDK can be found at:
//  https://developers.google.com/app-invites
//

#import <Foundation/Foundation.h>

#import "FIRInvitesSwiftNameSupport.h"

/// Error domain for errors returned by the invite dialog.
extern NSString *const kFIRInvitesErrorDomain
    FIR_SWIFT_NAME(InvitesErrorDomain);

/// Possible error codes returned by the invite dialog.
typedef NS_ENUM(NSInteger, FIRInvitesErrorCode) {
  /// Unknown error.
  FIRInvitesErrorCodeUnknown = -400,
  /// Invite is cancelled.
  FIRInvitesErrorCodeCanceled = -401,
  /// Invite is cancelled by user.
  FIRInvitesErrorCodeCanceledByUser = -402,
  /// Launch error.
  FIRInvitesErrorCodeLaunchError = -403,
  /// Sign in error.
  FIRInvitesErrorCodeSignInError = -404,
  /// Server error.
  FIRInvitesErrorCodeServerError = -490,
  /// Network error.
  FIRInvitesErrorCodeNetworkError = -491,
  /// SMS error.
  FIRInvitesErrorCodeSMSError = -492,
  /// Invalid parameters error.
  FIRInvitesErrorCodeInvalidParameters = -497,
} FIR_SWIFT_NAME(InvitesErrorCode);

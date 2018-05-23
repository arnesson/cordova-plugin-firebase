//
//  FIRInvites.h
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

@class FIRInvitesTargetApplication;

NS_ASSUME_NONNULL_BEGIN

/// An enum that represents the match type of an invitation.
typedef NS_ENUM(NSUInteger, FIRReceivedInviteMatchType) {
  /// The match between the deeplink and this device may not be perfect, hence you should not reveal
  /// any personal information related to the deep link.
  FIRReceivedInviteMatchTypeWeak,
  /// The match between the deeplink and this device is exact, hence you could reveal any personal
  /// information related to the deep link.
  FIRReceivedInviteMatchTypeStrong
} FIR_SWIFT_NAME(ReceivedInviteMatchType);

/// The class that represents a received invitation.
FIR_SWIFT_NAME(ReceivedInvite)
@interface FIRReceivedInvite : NSObject

/// The invite ID that was passed to the app.
@property(nonatomic, copy, readonly) NSString *inviteId;

/// The deep link that was passed to the app.
@property(nonatomic, copy, readonly) NSString *deepLink;

/// The match type of the received invitation.
@property(nonatomic, assign, readonly) FIRReceivedInviteMatchType matchType;

@end

/**
 * @abstract The definition of the block used by |handleUniversalLink:completion:|
 */
typedef void (^FIRInvitesUniversalLinkHandler)(FIRReceivedInvite * _Nullable receivedInvite,
                                                   NSError * _Nullable error)
  FIR_SWIFT_NAME(InvitesUniversalLinkHandler);

@class GINInviteTargetApplication;

/// The protocol to receive the result of the invite action.
FIR_SWIFT_NAME(InviteDelegate)
@protocol FIRInviteDelegate <NSObject>

@optional
/// Reports the status of the invite action.
/// |invitationsIds| holds the IDs of the invitations sent by the user.
/// |error| is nil upon success. Otherwise, it will contain one of the errors defined in
/// FIRInvitesError.h.
- (void)inviteFinishedWithInvitations:(NSArray <NSString *> *)invitationIds
                                error:(nullable NSError *)error;

@end

/// The protocol to configure the invite dialog.
FIR_SWIFT_NAME(InviteBuilder)
@protocol FIRInviteBuilder <NSObject>

/// Sets the delegate object that will receive callbacks after the invite dialog closes.
- (void)setInviteDelegate:(id<FIRInviteDelegate>)inviteDelegate;

/// Sets the title of the navigation bar of the invite dialog.
- (void)setTitle:(NSString *)title;

/// Sets the default message to use for the invitation. This is the message that will be sent
/// in the invite, for e.g., via SMS or email. This message must not exceed 100 characters.
/// The message will be modifiable by the user. Maximum length is 100 characters.
- (void)setMessage:(NSString *)message;

/// Sets the deepLink for the invitation. |deepLink| is an identifier that your app defines for use
/// across all supported platforms. It will be passed with the invitation to the receiver.
/// You can use it to present customized view when the user receives an invitation in your app.
- (void)setDeepLink:(NSString *)deepLink;

/// A user may send invites from iOS to users on other platforms, for e.g., users on Android.
/// Sets |FIRInvitesTargetApplication| to specify the non-iOS application that must be installed or
/// opened when a user acts on an invite on that platform.
- (void)setOtherPlatformsTargetApplication:(FIRInvitesTargetApplication *)targetApplication;

/// Sets the app description displayed in email invitations (max 1000 characters), but it is
/// no longer supported in Firebase App Invites.
- (void)setDescription:(NSString *)description
      __deprecated_msg("setDescription is no longer supported in Firebase App Invites.");

/// Sets an image for invitations. The imageURI is required to be in absolute format. The URI can
/// be either a content URI with extension "jpg" or "png", or a network url with scheme "https".
- (void)setCustomImage:(NSString *)imageURI;

/// Sets the text shown on the email invitation button to install the app. Default install
/// text used if not set. Maximum length is 32 characters.
- (void)setCallToActionText:(NSString *)callToActionText;

/// Sets the minimum version of the android app installed on the receiving device. If this
/// minimum version is not installed then the install flow will be triggered.
/// Note that the version code should not be zero.
- (void)setAndroidMinimumVersionCode:(NSInteger)versionCode;

/// Opens the invite dialog.
- (void)open;

@end

/// The main entry point for the invite APIs.
FIR_SWIFT_NAME(Invites)
@interface FIRInvites : NSObject

/// App Invite requires defining the client ID if the invite is received on a different platform
/// than iOS. If an Android client ID is defined in the GoogleService-Info.plist, the targetApp will
/// automatically be configured by calling [FIRApp configure] as a target app for new invites. This
/// property allows retrieving a copy of that |GINInviteTargetApplication|.
@property(nonatomic) FIRInvitesTargetApplication *targetApp;

/// Performs initial setup after the application launches. You should call this method in
/// |application:didFinishLaunchingWithOptions:| method.
/// For backward compatibility, launchOptions may nil. If nil, the invitation may appear twice
/// on iOS 9 if a user clicks on a link before opening the app.
+ (void)applicationDidFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

/// Legacy method to performs initial setup after the application launches.
/// You should call |applicationDidFinishLaunchingWithOptions:| instead.
+ (void)applicationDidFinishLaunching
    __deprecated_msg("Call |applicationDidFinishLaunchingWithOptions:| instead.");

/// This method should be called from your |UIApplicationDelegate|'s
/// |application:openURL:sourceApplication:annotation|.
/// sourceApplication and annotation may nil, and there will be no side effects.
/// Returns a |FIRReceivedInvite| instance if the URL is an invite deeplink.
+ (nullable id)handleURL:(NSURL *)url
       sourceApplication:(nullable NSString *)sourceApplication
              annotation:(nullable id)annotation
__deprecated_msg("Use |handleUniversalLink:completion:| instead.");

/**
 * @method handleUniversalLink:completion:
 * @abstract Convenience method to handle a Universal Link whether it is long or short. A long link
 *     will call the handler immediately, but a short link may not.
 * @param URL A Universal Link URL.
 * @param completion A block that handles the outcome of attempting to create a FIRReceivedInvite.
 * @return YES if FIRInvites is handling the link, otherwise, NO.
 */
+ (BOOL)handleUniversalLink:(NSURL *)URL
                 completion:(FIRInvitesUniversalLinkHandler)completion;

/// Sends google analytics data after the invitation flow is completed. You could call this
/// method in your application after you obtain a |FIRReceivedInvite| instance in
// |application:openURL:sourceApplication:annotation|.
+ (void)completeInvitation __deprecated_msg("No longer need to call.");

/// Marks an invitation as converted. You should call this method in your application after the user
/// performs an action that represents a successful conversion.
+ (void)convertInvitation:(NSString *)invitationId;

/// Returns a invite dialog builder instance. Calls |open| method to create the dialog after
/// setting the parameters as needed.
+ (nullable id<FIRInviteBuilder>)inviteDialog;

/// Closes the active invite dialog immediately, if one exists.
/// Note that it is usually not necessary to call this method, as the invite dialog closes itself
/// once the invite action has completed either successfully or with an error. Only call this method
/// when you need to interrupt the user in the middle of inviting.
+ (void)closeActiveInviteDialog;

/// Sets the API key for API access.
+ (void)setAPIKey:(NSString *)apiKey;

/// Sets the Google Analytics tracking Id. This is an optional method that you can use to
/// overwrite the value of the tracking Id. If this method is not called, we will use the tracking
/// Id set on the default Google Analytics tracker.
+ (void)setGoogleAnalyticsTrackingId:(NSString *)trackingId;

/// Sets the default |FIRInvitesTargetApplication| to be used in the |GINInviteBuilder|.
+ (void)setDefaultOtherPlatformsTargetApplication:(FIRInvitesTargetApplication *)targetApplication;

@end

NS_ASSUME_NONNULL_END

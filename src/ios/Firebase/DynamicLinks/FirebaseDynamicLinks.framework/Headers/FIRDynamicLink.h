#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @file FIRDynamicLink.h
 * @abstract Dynamic Link object used in Firebase Dynamic Links.
 */

/**
 * @abstract The confidence level of the matched Dynamic Link.
 */
typedef NS_ENUM(NSUInteger, FIRDynamicLinkMatchConfidence) {
  /**
   * The match between the Dynamic Link and this device may not be perfect, hence you should not
   *    reveal any personal information related to the Dynamic Link.
   */
  FIRDynamicLinkMatchConfidenceWeak,
  /**
   * The match between the Dynamic Link and this device is exact, hence you may reveal personal
   *     information related to the Dynamic Link.
   */
  FIRDynamicLinkMatchConfidenceStrong
} NS_SWIFT_NAME(DynamicLinkMatchConfidence)
    DEPRECATED_MSG_ATTRIBUTE("Use FIRDLMatchType instead.");

/**
 * @abstract The match type of the Dynamic Link.
 */
typedef NS_ENUM(NSUInteger, FIRDLMatchType) {
  /**
   * The match has not been achieved.
   */
  FIRDLMatchTypeNone,
  /**
   * The match between the Dynamic Link and this device may not be perfect, hence you should not
   *    reveal any personal information related to the Dynamic Link.
   */
  FIRDLMatchTypeWeak,
  /**
   * The match between the Dynamic Link and this device has high confidence but small possibility of
   *    error still exist.
   */
  FIRDLMatchTypeDefault,
  /**
   * The match between the Dynamic Link and this device is exact, hence you may reveal personal
   *     information related to the Dynamic Link.
   */
  FIRDLMatchTypeUnique,
} NS_SWIFT_NAME(DLMatchType);

/**
 * @class FIRDynamicLink
 * @abstract A received Dynamic Link.
 */
NS_SWIFT_NAME(DynamicLink)
@interface FIRDynamicLink : NSObject

/**
 * @property url
 * @abstract The URL that was passed to the app.
 */
@property(nonatomic, copy, readonly, nullable) NSURL *url;

/**
 * @property matchConfidence
 * @abstract The match confidence of the received Dynamic Link.
 */
@property(nonatomic, assign, readonly)
    FIRDynamicLinkMatchConfidence matchConfidence DEPRECATED_MSG_ATTRIBUTE(
        "Use FIRDynamicLink.matchType (DynamicLink.DLMatchType) instead.");

/**
 * @property matchType
 * @abstract The match type of the received Dynamic Link.
 */
@property(nonatomic, assign, readonly) FIRDLMatchType matchType;

/**
 * @property minimumAppVersion
 * @abstract The minimum iOS application version that supports the Dynamic Link. This is retrieved
 *     from the imv= parameter of the Dynamic Link URL. Note: This is not the minimum iOS system
 *     version, but the minimum app version. If app version of the opening app is less than the
 *     value of this property, than app expected to open AppStore to allow user to download most
 *     recent version. App can notify or ask user before opening AppStore.
 */
@property(nonatomic, copy, readonly, nullable) NSString *minimumAppVersion;

@end

NS_ASSUME_NONNULL_END

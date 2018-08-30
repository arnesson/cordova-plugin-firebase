#import <Foundation/Foundation.h>

@class FIRDynamicLink;

NS_ASSUME_NONNULL_BEGIN

/**
 * @file FIRDynamicLinksCommon.h
 * @abstract Commonly shared definitions within Firebase Dynamic Links.
 */

/**
 * @abstract The definition of the block used by |resolveShortLink:completion:|
 */
typedef void (^FIRDynamicLinkResolverHandler)(NSURL * _Nullable url, NSError * _Nullable error)
    NS_SWIFT_NAME(DynamicLinkResolverHandler);

/**
 * @abstract The definition of the block used by |handleUniversalLink:completion:|
 */
typedef void (^FIRDynamicLinkUniversalLinkHandler)(FIRDynamicLink * _Nullable dynamicLink,
                                                   NSError * _Nullable error)
    NS_SWIFT_NAME(DynamicLinkUniversalLinkHandler);

NS_ASSUME_NONNULL_END

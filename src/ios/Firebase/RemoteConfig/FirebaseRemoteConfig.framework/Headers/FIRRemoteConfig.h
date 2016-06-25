//
//  FIRRemoteConfig.h
//  Firebase Remote Config service SDK
//  Copyright 2016 Google Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

/// The Firebase Remote Config service default namespace, to be used if the API method does not
/// specify a different namespace. Use the default namespace if configuring from the Google Firebase
/// service.
extern NSString *const __nonnull FIRNamespaceGoogleMobilePlatform;

/// Key used to manage throttling in NSError user info when the refreshing of Remote Config
/// parameter values (data) is throttled. The value of this key is the elapsed time since 1970,
/// measured in seconds.
extern NSString *const __nonnull FIRRemoteConfigThrottledEndTimeInSecondsKey;

/// Indicates whether updated data was successfully fetched.
typedef NS_ENUM(NSInteger, FIRRemoteConfigFetchStatus) {
  FIRRemoteConfigFetchStatusNoFetchYet,
  FIRRemoteConfigFetchStatusSuccess,
  FIRRemoteConfigFetchStatusFailure,
  FIRRemoteConfigFetchStatusThrottled,
};

/// Remote Config error domain that handles errors when fetching data from the service.
extern NSString *const __nonnull FIRRemoteConfigErrorDomain;
/// Firebase Remote Config service fetch error.
typedef NS_ENUM(NSInteger, FIRRemoteConfigError) {
  /// Unknown or no error.
  FIRRemoteConfigErrorUnknown = 8001,
  /// Frequency of fetch requests exceeds throttled limit.
  FIRRemoteConfigErrorThrottled = 8002,
  /// Internal error that covers all internal HTTP errors.
  FIRRemoteConfigErrorInternalError = 8003,
};

/// Enumerated value that indicates the source of Remote Config data. Data can come from
/// the Remote Config service, the DefaultConfig that is available when the app is first installed,
/// or a static initialized value if data is not available from the service or DefaultConfig.
typedef NS_ENUM(NSInteger, FIRRemoteConfigSource) {
  FIRRemoteConfigSourceRemote,   ///< The data source is the Remote Config service.
  FIRRemoteConfigSourceDefault,  ///< The data source is the DefaultConfig defined for this app.
  FIRRemoteConfigSourceStatic,   ///< The data doesn't exist, return a static initialized value.
};

/// Completion handler invoked by fetch methods when they get a response from the server.
///
/// @param status Config fetching status.
/// @param error  Error message on failure.
typedef void (^FIRRemoteConfigFetchCompletion)(FIRRemoteConfigFetchStatus status,
                                               NSError *__nullable error);

#pragma mark - FIRRemoteConfigValue
@interface FIRRemoteConfigValue : NSObject<NSCopying>
@property(nonatomic, readonly, nullable) NSString *stringValue;
@property(nonatomic, readonly, nullable) NSNumber *numberValue;
@property(nonatomic, readonly, nonnull) NSData *dataValue;
@property(nonatomic, readonly) BOOL boolValue;
@property(nonatomic, readonly) FIRRemoteConfigSource source;
@end

#pragma mark - FIRRemoteConfigSettings
@interface FIRRemoteConfigSettings : NSObject
@property(nonatomic, readonly) BOOL isDeveloperModeEnabled;
/// Initializes FIRRemoteConfigSettings, which is used to set properties for custom settings. To
/// make custom settings take effect, pass the FIRRemoteConfigSettings instance to the
/// configSettings property of FIRRemoteConfig.
- (nullable FIRRemoteConfigSettings *)initWithDeveloperModeEnabled:(BOOL)developerModeEnabled
    NS_DESIGNATED_INITIALIZER;
@end

#pragma mark - FIRRemoteConfig
@interface FIRRemoteConfig : NSObject<NSFastEnumeration>
/// Last long fetch completion time.
@property(nonatomic, readonly, strong, nullable) NSDate *lastFetchTime;
/// Last fetch status. The status can be any enumerated value from FIRRemoteConfigFetchStatus.
@property(nonatomic, readonly, assign) FIRRemoteConfigFetchStatus lastFetchStatus;
/// Config settings are custom settings.
@property(nonatomic, readwrite, strong, nonnull) FIRRemoteConfigSettings *configSettings;

/// Returns the FIRRemoteConfig instance shared throughout your app. This singleton object contains
/// the complete set of Remote Config parameter values available to the app, including the Active
/// Config and Default Config. This object also caches values fetched from the Remote Config Server
/// until they are copied to the Active Config by calling activateFetched.
/// When you fetch values from the Remote Config Server using the default Firebase namespace
/// service, you should use this class method to create a shared instance of the FIRRemoteConfig
/// object to ensure that your app will function properly with the Remote Config Server and the
/// Firebase service.
+ (nonnull FIRRemoteConfig *)remoteConfig NS_SWIFT_NAME(remoteConfig());

/// Unavailable. Use +RemoteConfig instead.
- (nonnull instancetype)init __attribute__((unavailable("Use +remoteConfig instead.")));

#pragma mark - Fetch
/// Fetches Remote Config data with a callback.
/// @param completionHandler Fetch operation callback.
- (void)fetchWithCompletionHandler:(nullable FIRRemoteConfigFetchCompletion)completionHandler;

/// Fetches Remote Config data and sets a duration that specifies how long config data lasts.
/// @param expirationDuration  Duration that defines how long fetched config data is available, in
///                            seconds. When the config data expires, a new fetch is required.
/// @param completionHandler   Fetch operation callback.
- (void)fetchWithExpirationDuration:(NSTimeInterval)expirationDuration
                  completionHandler:(nullable FIRRemoteConfigFetchCompletion)completionHandler;

#pragma mark - Apply
/// Applies fetched Config data to Active Config, causing updates to the behavior and appearance of
/// the app to take effect (depending on how config data is used in the app).
/// Returns true if FetchedConfig has been applied to RemoteConfig or if there is no FetchedConfig.
/// Returns false if FetchedConfig is newer than RemoteConfig.
- (BOOL)activateFetched;

#pragma mark - Get Config
/// Enables access to configuration values by using object subscripting syntax.
/// This is used to get the config value of the default namespace.
/// <pre>
/// // Example:
/// FIRRemoteConfig *config = [FIRRemoteConfig remoteConfig];
/// FIRRemoteConfigValue *value = config[@"yourKey"];
/// BOOL b = value.boolValue;
/// NSNumber *number = config[@"yourKey"].numberValue;
/// </pre>
- (nonnull FIRRemoteConfigValue *)objectForKeyedSubscript:(nonnull NSString *)key;

/// Gets the config value of the default namespace.
/// @param key Config key.
- (nonnull FIRRemoteConfigValue *)configValueForKey:(nullable NSString *)key;

/// Gets the config value of a given namespace.
/// @param key              Config key.
/// @param aNamespace       Config results under a given namespace.
- (nonnull FIRRemoteConfigValue *)configValueForKey:(nullable NSString *)key
                                          namespace:(nullable NSString *)aNamespace;

/// Gets the config value of a given namespace and a given source.
/// @param key              Config key.
/// @param aNamespace       Config results under a given namespace.
/// @param source           Config value source.
- (nonnull FIRRemoteConfigValue *)configValueForKey:(nullable NSString *)key
                                          namespace:(nullable NSString *)aNamespace
                                             source:(FIRRemoteConfigSource)source;

/// Gets all the parameter keys from a given source and a given namespace.
///
/// @param source           The config data source.
/// @param aNamespace       The config data namespace.
/// @return                 An array of keys under the given source and namespace.
- (nonnull NSArray *)allKeysFromSource:(FIRRemoteConfigSource)source
                             namespace:(nullable NSString *)aNamespace;

#pragma mark - Defaults
/// Sets config defaults for parameter keys and values in the default namespace config.
///
/// @param defaultConfig    A dictionary mapping a NSString * key to a NSObject * value.
- (void)setDefaults:(nullable NSDictionary<NSString *, NSObject *> *)defaults;

/// Sets config defaults for parameter keys and values in the default namespace config.
///
/// @param defaultConfig    A dictionary mapping a NSString * key to a NSObject * value.
/// @param aNamespace       Config under a given namespace.
- (void)setDefaults:(nullable NSDictionary<NSString *, NSObject *> *)defaultConfig
          namespace:(nullable NSString *)aNamespace;

/// Sets default configs from plist for default namespace;
/// @param fileName The plist file name, with no file name extension. For example, if the plist file
///                 is defaultSamples.plist, call:
///                 [[FIRRemoteConfig remoteConfig] setDefaultsFromPlistFileName:@"defaultSamples"];
- (void)setDefaultsFromPlistFileName:(nullable NSString *)fileName;

/// Sets default configs from plist for a given namespace;
/// @param fileName The plist file name, with no file name extension. For example, if the plist file
///                 is defaultSamples.plist, call:
///                 [[FIRRemoteConfig remoteConfig] setDefaultsFromPlistFileName:@"defaultSamples"];
/// @param aNamespace The namespace where the default config is set.
- (void)setDefaultsFromPlistFileName:(nullable NSString *)fileName
                           namespace:(nullable NSString *)aNamespace;

/// Returns the default value of a given key. Returns nil if the key doesn't exist in DefaultConfig.
- (nullable FIRRemoteConfigValue *)defaultValueForKey:(nullable NSString *)key
                                            namespace:(nullable NSString *)aNamespace;

@end

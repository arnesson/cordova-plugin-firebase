#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import "Firebase.h"
@import FirebaseFirestore;

@interface FirebasePlugin : CDVPlugin

- (void)setAutoInitEnabled:(CDVInvokedUrlCommand*)command;
- (void)isAutoInitEnabled:(CDVInvokedUrlCommand*)command;

// Authentication
- (void)verifyPhoneNumber:(CDVInvokedUrlCommand*)command;
- (void)createUserWithEmailAndPassword:(CDVInvokedUrlCommand*)command;
- (void)signInUserWithEmailAndPassword:(CDVInvokedUrlCommand*)command;
- (void)authenticateUserWithGoogle:(CDVInvokedUrlCommand*)command;
- (void)authenticateUserWithApple:(CDVInvokedUrlCommand*)command;
- (void)signInWithCredential:(CDVInvokedUrlCommand*)command;
- (void)linkUserWithCredential:(CDVInvokedUrlCommand*)command;
- (void)reauthenticateWithCredential:(CDVInvokedUrlCommand*)command;
- (void)isUserSignedIn:(CDVInvokedUrlCommand*)command;
- (void)signOutUser:(CDVInvokedUrlCommand*)command;
- (void)getCurrentUser:(CDVInvokedUrlCommand*)command;
- (void)updateUserProfile:(CDVInvokedUrlCommand*)command;
- (void)updateUserEmail:(CDVInvokedUrlCommand*)command;
- (void)sendUserEmailVerification:(CDVInvokedUrlCommand*)command;
- (void)updateUserPassword:(CDVInvokedUrlCommand*)command;
- (void)sendUserPasswordResetEmail:(CDVInvokedUrlCommand*)command;
- (void)deleteUser:(CDVInvokedUrlCommand*)command;

// Remote notifications
- (void)getId:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)getAPNSToken:(CDVInvokedUrlCommand*)command;
- (NSString *)hexadecimalStringFromData:(NSData *)data;
- (void)grantPermission:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)getBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)unregister:(CDVInvokedUrlCommand*)command;
- (void)onMessageReceived:(CDVInvokedUrlCommand*)command;
- (void)onTokenRefresh:(CDVInvokedUrlCommand*)command;
- (void)onApnsTokenReceived:(CDVInvokedUrlCommand *)command;
- (void)sendNotification:(NSDictionary*)userInfo;
- (void)sendToken:(NSString*)token;
- (void)sendApnsToken:(NSString*)token;
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command;

// Analytics
- (void)setAnalyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)isAnalyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)setScreenName:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand*)command;
- (void)setUserProperty:(CDVInvokedUrlCommand*)command;

// Crashlytics
- (void)setCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)isCrashlyticsCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)isCrashlyticsCollectionCurrentlyEnabled:(CDVInvokedUrlCommand*)command;
- (void)logError:(CDVInvokedUrlCommand*)command;
- (void)logMessage:(CDVInvokedUrlCommand*)command;
- (void)sendCrash:(CDVInvokedUrlCommand*)command;
- (void)setCrashlyticsUserId:(CDVInvokedUrlCommand*)command;

// Remote config
- (void)fetch:(CDVInvokedUrlCommand*)command;
- (void)activateFetched:(CDVInvokedUrlCommand*)command;
- (void)getValue:(CDVInvokedUrlCommand*)command;

// Performance
- (void)setPerformanceCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)isPerformanceCollectionEnabled:(CDVInvokedUrlCommand*)command;
- (void)startTrace:(CDVInvokedUrlCommand*)command;
- (void)incrementCounter:(CDVInvokedUrlCommand*)command;
- (void)stopTrace:(CDVInvokedUrlCommand*)command;

// Firestore
- (void)addDocumentToFirestoreCollection:(CDVInvokedUrlCommand*)command;
- (void)setDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command;
- (void)updateDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command;
- (void)deleteDocumentFromFirestoreCollection:(CDVInvokedUrlCommand*)command;
- (void)fetchDocumentInFirestoreCollection:(CDVInvokedUrlCommand*)command;
- (void)fetchFirestoreCollection:(CDVInvokedUrlCommand*)command;


// Internals
+ (FirebasePlugin *) firebasePlugin;
+ (NSString*) appleSignInNonce;
+ (void) setFirestore:(FIRFirestore*) firestoreInstance;
- (void) handlePluginExceptionWithContext: (NSException*) exception :(CDVInvokedUrlCommand*)command;
- (void) handlePluginExceptionWithoutContext: (NSException*) exception;
- (void) _logError: (NSString*)msg;
- (void) _logInfo: (NSString*)msg;
- (void) _logMessage: (NSString*)msg;
- (BOOL) _shouldEnableCrashlytics;
- (int) saveAuthCredential: (FIRAuthCredential *) authCredential;
- (void)executeGlobalJavascript: (NSString*)jsString;

- (void)createChannel:(CDVInvokedUrlCommand *)command;
- (void)setDefaultChannel:(CDVInvokedUrlCommand *)command;
- (void)deleteChannel:(CDVInvokedUrlCommand *)command;
- (void)listChannels:(CDVInvokedUrlCommand *)command;

@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *tokenRefreshCallbackId;
@property (nonatomic, copy) NSString *apnsTokenRefreshCallbackId;
@property (nonatomic, copy) NSString *googleSignInCallbackId;
@property (nonatomic, copy) NSString *appleSignInCallbackId;

@property (nonatomic, retain) NSMutableArray *notificationStack;
@property (nonatomic, readwrite) NSMutableDictionary* traces;

@end

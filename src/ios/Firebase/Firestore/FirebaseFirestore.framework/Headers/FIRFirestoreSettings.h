/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Settings used to configure a `FIRFirestore` instance. */
NS_SWIFT_NAME(FirestoreSettings)
@interface FIRFirestoreSettings : NSObject <NSCopying>

/**
 * Creates and returns an empty `FIRFirestoreSettings` object.
 *
 * @return The created `FIRFirestoreSettings` object.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/** The hostname to connect to. */
@property(nonatomic, copy) NSString *host;

/** Whether to use SSL when connecting. */
@property(nonatomic, getter=isSSLEnabled) BOOL sslEnabled;

/**
 * A dispatch queue to be used to execute all completion handlers and event handlers. By default,
 * the main queue is used.
 */
@property(nonatomic, strong) dispatch_queue_t dispatchQueue;

/** Set to false to disable local persistent storage. */
@property(nonatomic, getter=isPersistenceEnabled) BOOL persistenceEnabled;

/**
 * Enables the use of FIRTimestamps for timestamp fields in FIRDocumentSnapshots.
 *
 * Currently, Firestore returns timestamp fields as an NSDate but NSDate is implemented as a double
 * which loses precision and causes unexpected behavior when using a timestamp from a snapshot as
 * a part of a subsequent query.
 *
 * Setting timestampsInSnapshotsEnabled to true will cause Firestore to return FIRTimestamp values
 * instead of NSDate, avoiding this kind of problem. To make this work you must also change any code
 * that uses NSDate to use FIRTimestamp instead.
 *
 * NOTE: in the future timestampsInSnapshotsEnabled = true will become the default and this option
 * will be removed so you should change your code to use FIRTimestamp now and opt-in to this new
 * behavior as soon as you can.
 */
@property(nonatomic, getter=areTimestampsInSnapshotsEnabled) BOOL timestampsInSnapshotsEnabled;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

#import "FIRPerformanceAttributable.h"

/**
 * FIRTrace objects contain information about a "Trace", which is a sequence of steps. Traces can be
 * used to measure the time taken for a sequence of steps.
 * Traces also include "Counters". Counters are used to track information which is cumulative in
 * nature (e.g., Bytes downloaded). Counters are scoped to an FIRTrace object.
 */
NS_EXTENSION_UNAVAILABLE("FirebasePerformance does not support app extensions at this time.")
NS_SWIFT_NAME(Trace)
@interface FIRTrace : NSObject <FIRPerformanceAttributable>

/** @brief Name of the trace. */
@property(nonatomic, copy, readonly, nonnull) NSString *name;

/** @brief Not a valid initializer. */
- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 * Starts the trace.
 */
- (void)start;

/**
 * Stops the trace if the trace is active.
 */
- (void)stop;

/**
 * Increments the counter for the provided counter name by 1. If it is a new counter name, the
 * counter value will be initialized to 1. Does nothing if the trace has not been started or has
 * already been stopped.
 *
 * @param counterName The name of the counter to increment.
 */
- (void)incrementCounterNamed:(nonnull NSString *)counterName
    NS_SWIFT_NAME(incrementCounter(named:));

/**
 * Increments the counter for the provided counter name with the provided value. If it is a new
 * counter name, the counter value will be initialized to the value. Does nothing if the trace has
 * not been started or has already been stopped.
 *
 * @param counterName The name of the counter to increment.
 * @param incrementValue The value the counter would be incremented with.
 */
- (void)incrementCounterNamed:(nonnull NSString *)counterName by:(NSInteger)incrementValue
    NS_SWIFT_NAME(incrementCounter(named:by:));

@end

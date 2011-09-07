//
//  Log.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	LogPriorityFatal = 0,
	LogPriorityError = 1,
	LogPriorityWarning = 2,
	LogPriorityInfo = 3,
	LogPriorityDebug = 4,
	LogPriorityVerbose = 5,
	LogPrioritySilent = 6
} LogMsgPriority;

typedef struct {
	NSString * message;
	LogMsgPriority priority;
} LogMsg;

LogMsg LogMsgMake (NSString * message, LogMsgPriority priority);

#define LogMsgMakeVerbose(x) (LogMsgMake(x, LogPriorityVerbose))
#define LogMsgMakeDebug(x) (LogMsgMake(x, LogPriorityDebug))
#define LogMsgMakeWarning(x) (LogMsgMake(x, LogPriorityWarning))
#define LogMsgMakeError(x) (LogMsgMake(x, LogPriorityError))

#define kLogInitialMaxVerbosity LogPriorityVerbose

void WALog (LogMsgPriority priority, NSString * msgFmt, ...);

/**
 * A generic logging facility that utilizes logging "priority."
 */
@interface Log : NSObject {
	LogMsgPriority maxVerbosity;
}

/**
 * Return the singleton Log object.
 */
+ (Log *)sharedLogFacility;

/**
 * Post a message to the log.
 */
- (void)postLogMessage:(LogMsg)msg;

/**
 * Check if the specified message will be printed.
 * @param msg The message to check.  The priority of this message is checked against
 * the max verbosity to determine the return value.
 */
- (BOOL)willPrintMessage:(LogMsg)msg;

/**
 * Change the maximum verbosity theshold.
 * @param priority The maximum (numerically) priority of message that should be printed.
 * For example, giving LogPriorityError will only allow for error and fatal messages
 * will be logged.
 */
- (void)setMaxVerbosity:(LogMsgPriority)priority;

@end

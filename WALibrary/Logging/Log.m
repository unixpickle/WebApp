//
//  Log.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import "Log.h"

LogMsg LogMsgMake (NSString * message, LogMsgPriority priority) {
	LogMsg msg;
	msg.message = message;
	msg.priority = priority;
	return msg;
}

void WALog (LogMsgPriority priority, NSString * msgFmt, ...) {
	va_list myList;
	va_start(myList, msgFmt);
	NSString * myString = [[NSString alloc] initWithFormat:msgFmt arguments:myList];
	va_end(myList);
	LogMsg aMsg = LogMsgMake(myString, priority);
	[[Log sharedLogFacility] postLogMessage:aMsg];
#if !__has_feature(objc_arc)
    [myString release];
#endif
}

@implementation Log

+ (Log *)sharedLogFacility {
	static Log * aLog = nil;
	if (!aLog) {
		aLog = [[Log alloc] init];
		[aLog setMaxVerbosity:kLogInitialMaxVerbosity];
	}
	return aLog;
}

- (id)init {
	if ((self = [super init])) {
		msgLock = [[NSLock alloc] init];
	}
	return self;
}

- (void)postLogMessage:(LogMsg)msg {
	static const struct {
#if !__has_feature(objc_arc)
        NSString * prefix;
#else
		__unsafe_unretained NSString * prefix;
#endif
		LogMsgPriority priority;
	} msgStrings[] = {
		{@"INFO", LogPriorityInfo},
		{@"DBUG", LogPriorityDebug},
		{@"ERRO", LogPriorityError},
		{@"FATL", LogPriorityFatal},
		{@"VRBS", LogPriorityVerbose},
		{@"WARN", LogPriorityWarning},
	};
	[msgLock lock];
	if ([self willPrintMessage:msg]) {
		NSString * prefix = @"SILENT ";
		for (int i = 0; i < 6; i++) {
			if (msgStrings[i].priority == msg.priority) {
				prefix = msgStrings[i].prefix;
			}
		}
		printf("[%s %s]: %s\n", [prefix UTF8String],
			   [[[NSDate date] description] UTF8String],
			   [msg.message UTF8String]);
	}
	[msgLock unlock];
}

- (BOOL)willPrintMessage:(LogMsg)msg {
	if (msg.priority <= maxVerbosity) {
		return YES;
	} else return NO;
}

- (void)setMaxVerbosity:(LogMsgPriority)priority {
	maxVerbosity = priority;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	[msgLock release];
	[super dealloc];
}
#endif

@end

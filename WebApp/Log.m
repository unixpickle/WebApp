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
	[myString release];
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

- (void)postLogMessage:(LogMsg)msg {
	if ([self willPrintMessage:msg]) {
		NSLog(@"%@", msg.message);
	}
}

- (BOOL)willPrintMessage:(LogMsg)msg {
	if (msg.priority <= maxVerbosity) {
		return YES;
	} else return NO;
}

- (void)setMaxVerbosity:(LogMsgPriority)priority {
	maxVerbosity = priority;
}

@end

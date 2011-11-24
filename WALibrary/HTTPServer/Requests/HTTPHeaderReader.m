//
//  HTTPHeaderReader.m
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPHeaderReader.h"

@implementation HTTPHeaderReader

- (id)initWithStream:(HTTPStream *)aStream {
	if ((self = [super init])) {
		stream = [aStream retain];
	}
	return self;
}

- (HTTPStream *)stream {
	return stream;
}

- (NSString *)readLine {
	NSTimeInterval timeLeft = kHeaderReadTimeout;
	NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:timeLeft];
	NSMutableString * string = [[NSMutableString alloc] init];
	while (timeLeft > 0) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSData * aChar = [stream readData:1 timeout:timeLeft];
		if (!aChar || [aChar length] == 0) {
			[string release];
			[pool drain];
			return nil;
		}
		char ascii = *((const char *)[aChar bytes]);
		if (ascii == '\n') {
			[pool drain];
			break;
		}
		if (isascii(ascii)) {
			if (ascii != '\r') {
				[string appendFormat:@"%c", ascii];
			}
		} else {
			[string release];
			[pool drain];
			return nil;
		}
		[pool drain];
		timeLeft = [endDate timeIntervalSinceNow];
	}
	
	if (timeLeft <= 0) {
		[string release];
		return nil;
	}
	
	NSString * immutable = [NSString stringWithString:string];
	[string release];
	return immutable;
}

- (BOOL)readField:(NSString **)fieldOut value:(NSString **)valueOut {
	NSString * string = [self readLine];
	if (!string) return NO;
	if ([string length] == 0) {
		if (fieldOut) *fieldOut = nil;
		if (valueOut) *valueOut = nil;
		return YES;
	}
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	NSRange colon = [string rangeOfString:@":"];
	if (colon.location == NSNotFound) {
		// not a valid header field
		return NO;
	}
	NSString * fieldName = [[string substringWithRange:NSMakeRange(0, colon.location)] stringByTrimmingCharactersInSet:whitespace];
	NSString * fieldValue = [[string substringFromIndex:colon.location + 1] stringByTrimmingCharactersInSet:whitespace];
	if (fieldOut) *fieldOut = fieldName;
	if (valueOut) *valueOut = fieldValue;
	return YES;
}

- (void)dealloc {
	[stream release];
	[super dealloc];
}

@end

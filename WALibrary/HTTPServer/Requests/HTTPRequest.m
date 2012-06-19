//
//  HTTPRequest.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#if __has_feature(objc_arc)
#define SETTER_IMPL(ivar, param) ivar = param;
#else
#define SETTER_IMPL(ivar, param) [ivar autorelease];\
	ivar = [param retain];
#endif

#import "HTTPRequest.h"

@interface HTTPRequest (Parsing)

- (BOOL)useHTTPRequestLine:(NSString *)line;

@end

@implementation HTTPRequest

- (id)initByReadingStream:(HTTPStream *)aStream {
	if ((self = [super init])) {
		// TODO: read first line of request!
		HTTPHeaderReader * headerReader = [(HTTPHeaderReader *)[HTTPHeaderReader alloc] initWithStream:aStream];
		NSString * httpRequestField = [headerReader readLine];
		
		if (!httpRequestField) {
#if !__has_feature(objc_arc)
			[headerReader release];
			[super dealloc];
#endif
			return nil;
		}
		
		if (![self useHTTPRequestLine:httpRequestField]) {
#if !__has_feature(objc_arc)
			[super dealloc];
#endif
			return nil;
		}
		
		NSString * nextKey = nil;
		NSString * nextVal = nil;
		BOOL terminated = NO;
		NSMutableDictionary * myHeaders = [[NSMutableDictionary alloc] init];
		while ([headerReader readField:&nextKey value:&nextVal]) {
			if (nextKey == nil && nextVal == nil) {
				terminated = YES;
				break;
			}
			[myHeaders setObject:nextVal forKey:nextKey];
		}
#if !__has_feature(objc_arc)
		[headerReader release];
#endif
		if (!terminated) {
#if !__has_feature(objc_arc)
			[myHeaders release];
			[self dealloc];
#endif
			return nil;
		}
		otherFields = [[NSDictionary alloc] initWithDictionary:myHeaders];
#if !__has_feature(objc_arc)
		[myHeaders release];
#endif
	}
	return self;
}

/** Getters **/

- (NSString *)requestPath {
	return requestPath;
}

- (NSString *)requestMethod {
	return requestMethod;
}

- (NSString *)httpVersion {
	return httpVersion;
}

- (NSDictionary *)otherFields {
	return otherFields;
}

/** Setters **/

- (void)setRequestPath:(NSString *)obj {
	SETTER_IMPL(requestPath, obj);
}

- (void)setRequestMethod:(NSString *)obj {
	SETTER_IMPL(requestMethod, obj);
}

- (void)setHttpVersion:(NSString *)obj {
	SETTER_IMPL(httpVersion, obj);
}

- (void)setOtherFields:(NSDictionary *)obj {
	SETTER_IMPL(otherFields, obj);
}

/** Special Getters **/

- (NSRange)rangeField {
	NSString * range = [otherFields objectForKey:@"Range"];
	NSRange rangeBytes = [range rangeOfString:@"bytes="];
	NSRange rangeOfDash = [range rangeOfString:@"-"];
	if (rangeBytes.location == NSNotFound || rangeOfDash.location == NSNotFound) {
		return NSMakeRange(NSNotFound, NSNotFound);
	}
	
	NSString * rangeStr = [range substringFromIndex:(rangeBytes.location + rangeBytes.length)];
	NSArray * comps = [rangeStr componentsSeparatedByString:@"-"];
	if ([comps count] != 2) {
		return NSMakeRange(NSNotFound, NSNotFound);
	}
	
	long long start = [[comps objectAtIndex:0] longLongValue];
	long long end = [[comps objectAtIndex:1] longLongValue];
	return NSMakeRange(start, end - start + 1);
}

/** Memory Management **/

#if !__has_feature(objc_arc)
- (void)dealloc {
	[self setRequestPath:nil];
	[self setRequestMethod:nil];
	[self setHttpVersion:nil];
	[self setOtherFields:nil];
	[super dealloc];
}
#endif

@end

@implementation HTTPRequest (Parsing)

- (BOOL)useHTTPRequestLine:(NSString *)line {
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	NSArray * components = [line componentsSeparatedByCharactersInSet:whitespace];
	if ([components count] != 3) {
		return NO;
	}
	
	NSString * versionString = [components objectAtIndex:2];
	if (![versionString hasPrefix:@"HTTP/"]) {
		return NO;
	}
	
	NSString * version = [versionString substringFromIndex:5];
	
	[self setRequestMethod:[components objectAtIndex:0]];
	[self setRequestPath:[[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[self setHttpVersion:version];
	return YES;
}

@end

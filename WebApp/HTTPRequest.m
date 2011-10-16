//
//  HTTPRequest.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#define SETTER_IMPL(ivar, param) [ivar autorelease];\
	ivar = [param retain];

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
			[headerReader release];
			[super dealloc];
			return nil;
		}
		
		if (![self useHTTPRequestLine:httpRequestField]) {
			[super dealloc];
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
		[headerReader release];
		if (!terminated) {
			[myHeaders release];
			[self dealloc];
			return nil;
		}
		otherFields = [[NSDictionary alloc] initWithDictionary:myHeaders];
		[myHeaders release];
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

/** Memory Management **/

- (void)dealloc {
	[self setRequestPath:nil];
	[self setRequestMethod:nil];
	[self setHttpVersion:nil];
	[self setOtherFields:nil];
	[super dealloc];
}

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
	[self setRequestPath:[components objectAtIndex:1]];
	[self setHttpVersion:version];
	return YES;
}

@end

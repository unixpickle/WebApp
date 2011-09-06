//
//  HTTPRequest.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import "HTTPRequest.h"

@implementation HTTPRequest

/** Getters **/

- (NSString *)requestPath {
	
}

- (NSString *)requestMethod {
	
}

- (NSString *)httpVersion {
	
}

- (NSDictionary *)otherFields {
	
}

/** Setters **/

- (void)setRequestPath:(NSString *)obj {
	
}

- (void)setRequestMethod:(NSString *)obj {
	
}

- (void)setHttpVersion:(NSString *)obj {
	
}

- (void)setOtherFields:(NSDictionary *)obj {
	
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

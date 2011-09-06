//
//  HTTPRequest.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPRequest : NSObject {
	NSString * requestPath;
	NSString * requestMethod;
	NSString * httpVersion;
	NSDictionary * otherFields;
}

// getters
- (NSString *)requestPath;
- (NSString *)requestMethod;
- (NSString *)httpVersion;
- (NSDictionary *)otherFields;

// setters
- (void)setRequestPath:(NSString *)obj;
- (void)setRequestMethod:(NSString *)obj;
- (void)setHttpVersion:(NSString *)obj;
- (void)setOtherFields:(NSDictionary *)obj;

@end

//
//  ServerExample.m
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerExample.h"

@implementation ServerExample

- (void)startExample:(int)port {
	NSError * error = nil;
	HTTPServer * server = [[HTTPServer alloc] initWithDelegate:self];
	if (![server beginServer:[NSNumber numberWithInt:port] error:&error]) {
		if (error) {
			WALog(LogPriorityFatal, @"Server failed: %@", error);
		} else {
			WALog(LogPriorityFatal, @"Server failed with no error.");
		}
	}
#if !__has_feature(objc_arc)
	[server release];
#endif
}

/* Server delegate */

- (HTTPContentProvider *)httpServer:(HTTPServer *)server providerForRequest:(HTTPRequest *)request {
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[request requestPath] isDirectory:&isDir]) {
		if (isDir) {
#if !__has_feature(objc_arc)
			return [[[DirectoryProvider alloc] initWithDirectory:[request requestPath]] autorelease];
#else
			return [[DirectoryProvider alloc] initWithDirectory:[request requestPath]];
#endif
		} else {
			if (![[request otherFields] objectForKey:@"Range"]) {
				WALog(LogPriorityDebug, @"Request: %@", [request otherFields]);
#if !__has_feature(objc_arc)
				return [[[FileProvider alloc] initWithFilePath:[request requestPath]] autorelease];
#else
				return [[FileProvider alloc] initWithFilePath:[request requestPath]];
#endif
			} else {
				WALog(LogPriorityDebug, @"Ranged Request: %@", [request otherFields]);
				NSRange range = [request rangeField];
				if (range.location == NSNotFound) {
#if !__has_feature(objc_arc)
					return [[[NotFoundProvider alloc] initWithRequest:request] autorelease];
#else
					return [[NotFoundProvider alloc] initWithRequest:request];
#endif
				} else {
#if !__has_feature(objc_arc)
					return [[[FileProvider alloc] initWithFilePath:[request requestPath] range:range] autorelease];
#else
					return [[FileProvider alloc] initWithFilePath:[request requestPath] range:range];
#endif
				}
			}
		}
	} else {
#if !__has_feature(objc_arc)
		return [[[NotFoundProvider alloc] initWithRequest:request] autorelease];
#else
		return [[NotFoundProvider alloc] initWithRequest:request];
#endif
	}
	return nil;
}

@end

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
	[server release];
}

/* Server delegate */

- (HTTPContentProvider *)httpServer:(HTTPServer *)server providerForRequest:(HTTPRequest *)request {
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[request requestPath] isDirectory:&isDir]) {
		if (isDir) {
			return [[[DirectoryProvider alloc] initWithDirectory:[request requestPath]] autorelease];
		} else {
			if (![[request otherFields] objectForKey:@"Range"]) {
				WALog(LogPriorityDebug, @"Request: %@", [request otherFields]);
				return [[[FileProvider alloc] initWithFilePath:[request requestPath]] autorelease];
			} else {
				WALog(LogPriorityDebug, @"Ranged Request: %@", [request otherFields]);
				NSRange range = [request rangeField];
				if (range.location == NSNotFound) {
					return [[[NotFoundProvider alloc] initWithRequest:request] autorelease];
				} else {
					return [[[FileProvider alloc] initWithFilePath:[request requestPath] range:range] autorelease];
				}
			}
		}
	} else {
		return [[[NotFoundProvider alloc] initWithRequest:request] autorelease];
	}
	return nil;
}

@end

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
			NSLog(@"Error: %@", error);
			WALog(LogPriorityFatal, @"Server failed: %@", error);
		} else {
			WALog(LogPriorityFatal, @"Server failed with no error.");
		}
	}
	[server release];
}

/* Server delegate */

- (HTTPContentProvider *)httpServer:(HTTPServer *)server providerForRequest:(HTTPRequest *)request {
	WALog(LogPriorityInfo, @"-httpServer:providerForRequest:");
	SimpleProvider * provider = [[SimpleProvider alloc] initWithRequest:request];
	return [provider autorelease];
}

@end

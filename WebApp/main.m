//
//  main.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerExample.h"

void sigpipeHandler (int i);

void sigpipeHandler (int i) {
	WALog(LogPriorityError, @"Received SIGPIPE: %d", i);
}

int main (int argc, const char * argv[]) {
#if !__has_feature(objc_arc)
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#else
    @autoreleasepool {
#endif
    
	signal(SIGPIPE, sigpipeHandler);
	
	[[Log sharedLogFacility] setMaxVerbosity:LogPriorityVerbose];
	ServerExample * example = [[ServerExample alloc] init];
	[example startExample:8080];

#if !__has_feature(objc_arc)
	[example release];
    [pool drain];
#else
    }
#endif
	return 0;
}


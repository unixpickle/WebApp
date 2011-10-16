//
//  main.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerExample.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	[[Log sharedLogFacility] setMaxVerbosity:LogPriorityVerbose];
	ServerExample * example = [[ServerExample alloc] init];
	[example startExample:8080];
	[example release];

	[pool drain];
	return 0;
}


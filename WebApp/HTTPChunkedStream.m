//
//  HTTPChunkedStream.m
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPChunkedStream.h"

@implementation HTTPChunkedStream

- (BOOL)writeData:(NSData *)theData {
	NSString * length = [NSString stringWithFormat:@"%X\r\n", [theData length]];
	NSMutableData * encoded = [[NSMutableData alloc] init];
	[encoded appendData:[length dataUsingEncoding:NSASCIIStringEncoding]];
	[encoded appendData:theData];
	[encoded appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	BOOL status = [super writeData:encoded];
	[encoded release];
	return status;
}

- (NSData *)readData:(ssize_t)length {
	// TODO: make this work!
	return nil;
}

- (NSData *)readData:(ssize_t)length timeout:(NSTimeInterval)time {
	// TODO: make this work!
	return nil;
}

- (void)closeStream {
	NSString * term = [NSString stringWithFormat:@"0\r\n"];
	[super writeData:[term dataUsingEncoding:NSASCIIStringEncoding]];
}

@end

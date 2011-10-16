//
//  HTTPStream.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import "HTTPStream.h"

@interface HTTPStream (Private)

- (NSData *)readIndefiniteData:(ssize_t)length timeout:(NSTimeInterval)aTime;

@end

@implementation HTTPStream

- (id)initWithSocket:(int)fileDescriptor {
	if ((self = [super init])) {
		socket = fileDescriptor;
		ivarLock = [[NSLock alloc] init];
		isOpen = YES;
	}
	return self;
}

- (int)fileDescriptor {
	BOOL flag = NO;
	[ivarLock lock];
	flag = socket;
	[ivarLock unlock];
	return flag;
}

- (BOOL)isOpen {
	BOOL flag = NO;
	[ivarLock lock];
	flag = isOpen;
	[ivarLock unlock];
	return flag;
}

- (BOOL)writeData:(NSData *)theData {
	const char * buffer = (const char *)[theData bytes];
	ssize_t written = 0;
	while (written < [theData length]) {
		ssize_t justWrote = -1;
		if ((justWrote = write([self fileDescriptor], &buffer[written], ([theData length] - written))) < 0) {
			if (errno != EINTR) {
				[self closeStream];
				return NO;
			}
		} else {
			written += justWrote;
		}
	}
	return YES;
}

- (NSData *)readData:(ssize_t)length {
	char * buff = (char *)malloc(length);
	ssize_t hasRead = 0;
	while (hasRead < length) {
		ssize_t got = -1;
		if ((got = (int)read([self fileDescriptor], &buff[hasRead], (length - hasRead))) < 0) {
			if (errno != EINTR) {
				[self closeStream];
				return [NSData dataWithBytesNoCopy:buff length:hasRead freeWhenDone:YES];
			}
		} else {
			hasRead += got;
		}
	}
	return [NSData dataWithBytesNoCopy:buff length:hasRead freeWhenDone:YES];
}

- (NSData *)readData:(ssize_t)length timeout:(NSTimeInterval)aTime {
	NSDate * endTime = [NSDate dateWithTimeIntervalSinceNow:aTime];
	NSMutableData * data = [[NSMutableData alloc] init];
	
	while ([data length] < length) {
		NSTimeInterval timeLeft = [endTime timeIntervalSinceNow];
		if (timeLeft < 0) {
			return data;
		}
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSData * someData = [self readIndefiniteData:(length - [data length]) timeout:timeLeft];
		if (!someData) {
			[pool drain];
			[data release];
			return nil;
		}
		[data appendData:someData];
		[pool drain];
	}
	
	NSData * immutable = [NSData dataWithData:data];
	[data release];
	return immutable;
}

- (void)closeStream {
	[ivarLock lock];
	if (socket >= 0) close(socket);
	socket = -1;
	isOpen = NO;
	[ivarLock unlock];
}

- (void)dealloc {
	[ivarLock release];
	[super dealloc];
}

@end

@implementation HTTPStream (Private)

- (NSData *)readIndefiniteData:(ssize_t)length timeout:(NSTimeInterval)aTime {
	fd_set sockSet;
	struct timeval delay;
	char * buff;
	ssize_t readLen;
	delay.tv_sec = round(aTime);
	delay.tv_usec = round(1000000.0 * (aTime - floor(aTime)));
	FD_ZERO(&sockSet);
	FD_SET([self fileDescriptor], &sockSet);
	if (aTime > 0) {
		if (select([self fileDescriptor] + 1, &sockSet, NULL, NULL, &delay) <= 0) {
			if (errno == EINTR) {
				return [self readData:length timeout:aTime];
			}
			return nil;
		}
	} else {
		if (select([self fileDescriptor] + 1, &sockSet, NULL, NULL, NULL) <= 0) {
			if (errno == EINTR) {
				return [self readData:length timeout:aTime];
			}
			return nil;
		}
	}
	buff = (char *)malloc(length);
	if ((readLen = read([self fileDescriptor], buff, length)) <= 0) {
		if (errno != EINTR) {
			free(buff);
			[self closeStream];
			return nil;
		} else {
			free(buff);
			return [self readData:length timeout:aTime];
		}
	}
	return [NSData dataWithBytesNoCopy:buff length:readLen freeWhenDone:YES];
}

@end

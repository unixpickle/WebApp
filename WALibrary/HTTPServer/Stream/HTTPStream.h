//
//  HTTPStream.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCHelper.h"

@class HTTPStream;

@protocol HTTPStreamWrapper

- (id)initWithStream:(HTTPStream *)aStream;

@end

/**
 * An abstract class for a data stream between the HTTP client and server.
 */
@interface HTTPStream : NSObject {
	int socket;
	BOOL isOpen;
	NSLock * ivarLock;
}

/**
 * Create a stream with a given network socket.
 * @return A new HTTP stream, or nil if the socket is invalid.
 */
- (id)initWithSocket:(int)fileDescriptor;

/**
 * Returns the underlying file descriptor of the stream.
 */
- (int)fileDescriptor;

/**
 * @return YES if the socket is open, NO otherwise.
 */
- (BOOL)isOpen;

/**
 * Write data to the stream.
 * @return YES if the data was written, NO if the write failed.
 */
- (BOOL)writeData:(NSData *)theData;

/**
 * Read data from the stream.  If reading is not available, nil shall be returned.
 * @return Data of the specified length, or less if EOF was reached.
 */
- (NSData *)readData:(ssize_t)length;

/**
 * Reads data from the stream; fails on a timeout.
 * @param length The number of bytes to read.
 * @param time The time to wait before "giving up." If this is zero,
 * the read operation will never time out.
 * @return Data of the specified length, or less if a timeout or EOF was encountered.
 */
- (NSData *)readData:(ssize_t)length timeout:(NSTimeInterval)time;

/**
 * Close the stream.  This may or may not close the underlying socket.
 * This will not automatically be called by -dealloc.
 */
- (void)closeStream;

@end

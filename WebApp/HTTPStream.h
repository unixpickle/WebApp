//
//  HTTPStream.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An abstract class for a data stream between the HTTP client and server.
 */
@interface HTTPStream : NSObject {
	
}

/**
 * Write data to the stream.
 */
- (void)writeData:(NSData *)theData;

/**
 * Read data from the stream.  If reading is not available, nil shall be returned.
 */
- (NSData *)readData:(int)length;

/**
 * Close the stream.  This may or may not close the underlying socket.
 */
- (void)closeStream;

@end

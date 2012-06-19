//
//  HTTPServer.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Log.h"
#import "HTTPContentProvider.h"
#import "HTTPChunkedStream.h"
#import "HTTPRequest.h"
#import "NSError+Message.h"
#import "ARCHelper.h"

// network-related imports
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h> 
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

@class HTTPServer;

@protocol HTTPServerDelegate

- (HTTPContentProvider *)httpServer:(HTTPServer *)server providerForRequest:(HTTPRequest *)request;

@end

@interface HTTPServer : NSObject {
	id<HTTPServerDelegate> delegate;
	
	// private ivars
	BOOL isServerClosed;
	NSLock * closedLock;
}

/**
 * Create an HTTP server with a specified delegate.
 */
- (id)initWithDelegate:(id<HTTPServerDelegate>)aDelegate;

/**
 * Start the HTTP server.  This method will not return unless a fatal
 * error occurs or the server is killed.
 *
 * @param portObj A port number.  This parameter is an object rather than
 * a primitive so that the method is easier to use with NSThreading.
 *
 * @param error An error (returned by reference).  This will only be changed
 * if the method returns NO.
 *
 * @return YES if the server was shutdown and no error occured.  NO if an
 * error occured.  If this is NO, the error argument will be set.
 */
- (BOOL)beginServer:(NSNumber *)portObj error:(NSError **)error;

/**
 * A thread-safe method that kills the server.  After this is called,
 * the -beginServer: method will return.
 */
- (void)closedownServer;

/**
 * @return The delegate of the HTTP server.
 */
- (id<HTTPServerDelegate>)delegate;

@end

//
//  HTTPServer.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import "HTTPServer.h"

@interface HTTPServer (Private)

// atomic set/get methods
- (BOOL)isServerClosed;
- (void)setIsServerClosed:(BOOL)flag;

@end

@implementation HTTPServer

- (id)initWithDelegate:(id<HTTPServerDelegate>)aDelegate {
	if ((self = [super init])) {
		delegate = aDelegate;
		closedLock = [[NSLock alloc] init];
		isServerClosed = NO;
	}
	return self;
}

- (BOOL)beginServer:(NSNumber *)portObj error:(NSError **)error {
	// We need a global pool for this thread (if this runs in the background).
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self setIsServerClosed:NO];
	// start a socket server
	struct sockaddr_in servAddr;
	struct sockaddr_in cliAddr;
	int server = socket(AF_INET, SOCK_STREAM, 0);
	int cliSock;
	socklen_t cliLen;
	struct linger l;
	bzero(&servAddr, sizeof(struct sockaddr_in));
	servAddr.sin_family = AF_INET;
	servAddr.sin_addr.s_addr = INADDR_ANY;
	servAddr.sin_port = htons([portObj unsignedShortValue]);
	// bind the socket to the address
	if (bind(server, (struct sockaddr *)&servAddr, sizeof(struct sockaddr_in)) < 0) {
		*error = [NSError errorWithDomain:@"bind" code:errno message:@"Failed to bind()."];
		[pool drain];
		return NO;
	}
	if (listen(server, 5) < 0) {
		*error = [NSError errorWithDomain:@"listen" code:errno message:@"Failed to listen()."];
		[pool drain];
		return NO;
	}
	
	WALog(LogPriorityInfo, @"Listening on port: %d", servAddr.sin_port);
	
	// disable linger
	l.l_onoff = 1;
	l.l_linger = 0;
	if (setsockopt(server, SOL_SOCKET, SO_KEEPALIVE | SO_LINGER, &l, sizeof(struct linger)) < 0) {
		WALog(LogPriorityWarning, @"Failed to disable SO_LINGER and SO_KEEPALIVE");
	}
	
	BOOL retStatus = YES;
	
	while (YES) {
		struct timeval timeout;
		fd_set socketSet;
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		FD_ZERO(socketSet);
		FD_SET(socketSet, server);
		// Wait for 1 second for a connection to be available
		if (select(server + 1, &socketSet, NULL, NULL, &timeout) < 0) {
			retStatus = NO;
			*error = [NSError errorWithDomain:@"select" code:errno message:@"Failed to select() socket."];
			break;
		}
		if ([self isServerClosed]) {
			close(server);
			break;
		}
		// If a connection is available, accept() it.
		if (FD_ISSET(socketSet, server)) {
			const char * ipAddr;
			cliSock = accept(server, (struct sockaddr *)&cliAddr, &cliLen);
			if (cliSock < 0) {
				WALog(LogPriorityError, @"Failed to accept from socket %d", server);
				retStatus = NO;
				*error = [NSError errorWithDomain:@"accept" code:errno message:@"Failed to accept() conncetion from socket."];
				break;
			}
			ipAddr = inet_ntoa(cliAddr.sin_addr);
			WALog(LogPriorityInfo, @"Connected from: %s", ipAddr);
			// TODO: hand the socket off to another thread.
			close(cliSock);
		}
	}
	
	[pool drain];
	return retStatus;
}

- (void)closedownServer {
	[self setIsServerClosed:YES];
}

- (id<HTTPServerDelegate>)delegate {
	return delegate;
}

@end

@implementation HTTPServer (Private)

- (BOOL)isServerClosed {
	BOOL flag;
	[closedLock lock];
	flag = isServerClosed;
	[closedLock unlock];
	return flag;
}

- (void)setIsServerClosed:(BOOL)flag {
	[closedLock lock];
	isServerClosed = flag;
	[closedLock unlock];
}

@end

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
// connection threads
- (NSError *)acceptServer:(int)server;
- (void)handleConnectionThread:(NSNumber *)socket;
- (void)handleConnection:(NSNumber *)socket;

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
#if !__has_feature(objc_arc)
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#endif
	[self setIsServerClosed:NO];
	// start a socket server
	struct sockaddr_in servAddr;
	
	int server = socket(AF_INET, SOCK_STREAM, 0);
	bzero(&servAddr, sizeof(struct sockaddr_in));
	servAddr.sin_family = AF_INET;
	servAddr.sin_addr.s_addr = INADDR_ANY;
	servAddr.sin_port = htons([portObj unsignedShortValue]);
	
    int reuseAddr = 1;
	if (setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, sizeof(int)) != 0) {
		WALog(LogPriorityWarning, @"Failed to disable SO_REUSEADDR");
	}
    
	// bind the socket to the address
	if (bind(server, (struct sockaddr *)&servAddr, sizeof(struct sockaddr_in)) < 0) {
#if !__has_feature(objc_arc)
		[pool drain];
#endif
		if (error) *error = [NSError errorWithDomain:@"bind" code:errno message:@"Failed to bind()."];
		return NO;
	}
	
	int keepalive = 0;
	if (setsockopt(server, SOL_SOCKET, SO_KEEPALIVE, &keepalive, sizeof(int)) != 0) {
		WALog(LogPriorityError, @"Failed to disable SO_KEEPALIVE");
	}
    
	int noSigPipe = 1;
	if (setsockopt(server, SOL_SOCKET, SO_NOSIGPIPE, (void *)&noSigPipe, sizeof(int)) != 0) {
        WALog(LogPriorityError, @"Failed to disable SO_NOSIGPIPE");
    }
	
	if (listen(server, 5) < 0) {
#if !__has_feature(objc_arc)
		[pool drain];
#endif
		if (error) *error = [NSError errorWithDomain:@"listen" code:errno message:@"Failed to listen()."];
		return NO;
	}
	
	WALog(LogPriorityInfo, @"Listening on port: %d", htons(servAddr.sin_port));
	
	BOOL retStatus = YES;
	
	while (YES) {
		struct timeval timeout;
		fd_set socketSet;
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		FD_ZERO(&socketSet);
		FD_SET(server, &socketSet);
		// Wait for 1 second for a connection to be available
		if (select(server + 1, &socketSet, NULL, NULL, &timeout) < 0) {
			if (errno != EINTR) {
				retStatus = NO;
				if (error) *error = [NSError errorWithDomain:@"select" code:errno message:@"Failed to select() socket."];
				break;
			}
		} else {
			if ([self isServerClosed]) {
				close(server);
				break;
			}
			// If a connection is available, accept() it.
			if (FD_ISSET(server, &socketSet)) {
				NSError * anError = [self acceptServer:server];
				if (anError) {
					if (error) *error = anError;
					retStatus = NO;
					break;
				}
			}
		}
	}
	
#if !__has_feature(objc_arc)
	if (error) {
		[*error retain];
	}
    
    [pool drain];
	if (error) {
		[*error autorelease];
	}
#endif
    
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

- (NSError *)acceptServer:(int)server {
	const char * ipAddr;
	struct sockaddr_in cliAddr;
	socklen_t cliLen = sizeof(struct sockaddr_in);
	int cliSock = accept(server, (struct sockaddr *)&cliAddr, &cliLen);
	if (cliSock < 0) {
		WALog(LogPriorityError, @"Failed to accept from socket %d", server);
		return [NSError errorWithDomain:@"accept" code:errno 
								message:@"Failed to accept() conncetion from socket."];
	}
	int sigPipe = 1;
	setsockopt(cliSock, SOL_SOCKET, SO_NOSIGPIPE, (void *)&sigPipe, sizeof(int));
	
	ipAddr = inet_ntoa(cliAddr.sin_addr);
	WALog(LogPriorityInfo, @"Connected from: %s", ipAddr);
	// TODO: hand the socket off to another thread.
	NSNumber * sockNum = [[NSNumber alloc] initWithInt:cliSock];
	[NSThread detachNewThreadSelector:@selector(handleConnectionThread:) toTarget:self withObject:sockNum];
#if !__has_feature(objc_arc)
	[sockNum release];
#endif
	
	return nil;
}

- (void)handleConnectionThread:(NSNumber *)socket {
#if !__has_feature(objc_arc)
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#endif
	@try {
		[self handleConnection:socket];
	} @catch (NSException * e) {
	}
#if !__has_feature(objc_arc)
	[pool drain];
#endif
}

- (void)handleConnection:(NSNumber *)socket {
	int fd = [socket intValue];
	WALog(LogPriorityDebug, @"-handleConnection: %d", fd);
	
	HTTPStream * stream = [[HTTPStream alloc] initWithSocket:fd];
	if (!stream) {
		WALog(LogPriorityError, @"Failed to open stream for fd: %d", fd);
		close(fd);
		return;
	}
	
	HTTPRequest * request = [[HTTPRequest alloc] initByReadingStream:stream];
	if (!request) {
		WALog(LogPriorityError, @"Failed to read header from stream: %@", stream);
		[stream closeStream];
#if !__has_feature(objc_arc)
		[stream release];
#endif
		return;
	}
    	
	HTTPContentProvider * provider = [delegate httpServer:self providerForRequest:request];
	WALog(LogPriorityDebug, @"-writingToProvider: %@", provider );
	if (provider) {
		NSString * responseString = [NSString stringWithFormat:@"HTTP/%@ %d %@\r\n",
									 [request httpVersion], [provider responseCode],
									 [provider responseMessage]];
		[stream writeData:[responseString dataUsingEncoding:NSASCIIStringEncoding]];
		[provider writeResponseHeaders:stream];
		[stream writeData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
		
		Class transportClass = [provider classForContentStream];
		if ([transportClass conformsToProtocol:@protocol(HTTPStreamWrapper)]) {		
			HTTPStream * newStream = [(HTTPStream<HTTPStreamWrapper> *)[transportClass alloc] initWithSocket:[stream fileDescriptor]];
			[provider writeDocumentBody:newStream];
			[newStream closeStream];
#if !__has_feature(objc_arc)
			[newStream release];
#endif
		} else {
			WALog(LogPriorityError, @"Invalid class from provider: %@", NSStringFromClass(transportClass));
		}
	}
	    
	[stream closeStream];
#if !__has_feature(objc_arc)
    [request release];
	[stream release];
#endif
}

@end

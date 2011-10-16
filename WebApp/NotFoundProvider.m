//
//  NotFoundProvider.m
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotFoundProvider.h"

@implementation NotFoundProvider

- (id)initWithRequest:(HTTPRequest *)aRequest {
	if ((self = [super init])) {
		request = [aRequest retain];
	}
	return self;
}

- (int)responseCode {
	return 404;
}

- (NSString *)responseMessage {
	return @"Not found";
}

- (void)writeResponseHeaders:(HTTPStream *)aStream {
	[super writeResponseHeaders:aStream]; // tells the transfer encoding
	[aStream writeData:[@"Content-Type: text/html; charset=ISO-8859-1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)writeDocumentBody:(HTTPStream *)aStream {
	NSString * bodyTemplate = @"<html><body>The page %@ does not exist.</body></html>";
	[aStream writeData:[[NSString stringWithFormat:bodyTemplate, [request requestPath]]
						dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)dealloc {
	[request release];
	[super dealloc];
}

@end

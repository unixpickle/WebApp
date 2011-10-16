//
//  SimpleProvider.m
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleProvider.h"

@implementation SimpleProvider

- (id)initWithRequest:(HTTPRequest *)aRequest {
	if ((self = [super init])) {
		request = [aRequest retain];
	}
	return self;
}

- (void)writeResponseHeaders:(HTTPStream *)aStream {
	[super writeResponseHeaders:aStream]; // tells the transfer encoding
	[aStream writeData:[@"Content-Type: text/html; charset=ISO-8859-1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)writeDocumentBody:(HTTPStream *)aStream {
	[self writeString:@"<html><body>\n" toStream:aStream];
	[self writeString:@"It works!<br /><br />" toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"Path: %@<br />", [request requestPath]]
			 toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"Method: %@<br />", [request requestMethod]]
			 toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"HTTP version: %@<br />", [request httpVersion]]
			 toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"Headers:<br /><pre>%@</pre>", [request otherFields]]
										toStream:aStream];
	[self writeString:@"</body></html>" toStream:aStream];
}

- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[stream writeData:[asciiString dataUsingEncoding:NSASCIIStringEncoding]];
	[pool drain];
}

- (void)dealloc {
	[request release];
	[super dealloc];
}

@end

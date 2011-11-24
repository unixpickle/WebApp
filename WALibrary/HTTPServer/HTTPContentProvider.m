//
//  HTTPContentProvider.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import "HTTPContentProvider.h"

@implementation HTTPContentProvider

- (NSString *)responseMessage {
	return nil;
}

- (int)responseCode {
	return 200;
}

- (void)writeResponseHeaders:(HTTPStream *)aStream {
	NSData * cTypeData = [kDefaultTransferEncodingHeader dataUsingEncoding:NSASCIIStringEncoding];
	[aStream writeData:cTypeData];
}

- (Class)classForContentStream {
	return [HTTPChunkedStream class];
}

- (void)writeDocumentBody:(HTTPStream *)aStream {
	
}

@end

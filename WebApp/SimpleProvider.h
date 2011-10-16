//
//  SimpleProvider.h
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPContentProvider.h"
#import "HTTPRequest.h"

@interface SimpleProvider : HTTPContentProvider {
	HTTPRequest * request;
}

- (id)initWithRequest:(HTTPRequest *)aRequest;
- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream;

@end

//
//  NotFoundProvider.h
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPContentProvider.h"
#import "HTTPRequest.h"

@interface NotFoundProvider : HTTPContentProvider {
	HTTPRequest * request;
}

- (id)initWithRequest:(HTTPRequest *)request;

@end

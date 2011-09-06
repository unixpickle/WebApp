//
//  HTTPServer.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPContentProvider.h"
#import "HTTPRequest.h"

@class HTTPServer;

@protocol HTTPServerDelegate

- (HTTPContentProvider *)httpServer:(HTTPServer *)server providerForRequest:(HTTPRequest *)request;

@end

@interface HTTPServer : NSObject {
	
}

@end

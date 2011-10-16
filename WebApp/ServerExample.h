//
//  ServerExample.h
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryProvider.h"
#import "FileProvider.h"
#import "NotFoundProvider.h"
#import "HTTPServer.h"

@interface ServerExample : NSObject <HTTPServerDelegate> {
	
}

- (void)startExample:(int)port;

@end

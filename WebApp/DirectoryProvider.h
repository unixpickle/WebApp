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

@interface DirectoryProvider : HTTPContentProvider {
	NSString * dirPath;
}

- (id)initWithDirectory:(NSString *)aDir;
- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream;

@end

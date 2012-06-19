//
//  HTTPHeaderReader.h
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPStream.h"
#import "ARCHelper.h"

#define kHeaderReadTimeout 60

@interface HTTPHeaderReader : NSObject {
	HTTPStream * stream;
}

- (id)initWithStream:(HTTPStream *)stream;
- (HTTPStream *)stream;

- (NSString *)readLine;
- (BOOL)readField:(NSString **)fieldOut value:(NSString **)valueOut;

@end

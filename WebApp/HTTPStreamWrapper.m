//
//  RawStream.m
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPStreamWrapper.h"

@implementation HTTPStreamWrapper

- (id)initWithStream:(HTTPStream *)stream {
	if ((self = [super initWithSocket:[stream fileDescriptor]])) {
	}
	return self;
}

- (void)closeStream {
	
}

@end

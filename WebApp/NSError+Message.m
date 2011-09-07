//
//  NSError+Message.m
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSError+Message.h"

@implementation NSError (Message)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)msg {
	NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:domain code:code userInfo:d];
}

@end

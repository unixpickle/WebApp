//
//  NSError+Message.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Message)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)msg;

@end

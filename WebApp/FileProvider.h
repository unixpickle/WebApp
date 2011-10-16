//
//  FileProvider.h
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPContentProvider.h"
#import "HTTPStreamWrapper.h"
#import "Log.h"

@interface FileProvider : HTTPContentProvider {
	NSString * filePath;
	NSString * contentType;
	
	NSRange contentRange;
	BOOL isRanged;
	unsigned long long fileSize;
}

- (id)initWithFilePath:(NSString *)aFile;
- (id)initWithFilePath:(NSString *)aFile range:(NSRange)aRange;
- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream;
- (NSString *)mimeTypeForFile:(NSString *)fileName;

@end

//
//  FileProvider.m
//  WebApp
//
//  Created by Alex Nichol on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileProvider.h"

@implementation FileProvider

- (id)initWithFilePath:(NSString *)aFile {
	if ((self = [super init])) {
#if !__has_feature(objc_arc)
		contentType = [[self mimeTypeForFile:aFile] retain];
		filePath = [aFile retain];
#else
		contentType = [self mimeTypeForFile:aFile];
		filePath = aFile;
#endif
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:aFile error:nil];
		if (!attributes) {
#if !__has_feature(objc_arc)
			[self dealloc];
#endif
			return nil;
		}
		fileSize = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
	}
	return self;
}

- (id)initWithFilePath:(NSString *)aFile range:(NSRange)aRange {
	if ((self = [super init])) {
#if !__has_feature(objc_arc)
		contentType = [[self mimeTypeForFile:aFile] retain];
		filePath = [aFile retain];
#else
        contentType = [self mimeTypeForFile:aFile];
		filePath = aFile;
#endif
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:aFile error:nil];
		if (!attributes) {
#if !__has_feature(objc_arc)
			[self dealloc];
#endif
			return nil;
		}
		fileSize = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
		contentRange = aRange;
		isRanged = YES;
		if (contentRange.location + contentRange.length > fileSize) {
#if !__has_feature(objc_arc)
			[self dealloc];
#endif
			return nil;
		}
	}
	return self;
}

- (void)writeResponseHeaders:(HTTPStream *)aStream {
	[self writeString:[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType]
			 toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"Accept-Ranges: bytes\r\n"]
										toStream:aStream];
	if (!isRanged) {
		[self writeString:[NSString stringWithFormat:@"Content-Length: %lld\r\n", fileSize]
				 toStream:aStream];
	} else {
		WALog(LogPriorityInfo, @"Providing ranged data.");
		[self writeString:[NSString stringWithFormat:@"Content-Range: bytes %lld-%lld/%lld\r\n",
						   contentRange.location, contentRange.location + contentRange.length - 1, fileSize]
											toStream:aStream];
		[self writeString:[NSString stringWithFormat:@"Content-Length: %lld\r\n", contentRange.length]
				 toStream:aStream];
	}
}

- (Class)classForContentStream {
	return [HTTPStreamWrapper class];
}

- (void)writeDocumentBody:(HTTPStream *)aStream {
	NSFileHandle * fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
	if (!fh) return;
	NSData * readData = nil;
	if (!isRanged) {
		while (true) {
#if !__has_feature(objc_arc)
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#else
            @autoreleasepool {
#endif
			readData = [fh readDataOfLength:65536];
			if ([readData length] == 0 || !readData) {
#if !__has_feature(objc_arc)
                [pool drain];
#endif
				break;
			}
			if (![aStream writeData:readData]) {
#if !__has_feature(objc_arc)
                [pool drain];
#endif
				break;
			}
#if !__has_feature(objc_arc)
            [pool drain];
#else
            }
#endif
		}
	} else {
		NSUInteger left = contentRange.length;
		[fh seekToFileOffset:contentRange.location];
		while (left > 0) {
#if !__has_feature(objc_arc)
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#else
            @autoreleasepool {
#endif
            readData = [fh readDataOfLength:left];
			if ([readData length] == 0 || !readData) {
#if !__has_feature(objc_arc)
                [pool drain];
#endif
				break;
			}
			if (![aStream writeData:readData]) {
#if !__has_feature(objc_arc)
                [pool drain];
#endif
				break;
			}
			left -= [readData length];
#if !__has_feature(objc_arc)
            [pool drain];
#else
            }
#endif
		}
	}
	[fh closeFile];
}

- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream {
#if !__has_feature(objc_arc)
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#else
    @autoreleasepool {
#endif
	[stream writeData:[asciiString dataUsingEncoding:NSASCIIStringEncoding]];
#if !__has_feature(objc_arc)
	[pool drain];
#else
    }
#endif
}

- (NSString *)mimeTypeForFile:(NSString *)fileName {
	const struct {
#if !__has_feature(objc_arc)
		NSString * extension;
		NSString * mimeType;
#else
        __unsafe_unretained NSString * extension;
		__unsafe_unretained NSString * mimeType;
#endif
	} mimeToExtension[] = {
		{@"jpg", @"image/jpeg"},
		{@"jpeg", @"image/jpeg"},
		{@"png", @"image/png"},
		{@"md", @"text/plain"},
		{@"pdf", @"application/pdf"},
		{@"mp3", @"audio/mpeg3"},
		{@"mov", @"video/quicktime"},
		{@"txt", @"text/plain"}
	};
	
	NSString * extension = [[fileName pathExtension] lowercaseString];
	for (int i = 0; i < 8; i++) {
		if ([mimeToExtension[i].extension isEqualToString:extension]) {
			return mimeToExtension[i].mimeType;
		}
	}
	
	if ([fileName pathExtension] == nil || [[fileName pathExtension] isEqualToString:@""]) {
		return @"text/plain";
	}
	
	return @"application/octet-stream";
}

#if !__has_feature(objc_arc)
- (void)dealloc {
	[filePath release];
	[contentType release];
	[super dealloc];
}
#endif

@end

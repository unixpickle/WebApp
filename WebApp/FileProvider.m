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
		contentType = [[self mimeTypeForFile:aFile] retain];
		filePath = [aFile retain];
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:aFile error:nil];
		if (!attributes) {
			[self dealloc];
			return nil;
		}
		fileSize = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
	}
	return self;
}

- (id)initWithFilePath:(NSString *)aFile range:(NSRange)aRange {
	if ((self = [super init])) {
		contentType = [[self mimeTypeForFile:aFile] retain];
		filePath = [aFile retain];
		NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:aFile error:nil];
		if (!attributes) {
			[self dealloc];
			return nil;
		}
		fileSize = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
		contentRange = aRange;
		isRanged = YES;
		if (contentRange.location + contentRange.length > fileSize) {
			[self dealloc];
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
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			readData = [fh readDataOfLength:65536];
			if ([readData length] == 0 || !readData) {
				[pool drain];
				break;
			}
			if (![aStream writeData:readData]) {
				[pool drain];
				break;
			}
			[pool drain];
		}
	} else {
		NSUInteger left = contentRange.length;
		[fh seekToFileOffset:contentRange.location];
		while (left > 0) {
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			readData = [fh readDataOfLength:left];
			if ([readData length] == 0 || !readData) {
				[pool drain];
				break;
			}
			if (![aStream writeData:readData]) {
				[pool drain];
				break;
			}
			left -= [readData length];
			[pool drain];
		}
	}
	[fh closeFile];
}

- (void)writeString:(NSString *)asciiString toStream:(HTTPStream *)stream {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[stream writeData:[asciiString dataUsingEncoding:NSASCIIStringEncoding]];
	[pool drain];
}

- (NSString *)mimeTypeForFile:(NSString *)fileName {
	const struct {
		NSString * extension;
		NSString * mimeType;
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

- (void)dealloc {
	[filePath release];
	[contentType release];
	[super dealloc];
}

@end

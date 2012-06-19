//
//  SimpleProvider.m
//  WebApp
//
//  Created by Alex Nichol on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectoryProvider.h"

@implementation DirectoryProvider

- (id)initWithDirectory:(NSString *)aDir {
	if ((self = [super init])) {
#if !__has_feature(objc_arc)
		dirPath = [aDir retain];
#else
        dirPath = aDir;
#endif
	}
	return self;
}

- (void)writeResponseHeaders:(HTTPStream *)aStream {
	[super writeResponseHeaders:aStream]; // tells the transfer encoding
	[aStream writeData:[@"Content-Type: text/html; charset=ISO-8859-1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)writeDocumentBody:(HTTPStream *)aStream {
	NSString * parentDir = [dirPath stringByDeletingLastPathComponent];
	[self writeString:@"<html><body>\n" toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"<h1 style=\"padding: 0px; margin: 0px\">Contents of directory: %@</h1>\n", dirPath]
			 toStream:aStream];
	[self writeString:[NSString stringWithFormat:@"<a href=\"%@\">To parent directory</a><br /><br />", parentDir]
			 toStream:aStream];
	[self writeString:@"<ul>\n" toStream:aStream];
	NSArray * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
	for (int i = 0; i < [dirContents count]; i++) {
		NSString * fileName = [dirContents objectAtIndex:i];
		NSString * absolute = [dirPath stringByAppendingPathComponent:fileName];
		BOOL isDirectory = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:absolute isDirectory:&isDirectory]) {
			NSString * formatString = nil;
			if (isDirectory) {
				formatString = @"<li><a href=\"%@\">%@/</a></li>\n";
			} else {
				formatString = @"<li><a href=\"%@\">%@</a></li>\n";
			}
			NSString * fileStr = [NSString stringWithFormat:formatString,
								  [absolute stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								  fileName];
			[self writeString:fileStr toStream:aStream];
		}
	}
	[self writeString:@"</ul>\n" toStream:aStream];
	[self writeString:@"</body></html>" toStream:aStream];
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

#if !__has_feature(objc_arc)
- (void)dealloc {
	[dirPath release];
	[super dealloc];
}
#endif

@end

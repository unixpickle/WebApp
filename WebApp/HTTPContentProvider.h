//
//  HTTPContentProvider.h
//  WebApp
//
//  Created by Alex Nichol on 9/6/11.
//  Copyright 2011 Ryan & Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPStream.h"

#define kDefaultTransferEncodingHeader @"Transfer-Encoding: chunked\r\n"

@interface HTTPContentProvider : NSObject {
	
}

/**
 * Return the (optional) error message for the response.
 * @return The error/status message, or nil for the default.
 */
- (NSString *)responseMessage;

/**
 * Return the HTTP status.
 * @return For a successful request this should be between 200 and 299.
 */
- (int)responseCode;

/**
 * Called when it is time for the content provider to write the response
 * fields to the HTTP stream.  If no additional headers (e.g. content type)
 * need to be written, this can be an empty method.
 */
- (void)writeResponseHeaders:(HTTPStream *)aStream;

/**
 * Called when it is time for the content provider to write the contents of
 * the HTTP document.
 * @param aStream The stream to which the HTTP response data should be written.
 * This will most likely be a chunked stream, although that may not always
 * be the case.
 */
- (void)writeDocumentBody:(HTTPStream *)aStream;

@end

//
//  NSString+MIMEType.h
//  StoAmigo
//
//  Created by simon.zeng on 1/2/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MIMEType)

// UTI 2 MIME type
+ (NSString *)UTIStringFromMIMEType:(NSString *)mimeTypeString;
+ (NSString *)MIMETypeStringFromUTI:(NSString *)UTIString;

// Ext 2 UTI
+ (NSString *)extensionFromUTI:(NSString *)UTIString;
+ (NSString *)UTIStringFromExtension:(NSString *)extension;

// MIME type 2 Ext
+ (NSString *)extensionFromMIMEType:(NSString *)mimeTypeString;
+ (NSString *)MIMETypeStringFromExtension:(NSString *)extension;

@end

//
//  NSString+MIMEType.m
//  StoAmigo
//
//  Created by simon.zeng on 1/2/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import "NSString+MIMEType.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@implementation NSString (MIMEType)

+ (NSString *)UTIStringFromMIMEType:(NSString *)mimeTypeString
{
    NSString * UTIString = nil;
    
    if (mimeTypeString)
    {
        CFStringRef MIMEType = (__bridge CFStringRef)mimeTypeString;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
        UTIString = (__bridge_transfer NSString *)UTI;
    }
    
    return UTIString;
}

+ (NSString *)MIMETypeStringFromUTI:(NSString *)UTIString
{
    NSString * MIMETypeString = nil;
    
    if (UTIString)
    {
        CFStringRef UTI =  (__bridge CFStringRef)UTIString;
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);

        MIMETypeString = (__bridge_transfer NSString *)MIMEType;
    }
    
    return MIMETypeString;
}


// Ext 2 UTI
+ (NSString *)extensionFromUTI:(NSString *)UTIString
{
    NSString * extensionString = nil;
    
    if (UTIString)
    {
        CFStringRef UTI = (__bridge CFStringRef)UTIString;
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassFilenameExtension);
        
        extensionString = (__bridge_transfer NSString *)extension;
    }
    
    return extensionString;
}

+ (NSString *)UTIStringFromExtension:(NSString *)extension
{
    NSString * UTIString = nil;
    
    if (extension)
    {
        CFStringRef Ext = (__bridge CFStringRef)extension;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, Ext, NULL);
        UTIString = (__bridge_transfer NSString *)UTI;
    }
    
    return UTIString;
}

+ (NSString *)extensionFromMIMEType:(NSString *)mimeTypeString
{
    NSString * extensionString = nil;
    
    if (mimeTypeString)
    {
        CFStringRef MIMEType = (__bridge CFStringRef)mimeTypeString;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassFilenameExtension);
        CFRelease(UTI);
        
        extensionString = (__bridge_transfer NSString *)extension;
    }
    
    return extensionString;
}

+ (NSString *)MIMETypeStringFromExtension:(NSString *)extension
{
    NSString * MIMETypeString = nil;
    
    if (extension)
    {
        CFStringRef fileExtension = (__bridge CFStringRef)extension;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        MIMETypeString = (__bridge_transfer NSString *)MIMEType;
    }
    
    return MIMETypeString;
}

@end

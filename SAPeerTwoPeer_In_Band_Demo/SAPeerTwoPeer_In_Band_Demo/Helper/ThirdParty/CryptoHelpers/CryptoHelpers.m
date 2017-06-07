//
//  CryptoHelpers.m
//  CloudLocker
//
//  Created by Konstantin Chugalinskiy on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CryptoHelpers.h"
#include <CommonCrypto/CommonDigest.h>

@implementation CryptoHelpers

+(NSData *)createSHA512:(NSString *)source {
    const char *s = [source cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [[NSData alloc] initWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    CC_SHA512(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *result = [[NSData alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    return result;
}

+(NSString*)createMD5:(NSString *)source {
    const char *ptr = [source UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}

@end

//
//  CryptoHelpers.h
//  CloudLocker
//
//  Created by Konstantin Chugalinskiy on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoHelpers : NSObject

+(NSData *)createSHA512:(NSString *)source;
+(NSString*)createMD5:(NSString *)source;

@end

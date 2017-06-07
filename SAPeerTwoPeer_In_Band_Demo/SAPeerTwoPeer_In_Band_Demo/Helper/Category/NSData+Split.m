//
//  NSData+Split.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "NSData+Split.h"

@implementation NSData (Split)

- (void)splitDataWithSplitChunkSize:(NSUInteger)chunk completedBlock:(SASplitDataCompletedBlock)block
{
    NSMutableArray <NSData *>*dataArrays = [NSMutableArray array];
    
    NSData* myBlob = self;
    NSUInteger length = [myBlob length];
    
    NSUInteger chunkSize = chunk;
    NSUInteger offset = 0;
    
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        
        NSData* dataChunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        
        if (dataChunk)
        {
            offset += thisChunkSize;
            
            [dataArrays addObject:dataChunk];
        }
        else
        {
            if (block)
            {
                NSError * error = [NSError errorWithDomain:@"Split failed"
                                                      code:-1
                                                  userInfo:nil];
                block(NO, nil, error);
            }
            break;
        }
        
    } while (offset < length);
    
    if (block)
    {
        if (offset == length)
        {
            block(YES, dataArrays, nil);
        }
        else
        {
            block(NO, nil, nil);
        }
    }
    
}

@end

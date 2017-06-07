//
//  SAData.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAData.h"

@implementation SAData

- (instancetype)init
{
    if (self = [super init])
    {
        _data = [NSMutableData data];
        _dataType = nil;
        _state = SADataStateDefault;
    }
    return self;
}

+ (instancetype)data
{
    return [[SAData alloc] init];
}

- (void)addData:(NSData *)data
{
    [_data appendData:data];
}

- (void)clearData;
{
    _data = nil;
    _data = [NSMutableData data];
}

#pragma mark - Over write
- (NSString *)description
{
    NSMutableString * string = [NSMutableString string];
    
    [string appendFormat:@"\nSAData: %p\n", &self];
    [string appendFormat:@"{\n"];
    [string appendFormat:@"    dataType : %@\n", _dataType];
    [string appendFormat:@"    data state : %@", [self getDataStateString]];
    [string appendFormat:@"    data estimated size : %ld\n", _estimatedSize];
    [string appendFormat:@"    data actual size : %ld\n", _data.length];
    [string appendFormat:@"}"];
    
    return string;
}

- (NSString *)getDataStateString
{
    switch (_state)
    {
        case SADataStateDefault:
            return @"SADataStateDefault";
            break;
        case SADataStateBegin:
            return @"SADataStateBegin";
            break;
        case SADataStateTransferring:
            return @"SADataStateTransferring";
            break;
        case SADataStateCompleted:
            return @"SADataStateCompleted";
            break;
        default:
            break;
    }
}

@end

//
//  RTCDataChannel+JSON.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "RTCDataChannel+JSON.h"

static NSString * const SADataBeginKey = @"transfer-request-offer";
static NSString * const SADataBeganKey = @"transfer-request-answer";

static NSString * const SADataComletedOfferKey = @"transfer-comleted-offer";
static NSString * const SADataComletedAnswerKey = @"transfer-comleted-answer";

@implementation RTCDataChannel (JSON)

- (RTCDataBuffer *)BeginOfferJSONStringWithDataModel:(SADataModel *)dataModel
{
    NSDictionary * JSONDict = @{@"type" : SADataBeginKey,
                                @"dataType" : dataModel.dataTypeString,
                                @"dataSize" : @(dataModel.data.length),
                                @"dataChannelId" : @(self.channelId),
                                @"dataChannelLable" : self.label};
    
    NSData * JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:nil];
    
    return [[RTCDataBuffer alloc] initWithData:JSONData isBinary:NO];
}

- (RTCDataBuffer *)BeginAnswerJSONStringWithData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Logic error!");
    }
    
    NSData * data = dataBuffer.data;
    
    NSError *error = nil;
    id JSONContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    
    if ([JSONContent isKindOfClass:[NSDictionary class]])
    {
        NSString * typeString = [(NSDictionary *)JSONContent objectForKey:@"type"];
        NSString * dataType = [(NSDictionary *)JSONContent objectForKey:@"dataType"];
        NSNumber * dataSize = [(NSDictionary *)JSONContent objectForKey:@"dataSize"];
        NSNumber * dataChannelId = [(NSDictionary *)JSONContent objectForKey:@"dataChannelId"];
        NSString * dataChannelLabel = [(NSDictionary *)JSONContent objectForKey:@"dataChannelLable"];
        
        if ([typeString isEqualToString:SADataBeginKey] && dataType && dataSize)
        {
            NSDictionary * JSONDict = @{@"type" : SADataBeganKey,
                                        @"dataType" : dataType,
                                        @"dataSize" : dataSize,
                                        @"dataChannelId" : dataChannelId,
                                        @"dataChannelLable" : dataChannelLabel};
            
            NSData * JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:nil];
            
            return [[RTCDataBuffer alloc] initWithData:JSONData isBinary:NO];
        }
        else
        {
            NSLog(@"Missing data in JSON,\n%@", JSONContent);
            return nil;
        }
    }
    else
    {
        NSLog(@"JSON format is %@", [JSONContent class]);
        return nil;
    }
}

- (CGFloat)estimatedSizeWithData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Logic error!");
    }
    
    NSData * data = dataBuffer.data;
    
    NSError *error = nil;
    id JSONContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return -1.0f;
    }
    
    if ([JSONContent isKindOfClass:[NSDictionary class]])
    {
        NSString * typeString = [(NSDictionary *)JSONContent objectForKey:@"type"];
        NSString * dataType = [(NSDictionary *)JSONContent objectForKey:@"dataType"];
        NSNumber * dataSize = [(NSDictionary *)JSONContent objectForKey:@"dataSize"];
        NSNumber * dataChannelId = [(NSDictionary *)JSONContent objectForKey:@"dataChannelId"];
        NSString * dataChannelLabel = [(NSDictionary *)JSONContent objectForKey:@"dataChannelLable"];
        
        if (typeString && dataType && dataSize && [dataChannelId isEqualToNumber:@(self.channelId)] && [dataChannelLabel isEqualToString:self.label])
        {
            return dataSize.floatValue;
        }
        else
        {
            NSLog(@"Missing data in JSON,\n%@", JSONContent);
            return -1.0f;
        }
    }
    else
    {
        NSLog(@"JSON format is %@", [JSONContent class]);
        return -1.0f;
    }
}

- (NSString *)dataTypeStringWithData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Logic error!");
    }
    
    NSData * data = dataBuffer.data;
    
    NSError *error = nil;
    id JSONContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    
    if ([JSONContent isKindOfClass:[NSDictionary class]])
    {
        NSString * typeString = [(NSDictionary *)JSONContent objectForKey:@"type"];
        NSString * dataType = [(NSDictionary *)JSONContent objectForKey:@"dataType"];
        NSNumber * dataSize = [(NSDictionary *)JSONContent objectForKey:@"dataSize"];
        NSNumber * dataChannelId = [(NSDictionary *)JSONContent objectForKey:@"dataChannelId"];
        NSString * dataChannelLabel = [(NSDictionary *)JSONContent objectForKey:@"dataChannelLable"];
        
        if (typeString && dataType && dataSize && [dataChannelId isEqualToNumber:@(self.channelId)] && [dataChannelLabel isEqualToString:self.label])
        {
            return dataType;
        }
        else
        {
            NSLog(@"Missing data in JSON,\n%@", JSONContent);
            return nil;
        }
    }
    else
    {
        NSLog(@"JSON format is %@", [JSONContent class]);
        return nil;
    }
}

- (SADataBufferType)dataBufferTypeWithData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Logic error!");
    }
    
    NSData * data = dataBuffer.data;
    
    NSError *error = nil;
    id JSONContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return SADataBufferTypeError;
    }
    
    if ([JSONContent isKindOfClass:[NSDictionary class]])
    {
        NSString * typeString = [(NSDictionary *)JSONContent objectForKey:@"type"];
        NSString * dataType = [(NSDictionary *)JSONContent objectForKey:@"dataType"];
        NSNumber * dataSize = [(NSDictionary *)JSONContent objectForKey:@"dataSize"];
        NSNumber * dataChannelId = [(NSDictionary *)JSONContent objectForKey:@"dataChannelId"];
        NSString * dataChannelLabel = [(NSDictionary *)JSONContent objectForKey:@"dataChannelLable"];
        
        if (typeString && dataType && dataSize && [dataChannelId isEqualToNumber:@(self.channelId)] && [dataChannelLabel isEqualToString:self.label])
        {
            if ([typeString isEqualToString:SADataBeginKey])
            {
                return SADataBufferTypeBeginOffer;
            }
            else if ([typeString isEqualToString:SADataBeganKey])
            {
                return SADataBufferTypeBeginAnswer;
            }
            else if ([typeString isEqualToString:SADataComletedOfferKey])
            {
                return SADataBufferTypeCompletedOffer;
            }
            else if ([typeString isEqualToString:SADataComletedAnswerKey])
            {
                return SADataBufferTypeCompletedAnswer;
            }
            else
            {
                return SADataBufferTypeError;
            }
            
        }
        else
        {
            NSLog(@"Missing data in JSON,\n%@", JSONContent);
            return SADataBufferTypeError;
        }
    }
    else
    {
        NSLog(@"JSON format is %@", [JSONContent class]);
        return SADataBufferTypeError;
    }
}

- (RTCDataBuffer *)CompletedOfferJSONStringWithData:(SAData *)data
{
    NSDictionary * JSONDict = @{@"type" : SADataComletedOfferKey,
                                @"dataType" : data.dataType,
                                @"dataSize" : @(data.data.length),
                                @"dataChannelId" : @(self.channelId),
                                @"dataChannelLable" : self.label};
    
    NSData * JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:nil];
    
    return [[RTCDataBuffer alloc] initWithData:JSONData isBinary:NO];
}

- (RTCDataBuffer *)CompletedAnswerJSONStringWithData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Logic error!");
    }
    
    NSData * data = dataBuffer.data;
    
    NSError *error = nil;
    id JSONContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    
    if ([JSONContent isKindOfClass:[NSDictionary class]])
    {
        NSString * typeString = [(NSDictionary *)JSONContent objectForKey:@"type"];
        NSString * dataType = [(NSDictionary *)JSONContent objectForKey:@"dataType"];
        NSNumber * dataSize = [(NSDictionary *)JSONContent objectForKey:@"dataSize"];
        NSNumber * dataChannelId = [(NSDictionary *)JSONContent objectForKey:@"dataChannelId"];
        NSString * dataChannelLabel = [(NSDictionary *)JSONContent objectForKey:@"dataChannelLable"];
        
        if ([typeString isEqualToString:SADataComletedOfferKey] && dataType && dataSize)
        {
            NSDictionary * JSONDict = @{@"type" : SADataComletedAnswerKey,
                                        @"dataType" : dataType,
                                        @"dataSize" : dataSize,
                                        @"dataChannelId" : dataChannelId,
                                        @"dataChannelLable" : dataChannelLabel};
            
            NSData * JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:nil];
            
            return [[RTCDataBuffer alloc] initWithData:JSONData isBinary:NO];
        }
        else
        {
            NSLog(@"Missing data in JSON,\n%@", JSONContent);
            return nil;
        }
    }
    else
    {
        NSLog(@"JSON format is %@", [JSONContent class]);
        return nil;
    }
}

@end

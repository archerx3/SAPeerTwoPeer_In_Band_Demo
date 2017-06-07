//
//  RTCSessionDescription+JSON.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "RTCSessionDescription+JSON.h"

static NSString const *kRTCSessionDescriptionTypeKey = @"type";
static NSString const *kRTCSessionDescriptionSdpKey = @"sdp";

@implementation RTCSessionDescription (JSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *typeString = dictionary[kRTCSessionDescriptionTypeKey];
    RTCSdpType type = [[self class] typeForString:typeString];
    
    NSString *sdp = dictionary[kRTCSessionDescriptionSdpKey];
    
    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSData *)JSONData
{
    NSString *type = [[self class] stringForType:self.type];
    NSDictionary *json = @{
                           kRTCSessionDescriptionTypeKey : type,
                           kRTCSessionDescriptionSdpKey : self.sdp
                           };
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end

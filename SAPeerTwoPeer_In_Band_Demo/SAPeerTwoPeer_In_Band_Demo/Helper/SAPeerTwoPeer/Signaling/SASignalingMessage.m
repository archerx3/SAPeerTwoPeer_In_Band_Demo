//
//  SASignalingMessage.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SASignalingMessage.h"

#import "RTCIceCandidate+JSON.h"
#import "RTCSessionDescription+JSON.h"

static NSString * const kSASignalingMessageTypeKey = @"type";
static NSString * const kSASignalingMessageValueKey = @"value";

static NSString * const kSATypeValueGetRoom = @"GETROOM";
static NSString * const kSATypeValueOffer = @"offer";
static NSString * const kSATypeValueAnswer = @"answer";
static NSString * const kSATypeValueCandidate = @"candidate";
static NSString * const kSATypeValueRemoveCandidates = @"remove-candidates";
static NSString * const kSATypeValueBye = @"bye";

@implementation SASignalingMessage

@synthesize type = mType;

- (instancetype)initWithType:(SASignalingMessageType)type
{
    if (self = [super init])
    {
        mType = type;
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithData:[self JSONData]
                                 encoding:NSUTF8StringEncoding];
}

+ (SASignalingMessage *)messageFromJSONString:(NSString *)jsonString
{
    NSDictionary *values = [NSDictionary dictionaryWithJSONString:jsonString];
    if (!values)
    {
        NSLog(@"Error parsing signaling message JSON.");
        return nil;
    }
    
    NSString *typeString = values[kSASignalingMessageTypeKey];
    SASignalingMessage *message = nil;
    
    if ([typeString isEqualToString:kSATypeValueCandidate])
    {
        RTCIceCandidate *candidate = [RTCIceCandidate candidateFromJSONDictionary:values];
        message = [[SAICECandidateMessage alloc] initWithCandidate:candidate];
    }
    else if ([typeString isEqualToString:kSATypeValueRemoveCandidates])
    {
        NSLog(@"Received remove-candidates message");
        NSArray<RTCIceCandidate *> *candidates = [RTCIceCandidate candidatesFromJSONDictionary:values];
        message = [[SAICECandidateRemovalMessage alloc] initWithRemovedCandidates:candidates];
    }
    else if ([typeString isEqualToString:kSATypeValueOffer] || [typeString isEqualToString:kSATypeValueAnswer])
    {
        RTCSessionDescription *description = [RTCSessionDescription descriptionFromJSONDictionary:values];
        message = [[SASessionDescriptionMessage alloc] initWithDescription:description];
    }
    else if ([typeString isEqualToString:kSATypeValueBye])
    {
        message = [[SAByeMessage alloc] init];
    }
    else if ([typeString isEqualToString:kSATypeValueGetRoom])
    {
        message = [[SAGetRoomMessage alloc] initWithRoomNumber:values[@"value"]];
    }
    else
    {
        NSLog(@"Unexpected type: %@", typeString);
    }
    return message;
}

- (NSData *)JSONData
{
    return nil;
}

@end

@implementation SAGetRoomMessage

@synthesize roomNumber = mRoomNumber;

- (instancetype)initWithRoomNumber:(NSNumber *)roomNumber
{
    if (self = [super initWithType:kSASignalingMessageTypeGetRoom])
    {
        mRoomNumber = roomNumber.stringValue;
    }
    return self;
}

- (NSData *)JSONData
{
    NSDictionary * dict = @{kSASignalingMessageTypeKey : kSATypeValueGetRoom, kSASignalingMessageValueKey : mRoomNumber};
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
}

@end

/**
 ICE Candidate Message
 */
@implementation SAICECandidateMessage

@synthesize candidate = mCandidate;

- (instancetype)initWithCandidate:(RTCIceCandidate *)candidate
{
    if (self = [super initWithType:kSASignalingMessageTypeCandidate])
    {
        mCandidate = candidate;
    }
    return self;
}

- (NSData *)JSONData
{
    return [mCandidate JSONData];
}

@end

/**
 ICE Candidate Removal Message
 */
@implementation SAICECandidateRemovalMessage

@synthesize candidates = mCandidates;

- (instancetype)initWithRemovedCandidates:(NSArray<RTCIceCandidate *> *)candidates
{
    NSParameterAssert(candidates.count);
    if (self = [super initWithType:kSASignalingMessageTypeCandidateRemoval])
    {
        mCandidates = candidates;
    }
    return self;
}

- (NSData *)JSONData
{
    return [RTCIceCandidate JSONDataForIceCandidates:mCandidates withType:kSATypeValueRemoveCandidates];
}

@end

/**
 SDP message
 */
@implementation SASessionDescriptionMessage

@synthesize sessionDescription = mSessionDescription;

- (instancetype)initWithDescription:(RTCSessionDescription *)description
{
    SASignalingMessageType messageType = kSASignalingMessageTypeOffer;
    RTCSdpType sdpType = description.type;
    switch (sdpType)
    {
        case RTCSdpTypeOffer:
            messageType = kSASignalingMessageTypeOffer;
            break;
        case RTCSdpTypeAnswer:
            messageType = kSASignalingMessageTypeAnswer;
            break;
        case RTCSdpTypePrAnswer:
            NSAssert(NO, @"Unexpected type: %@",
                     [RTCSessionDescription stringForType:sdpType]);
            break;
    }
    if (self = [super initWithType:messageType])
    {
        mSessionDescription = description;
    }
    return self;
}

- (NSData *)JSONData
{
    return [mSessionDescription JSONData];
}

@end

/**
 Bye Message
 */
@implementation SAByeMessage

- (instancetype)init
{
    return [super initWithType:kSASignalingMessageTypeBye];
}

@end

//
//  SASignalingMessage.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSASignalingMessageTypeGetRoom,
    kSASignalingMessageTypeCandidate,
    kSASignalingMessageTypeCandidateRemoval,
    kSASignalingMessageTypeOffer,
    kSASignalingMessageTypeAnswer,
    kSASignalingMessageTypeBye,
} SASignalingMessageType;

/**
 Base class for signaling message
 */
@interface SASignalingMessage : NSObject

@property(nonatomic, readonly) SASignalingMessageType type;

+ (SASignalingMessage *)messageFromJSONString:(NSString *)jsonString;
- (NSData *)JSONData;

@end

@interface SAGetRoomMessage : SASignalingMessage

@property (nonatomic, readonly) NSString * roomNumber;

- (instancetype)initWithRoomNumber:(NSNumber *)roomNumber;

@end

/**
 ICE Candidate Message
 */
@interface SAICECandidateMessage : SASignalingMessage

@property(nonatomic, readonly) RTCIceCandidate *candidate;

- (instancetype)initWithCandidate:(RTCIceCandidate *)candidate;

@end

/**
 ICE Candidate Removal Message
 */
@interface SAICECandidateRemovalMessage : SASignalingMessage

@property(nonatomic, readonly) NSArray<RTCIceCandidate *> *candidates;

- (instancetype)initWithRemovedCandidates:(NSArray<RTCIceCandidate *> *)candidates;

@end

/**
 SDP message
 */
@interface SASessionDescriptionMessage : SASignalingMessage

@property(nonatomic, readonly) RTCSessionDescription *sessionDescription;

- (instancetype)initWithDescription:(RTCSessionDescription *)description;

@end

/**
 Bye Message
 */
@interface SAByeMessage : SASignalingMessage

@end

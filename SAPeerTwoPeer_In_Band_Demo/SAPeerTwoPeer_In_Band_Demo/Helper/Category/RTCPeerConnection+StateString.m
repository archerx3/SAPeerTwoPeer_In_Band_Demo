//
//  RTCPeerConnection+StateString.m
//  SAPeerTwoPeer_In_Band_Demo
//
//  Created by archer.chen on 6/7/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "RTCPeerConnection+StateString.h"

@implementation RTCPeerConnection (StateString)

- (NSString *)getSignalingStateString
{
    NSString * state = nil;
    
    switch (self.signalingState)
    {
        case RTCSignalingStateStable:
            state = @"RTCSignalingStateStable";
            break;
        case RTCSignalingStateHaveLocalOffer:
            state = @"RTCSignalingStateHaveLocalOffer";
            break;
        case RTCSignalingStateHaveLocalPrAnswer:
            state = @"RTCSignalingStateHaveLocalPrAnswer";
            break;
        case RTCSignalingStateHaveRemoteOffer:
            state = @"RTCSignalingStateHaveRemoteOffer";
            break;
        case RTCSignalingStateHaveRemotePrAnswer:
            state = @"RTCSignalingStateHaveRemotePrAnswer";
            break;
        case RTCSignalingStateClosed:
            state = @"RTCSignalingStateClosed";
            break;
        default:
            break;
    }
    
    return state;
}

@end

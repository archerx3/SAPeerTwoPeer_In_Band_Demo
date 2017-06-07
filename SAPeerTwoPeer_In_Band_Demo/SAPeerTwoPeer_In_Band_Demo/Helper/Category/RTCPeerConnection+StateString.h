//
//  RTCPeerConnection+StateString.h
//  SAPeerTwoPeer_In_Band_Demo
//
//  Created by archer.chen on 6/7/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <WebRTC/WebRTC.h>

@interface RTCPeerConnection (StateString)

- (NSString *)getSignalingStateString;

@end

//
//  SASignalingChannel.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SASignalingMessage.h"

typedef NS_ENUM(NSInteger, SASignalingChannelState) {
    kSASignalingChannelStateClosed,
    kSASignalingChannelStateOpen,
    kSASignalingChannelStateRegistered,
    kSASignalingChannelStateError
    
};

@protocol SASignalingChannel;
@protocol SASignalingChannelDelegate <NSObject>

- (void)signalingChannel:(id<SASignalingChannel>)channel didChangeState:(SASignalingChannelState)state;
- (void)signalingChannel:(id<SASignalingChannel>)channel didReceiveMessage:(SASignalingMessage *)message;

@end

@protocol SASignalingChannel <NSObject>

@property (nonatomic, readonly) NSString * roomId;
@property (nonatomic, readonly) SASignalingChannelState state;
@property (nonatomic, weak) id <SASignalingChannelDelegate> delegate;

- (void)createRoom;
- (void)joinForRoomId:(NSString *)roomId;

// Sends signaling message over the channel.
- (void)sendMessage:(SASignalingMessage *)message;

@end


//
//  SAPeerClient.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SASignalingChannel.h"
#import "SADataModel.h"

typedef NS_ENUM(NSInteger, SAPeerClientSignalingChannelState) {
    kSAPeerClientSignalingChannelStateDisconnected,
    kSAPeerClientSignalingChannelStateConnecting,
    kSAPeerClientSignalingChannelStateConnected,
    kSAPeerClientSignalingChannelStateRegistered,
};

typedef NS_ENUM(NSInteger, SAPeerClientDataChannelState) {
    kSAPeerClientDataChannelStateDisconnected,
    kSAPeerClientDataChannelStateConnecting,
    kSAPeerClientDataChannelStateConnected,
};

@class SAPeerClient;
@class SADataBuffer;

@protocol SAPeerClientDelegate <NSObject>

- (void)peerClient:(SAPeerClient *)client didChangeSignalingChannelState:(SAPeerClientSignalingChannelState)state;

- (void)peerClient:(SAPeerClient *)client didCreateRoom:(NSString *)roomNumber;

- (void)peerClient:(SAPeerClient *)client didChangeDataChannelState:(SAPeerClientDataChannelState)state;

- (void)peerClient:(SAPeerClient *)client didSendProgress:(CGFloat)prgress;

- (void)peerClient:(SAPeerClient *)client didReceiveProgress:(CGFloat)progress;
- (void)peerClient:(SAPeerClient *)client didReceiveDataWith:(SADataModel *)data;

- (void)peerClient:(SAPeerClient *)client didError:(NSError *)error;

@end

@interface SAPeerClient : NSObject

@property (nonatomic, readonly) SAPeerClientSignalingChannelState signalingChannelState;
@property (nonatomic, readonly) SAPeerClientDataChannelState dataChannelState;
@property (nonatomic, weak) id <SAPeerClientDelegate> delegate;

- (instancetype)initWithDelegate:(id<SAPeerClientDelegate>)delegate;

- (void)connectToRoomWithId:(NSString *)roomId;

- (void)sendData:(SADataModel *)dataModel;

- (void)disconnect;

@end

//
//  SAWebSocketChannel.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SASignalingChannel.h"

// Wraps a WebSocket connection to the AppRTC WebSocket server.
@interface SAWebSocketChannel : NSObject <SASignalingChannel>

- (instancetype)initWithURL:(NSURL *)url delegate:(id<SASignalingChannelDelegate>)delegate;


- (void)createRoom;
- (void)joinForRoomId:(NSString *)roomId;

- (void)sendMessage:(SASignalingMessage *)message;

- (void)leaveRoom;

@end

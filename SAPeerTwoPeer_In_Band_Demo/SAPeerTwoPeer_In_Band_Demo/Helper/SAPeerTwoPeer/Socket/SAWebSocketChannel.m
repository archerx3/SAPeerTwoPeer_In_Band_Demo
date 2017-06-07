//
//  SAWebSocketChannel.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAWebSocketChannel.h"

typedef NS_ENUM(NSInteger, SARoomOperationType) {
    
    SARoomOperationTypeCreate,
    SARoomOperationTypeJoin
    
};

static NSString const *kSAWSSMessageTypeKey = @"type";
static NSString const *kSAWSSMessageValueKey = @"value";

static NSString const *kSAWSSMessageCreateRoomKey = @"GETROOM";
static NSString const *kSAWSSMessageJoinRoomKey = @"ENTERROOM";

@interface SAWebSocketChannel () <SRWebSocketDelegate>
{
    NSURL * mURL;
    SRWebSocket * mSocket;
}

@end

@implementation SAWebSocketChannel

@synthesize delegate = mDelegate;
@synthesize state = mState;
@synthesize roomId = mRoomId;

#pragma mark -- initialization
- (instancetype)initWithURL:(NSURL *)url delegate:(id<SASignalingChannelDelegate>)delegate
{
    if (self = [super init])
    {
        mURL = url;
        mDelegate = delegate;
        
        mSocket = [[SRWebSocket alloc] initWithURL:url];
        mSocket.delegate = self;
        
        NSLog(@"Opening WebSocket.");
        
        [mSocket open];
    }
    
    return self;
}

#pragma mark --

- (void)dealloc
{
    [self disconnect];
}

#pragma mark --

- (void)setState:(SASignalingChannelState)state
{
    if (mState != state)
    {
        mState = state;
        
        [mDelegate signalingChannel:self didChangeState:mState];
    }
}

#pragma mark -- Public

- (void)createRoom
{
    if (mState == kSASignalingChannelStateOpen)
    {
        [self registerWithColliderWith:SARoomOperationTypeCreate];
    }
}

- (void)joinForRoomId:(NSString *)roomId
{
    NSParameterAssert(roomId.length);
    
    mRoomId = roomId;
    if (mState == kSASignalingChannelStateOpen)
    {
        [self registerWithColliderWith:SARoomOperationTypeJoin];
    }
}

- (void)sendMessage:(SASignalingMessage *)message
{
    NSData *data = [message JSONData];
    
    if (mState == kSASignalingChannelStateRegistered)
    {
        NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [mSocket send:messageString];
        
        NSLog(@"%s\nSend message : %@", __func__, message);
    }
    else
    {
        NSLog(@"%s\nCan not send message : %@", __func__, message);
    }
}

- (void)leaveRoom
{
    [self disconnect];
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"WebSocket connection opened.");
    self.state = kSASignalingChannelStateOpen;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    SASignalingMessage *signalingMessage = [SASignalingMessage messageFromJSONString:message];
    
    if (signalingMessage.type == kSASignalingMessageTypeOffer)
    {
        self.state = kSASignalingChannelStateRegistered;
    }
    
    [mDelegate signalingChannel:self didReceiveMessage:signalingMessage];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"WebSocket error: %@", error);
    self.state = kSASignalingChannelStateError;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket closed with code: %ld reason:%@ wasClean:%d", (long)code, reason, wasClean);
    
    NSParameterAssert(mState != kSASignalingChannelStateError);
    self.state = kSASignalingChannelStateClosed;
}

#pragma mark -- Private

- (void)disconnect
{
    if (mState == kSASignalingChannelStateClosed || mState == kSASignalingChannelStateError)
    {
        return;
    }
    
    [mSocket close];
}

- (void)registerWithColliderWith:(SARoomOperationType)type
{
    if (mState == kSASignalingChannelStateError || mState == kSASignalingChannelStateClosed)
    {
        return;
    }
    
    NSDictionary *message = nil;
    
    if (type == SARoomOperationTypeCreate)
    {
        message = @{kSAWSSMessageTypeKey : kSAWSSMessageCreateRoomKey, kSAWSSMessageValueKey : @""};
    }
    else
    {
        NSParameterAssert(mRoomId.length);
        
        message = @{kSAWSSMessageTypeKey : kSAWSSMessageJoinRoomKey, kSAWSSMessageValueKey : @(mRoomId.integerValue)};
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:message
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];

    NSString *messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [mSocket send:messageString];
    
    if (type == SARoomOperationTypeJoin)
    {
        self.state = kSASignalingChannelStateRegistered;
    }
}

@end

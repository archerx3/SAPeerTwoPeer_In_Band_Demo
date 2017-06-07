//
//  SAPeerClient.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAPeerClient.h"

#import "SAWebSocketChannel.h"
#import "SAWebSocketChannel.h"
#import "SAData.h"
#import "SADataBuffer.h"
#import "SADataSender.h"

#import "RTCIceServer+JSON.h"
#import "RTCDataChannel+JSON.h"
#import "RTCPeerConnection+StateString.h"

static NSString * const kSAPeerTwoPeerSignalingServerURL = @"ws://69.60.161.216:30002/signaling";

@interface SAPeerClient ()
<
SASignalingChannelDelegate,
RTCPeerConnectionDelegate,
RTCDataChannelDelegate,
SADataSenderDelegate
>
{
    SAPeerClientSignalingChannelState mSignalingChannelState;
    SAPeerClientDataChannelState mDataChannelState;
    
    SAWebSocketChannel *mWebSocketChannel;
    BOOL mSignalingServerOpened;
    
    BOOL mJoinedRoomShouldCreateOffer;
    
    RTCPeerConnectionFactory * mFactory;
    RTCPeerConnection * mCurrentPeerConnection;
    RTCDataChannel * mCurrentDataChannel;
    
    NSString * mCurrentRoom;
    
    SADataSender * mDataSender;
    SAData * mCacheData;
    
    NSUInteger mOffset;
    
    BOOL mShouldSendWaitingData;
    BOOL mShouldCheckIfSendWaitingData;
}

@end

@implementation SAPeerClient

@synthesize signalingChannelState   = mSignalingChannelState;
@synthesize dataChannelState        = mDataChannelState;
@synthesize delegate                = mDelegate;

#pragma mark - initialization

- (instancetype)initWithDelegate:(id<SAPeerClientDelegate>)delegate
{
    if (self = [super init])
    {
        mDelegate = delegate;
        [self initializationPeerClient];
    }
    return self;
}

- (void)initializationPeerClient
{
    mSignalingServerOpened = NO;
    mJoinedRoomShouldCreateOffer = NO;
    mShouldSendWaitingData = NO;
    mShouldCheckIfSendWaitingData = NO;
    
    NSURL * signalingServerURL = [NSURL URLWithString:kSAPeerTwoPeerSignalingServerURL];
    mWebSocketChannel = [[SAWebSocketChannel alloc] initWithURL:signalingServerURL delegate:self];
    
//    RTCSetMinDebugLogLevel(RTCLoggingSeverityVerbose);
    
    mFactory = [[RTCPeerConnectionFactory alloc] init];
    
    mCacheData = [SAData data];
    
    [self createPeerConnection];
}

#pragma mark -

- (void)setSignalingChannelState:(SAPeerClientSignalingChannelState)signalingChannelState
{
    if (mSignalingChannelState != signalingChannelState)
    {
        mSignalingChannelState = signalingChannelState;
        
        [self checkSignalingChannelState];
        
        if (mDelegate && [mDelegate respondsToSelector:@selector(peerClient:didChangeSignalingChannelState:)])
        {
            [mDelegate peerClient:self didChangeSignalingChannelState:mSignalingChannelState];
        }
    }
    else
    {
        if (mSignalingChannelState == kSAPeerClientSignalingChannelStateDisconnected)
        {
            if (mDelegate && [mDelegate respondsToSelector:@selector(peerClient:didChangeSignalingChannelState:)])
            {
                [mDelegate peerClient:self didChangeSignalingChannelState:mSignalingChannelState];
            }
        }
    }
    
}

- (void)setDataChannelState:(SAPeerClientDataChannelState)dataChannelState
{
    if (mDataChannelState != dataChannelState)
    {
        mDataChannelState = dataChannelState;
        
        if (mDelegate && [mDelegate respondsToSelector:@selector(peerClient:didChangeDataChannelState:)])
        {
            [mDelegate peerClient:self didChangeDataChannelState:mDataChannelState];
        }
    }
}

- (void)setDelegate:(id<SAPeerClientDelegate>)delegate
{
    if (mDelegate != delegate)
    {
        mDelegate = delegate;
    }
}

#pragma mark - Public
- (void)connectToRoomWithId:(NSString *)roomId
{
    if (mSignalingServerOpened)
    {
        if (roomId && roomId.length > 0)
        {
            mCurrentRoom = roomId;
            mJoinedRoomShouldCreateOffer = YES;
            [mWebSocketChannel joinForRoomId:roomId];
        }
        else
        {
            [mWebSocketChannel createRoom];
        }
    }
}

- (void)sendData:(SADataModel *)dataModel;
{
    NSAssert((dataModel.data != nil), @"The data that need to send is nil!");
    
    if ([self canSendDataUsingDataChannel])
    {
        mDataSender = [[SADataSender alloc] initWithDataModel:dataModel dataChannel:mCurrentDataChannel delegate:self];
        
        RTCDataBuffer * dataBuffer = [mCurrentDataChannel BeginOfferJSONStringWithDataModel:dataModel];
        
        if ([mCurrentDataChannel sendData:dataBuffer])
        {
            NSLog(@"Send data buffer success!");
        }
        else
        {
            NSLog(@"Send data buffer failed!");
        }
    }
    else
    {
        NSLog(@"Can not send data using data channel@\n mCurrentDataChannel : %@\n Data Channel State: %ld\n self.dataChannelState : %ld", mCurrentDataChannel, (long)mCurrentDataChannel.readyState, (long)self.dataChannelState);
    }
}

- (void)disconnect
{
    [mCurrentPeerConnection close];
    [mWebSocketChannel leaveRoom];
}

#pragma mark - SASignalingChannelDelegate
- (void)signalingChannel:(id<SASignalingChannel>)channel didChangeState:(SASignalingChannelState)state
{
    switch (state)
    {
        case kSASignalingChannelStateClosed:
        case kSASignalingChannelStateError:
        {
            self.signalingChannelState = kSAPeerClientSignalingChannelStateDisconnected;
            mWebSocketChannel = nil;
        }
            break;
        case kSASignalingChannelStateOpen:
            self.signalingChannelState = kSAPeerClientSignalingChannelStateConnected;
            break;
        case kSASignalingChannelStateRegistered:
            self.signalingChannelState = kSAPeerClientSignalingChannelStateRegistered;
            break;
        default:
            break;
    }
}

- (void)signalingChannel:(id<SASignalingChannel>)channel didReceiveMessage:(SASignalingMessage *)message
{
    if ([message isKindOfClass:[SASessionDescriptionMessage class]])
    {
        [self receiveSessionDescriptionMessage:(SASessionDescriptionMessage *)message];
    }
    else if ([message isKindOfClass:[SAICECandidateMessage class]])
    {
        if (mCurrentPeerConnection && [(SAICECandidateMessage *)message candidate])
        {
            [mCurrentPeerConnection addIceCandidate:[(SAICECandidateMessage *)message candidate]];
            NSLog(@"Add ice candidate");
        }
    }
    else if ([message isKindOfClass:[SAICECandidateRemovalMessage class]])
    {
        
    }
    else if ([message isKindOfClass:[SAByeMessage class]])
    {
        
    }
    else if ([message isKindOfClass:[SAGetRoomMessage class]])
    {
        mCurrentRoom = [(SAGetRoomMessage *)message roomNumber];
        
        NSLog(@"Create room %@", mCurrentRoom);
        
        if (mDelegate && [mDelegate respondsToSelector:@selector(peerClient:didCreateRoom:)])
        {
            [mDelegate peerClient:self didCreateRoom:mCurrentRoom];
        }
    }
    
}

#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged
{
    NSString * state = nil;
    BOOL signalingConnectionIsClosed = NO;
    switch (stateChanged)
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
        {
            state = @"RTCSignalingStateClosed";
            signalingConnectionIsClosed = YES;
        }
            break;
        default:
            break;
    }
    NSLog(@"%s\n%@", __func__, state);
    
    if (signalingConnectionIsClosed)
    {
        self.signalingChannelState = kSAPeerClientSignalingChannelStateDisconnected;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream
{
    NSLog(@"%s", __func__);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream
{
    NSLog(@"%s", __func__);
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection
{
    NSLog(@"Peer connection should negotiate!");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState
{
    NSString * state = nil;
    BOOL dataChannelIsClosed = NO;
    switch (newState)
    {
        case RTCIceConnectionStateNew:
            state = @"RTCIceConnectionStateNew";
            break;
        case RTCIceConnectionStateChecking:
            state = @"RTCIceConnectionStateChecking";
            break;
        case RTCIceConnectionStateConnected:
            state = @"RTCIceConnectionStateConnected";
            break;
        case RTCIceConnectionStateCompleted:
            state = @"RTCIceConnectionStateCompleted";
            break;
        case RTCIceConnectionStateFailed:
        {
            state = @"RTCIceConnectionStateFailed";
            dataChannelIsClosed = YES;
        }
            break;
        case RTCIceConnectionStateDisconnected:
            state = @"RTCIceConnectionStateDisconnected";
            break;
        case RTCIceConnectionStateClosed:
        {
            state = @"RTCIceConnectionStateClosed";
            dataChannelIsClosed = YES;
        }
            break;
        case RTCIceConnectionStateCount:
            state = @"RTCIceConnectionStateCount";
            break;
        default:
            break;
    }
    NSLog(@"%s\n%@", __func__, state);
    
    if (dataChannelIsClosed)
    {
//        self.dataChannelState = kSAPeerClientDataChannelStateDisconnected;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState
{
    NSString * state = nil;
    switch (newState)
    {
        case RTCIceGatheringStateNew:
            state = @"RTCIceGatheringStateNew";
            break;
        case RTCIceGatheringStateGathering:
            state = @"RTCIceGatheringStateGathering";
            break;
        case RTCIceGatheringStateComplete:
            state = @"RTCIceGatheringStateComplete";
            break;
        default:
            break;
    }
    NSLog(@"%s\n%@", __func__, state);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate
{
    SAICECandidateMessage * message = [[SAICECandidateMessage alloc] initWithCandidate:candidate];
    
    if (mSignalingServerOpened)
    {
        NSLog(@"Send ice candidate");
        [mWebSocketChannel sendMessage:message];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates
{
    NSLog(@"%s", __func__);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    switch (dataChannel.readyState)
    {
        case RTCDataChannelStateConnecting:
        {
            NSLog(@"%s RTCDataChannelStateConnecting", __func__);
            
            self.dataChannelState = kSAPeerClientDataChannelStateConnecting;
        }
            break;
        case RTCDataChannelStateOpen:
        {
            if (!mCurrentDataChannel)
            {
                mCurrentDataChannel = dataChannel;
                mCurrentDataChannel.delegate = self;
                NSLog(@"%s\nSet up mCurrentDataChannel", __func__);
            }
            self.dataChannelState = kSAPeerClientDataChannelStateConnected;
        }
            break;
        case RTCDataChannelStateClosing:
        {
            NSLog(@"%s RTCDataChannelStateClosing", __func__);
            self.dataChannelState = kSAPeerClientDataChannelStateDisconnected;
        }
            break;
        case RTCDataChannelStateClosed:
        {
            NSLog(@"%s RTCDataChannelStateClosed", __func__);
            self.dataChannelState = kSAPeerClientDataChannelStateDisconnected;
        }
            break;
    }
}

#pragma mark - RTCDataChannelDelegate
- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel
{
    NSLog(@"%s", __func__);
    
    switch (dataChannel.readyState)
    {
        case RTCDataChannelStateConnecting:
        {
            self.dataChannelState = kSAPeerClientDataChannelStateConnecting;
        }
            break;
        case RTCDataChannelStateOpen:
        {
            self.dataChannelState = kSAPeerClientDataChannelStateConnected;
        }
            break;
        case RTCDataChannelStateClosing:
        {
            NSLog(@"%s RTCDataChannelStateClosing", __func__);
            self.dataChannelState = kSAPeerClientDataChannelStateDisconnected;
        }
            break;
        case RTCDataChannelStateClosed:
        {
            NSLog(@"%s RTCDataChannelStateClosed", __func__);
            self.dataChannelState = kSAPeerClientDataChannelStateDisconnected;
        }
            break;
    }
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    if (buffer.isBinary)
    {
        [self parserBinaryData:buffer];
    }
    else
    {
        [self parserJSONData:buffer];
    }
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didChangeBufferedAmount:(uint64_t)amount
{
    NSLog(@"\n%s\namount:%llu", __func__, amount);
    // Data buffer amount
    [mDataSender dataBufferAmountDidChangeBufferedAmount:amount dataChannel:dataChannel];
}

#pragma mark - SADataSenderDelegate
- (void)dataSender:(SADataSender *)dataSender didChangedState:(SADataSenderState)newState
{
    switch (newState)
    {
        case SADataSenderStateDefault:
        {
            NSLog(@"Reset data sender state ");
        }
            break;
        case SADataSenderStateDataGenerating:
        {
            NSLog(@"Data sender is generating data!");
        }
            break;
        case SADataSenderStateDataGeneratedFailed:
        {
            NSLog(@"Data sender split data failed!");
        }
            break;
        case SADataSenderStateDataGeneratedSuccess:
        {
            mShouldSendWaitingData = YES;
            [self sendWaitingData];
        }
            break;
        case SADataSenderStateSending:
        {
            NSLog(@"Sending data ...");
        }
            break;
        case SADataSenderStateSentFailed:
        {
            NSLog(@"Sent data failed!");
        }
            break;
        case SADataSenderStateSuspend:
        {
            NSLog(@"Send data suspend!");
        }
            break;
        case SADataSenderStateResume:
        {
            NSLog(@"Send data resume!");
        }
            break;
        case SADataSenderStateCompleted:
        {
            NSLog(@"Send data completed!");
        }
            break;
        default:
            break;
    }
}

- (void)dataSender:(SADataSender *)dataSender didSendProgress:(CGFloat)progress
{
    if ([mDelegate respondsToSelector:@selector(peerClient:didSendProgress:)])
    {
        [mDelegate peerClient:self didSendProgress:progress];
    }
}

#pragma mark - Configure
- (RTCConfiguration *)defaultConfiguration
{
    RTCConfiguration * configuration = [[RTCConfiguration alloc] init];
    RTCIceServer * defaultIceServer = [RTCIceServer defaultRTCIceServer];
    configuration.iceServers = @[defaultIceServer];
    
    return configuration;
}

- (RTCMediaConstraints *)defaultConstraints
{
    NSDictionary *constraintDict = nil;
    NSDictionary *optionalDict = nil;
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:constraintDict optionalConstraints:optionalDict];
    
    return constraints;
}

#pragma mark - Private
- (BOOL)canSendDataUsingDataChannel
{
    return mCurrentDataChannel && mCurrentDataChannel.readyState == RTCDataChannelStateOpen && self.dataChannelState == kSAPeerClientDataChannelStateConnected;
}

- (void)checkSignalingChannelState
{
    switch (self.signalingChannelState)
    {
        case kSAPeerClientSignalingChannelStateDisconnected:
        case kSAPeerClientSignalingChannelStateConnecting:
            mSignalingServerOpened = NO;
            break;
        case kSAPeerClientSignalingChannelStateConnected:
            mSignalingServerOpened = YES;
            break;
        case kSAPeerClientSignalingChannelStateRegistered:
            [self joinedRoom];
            break;
        default:
            mSignalingServerOpened = NO;
            break;
    }
}

- (void)createPeerConnection
{
    if (mCurrentPeerConnection)
    {
        NSLog(@"%s\n Setup mCurrentPeerConnection to nil", __func__);
        mCurrentPeerConnection.delegate = nil;
        mCurrentPeerConnection = nil;
    }
    // Create peer connection
    mCurrentPeerConnection = [mFactory peerConnectionWithConfiguration:[self defaultConfiguration]
                                                           constraints:[self defaultConstraints]
                                                              delegate:self];
    
    if (!mCurrentPeerConnection)
    {
        NSLog(@"Create peer connection failed!");
    }
}

- (void)createDataChannel
{
    if (mCurrentPeerConnection)
    {
        RTCDataChannelConfiguration * dataChannelConfiguration = [[RTCDataChannelConfiguration alloc] init];
        dataChannelConfiguration.isOrdered = YES;
//        dataChannelConfiguration.channelId = 100;
        dataChannelConfiguration.isNegotiated = NO;
        
        NSString * label = [NSString stringWithFormat:@"datachannel_%@caller", mCurrentRoom];
        
        mCurrentDataChannel = [mCurrentPeerConnection dataChannelForLabel:label configuration:dataChannelConfiguration];
        
        if (mCurrentDataChannel)
        {
            mCurrentDataChannel.delegate = self;
            NSLog(@"Create data channel successful");
        }
        else
        {
            NSLog(@"Create data channel failed");
        }
    }
    else
    {
        NSLog(@"mCurrentPeerConnection is nil!");
    }
}

- (void)createOffer
{
    if (mCurrentPeerConnection)
    {
        __weak SAPeerClient * weakSelf = self;
        [mCurrentPeerConnection offerForConstraints:[self defaultConstraints]
                                  completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                                      
                                      [mCurrentPeerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                                          
                                          if (error)
                                          {
                                              NSLog(@"\n%s\nSet local sdp failed!%@", __func__, error.localizedDescription);
                                          }
                                          else
                                          {
                                              [weakSelf sendSessionDescription:sdp];
                                          }
                                          
                                      }];
            
        }];
    }
    else
    {
        NSLog(@"%s\nmCurrentPeerConnection is nil", __func__);
    }
}

- (void)createAnswer
{
    if (mCurrentPeerConnection)
    {
        __weak SAPeerClient * weakSelf = self;
        [mCurrentPeerConnection answerForConstraints:[self defaultConstraints]
                                   completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                                       
                                       [mCurrentPeerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                                           
                                           if (error)
                                           {
                                               NSLog(@"\n%s\nSet local sdp failed!%@", __func__, error.localizedDescription);
                                           }
                                           else
                                           {
                                               [weakSelf sendSessionDescription:sdp];
                                           }
                                           
                                       }];
                                       
                                   }];
    }
    else
    {
        NSLog(@"%s\nmCurrentPeerConnection is nil", __func__);
    }
}

- (void)sendSessionDescription:(RTCSessionDescription *)sdp
{
    SASessionDescriptionMessage *offerMessage = [[SASessionDescriptionMessage alloc] initWithDescription:sdp];
    [mWebSocketChannel sendMessage:offerMessage];
}

- (void)joinedRoom
{
    if (mJoinedRoomShouldCreateOffer)
    {
        mJoinedRoomShouldCreateOffer = NO;
        [self createDataChannel];
        [self createOffer];
    }
}

- (void)receiveSessionDescriptionMessage:(SASessionDescriptionMessage *)message
{
    SASignalingMessageType type = message.type;
    
    if (type == kSASignalingMessageTypeAnswer)
    {
        [self receiveAnswerMessage:message];
    }
    else if (type == kSASignalingMessageTypeOffer)
    {
        [self receiveOfferMessage:message];
    }
}

- (void)receiveOfferMessage:(SASessionDescriptionMessage *)message
{
    if (!mCurrentPeerConnection)
    {
        [self createPeerConnection];
    }
    
    NSLog(@"Receice offer");
    NSLog(@"%s\n signaling state of current peer connetion is : %@", __func__, [mCurrentPeerConnection getSignalingStateString]);
    __weak SAPeerClient * weakSelf = self;
    [mCurrentPeerConnection setRemoteDescription:message.sessionDescription
                               completionHandler:^(NSError * _Nullable error) {
        
                                   if (error)
                                   {
                                       NSLog(@"%s\nSetup remote sdp failed!\n %@", __func__, error.localizedDescription);
                                   }
                                   else
                                   {
                                       [weakSelf createAnswer];
                                   }
    
                               }];
}

- (void)receiveAnswerMessage:(SASessionDescriptionMessage *)message
{
    if (!mCurrentPeerConnection)
    {
        NSLog(@"%s\nmCurrentPeerConnection is nil", __func__);
    }
    
    NSLog(@"Receice answer");
    NSLog(@"%s\n signaling state of current peer connetion is : %@", __func__, [mCurrentPeerConnection getSignalingStateString]);
    [mCurrentPeerConnection setRemoteDescription:message.sessionDescription
                               completionHandler:^(NSError * _Nullable error) {
        
                                   if (error)
                                   {
                                       NSLog(@"%s\nSetup remote sdp failed!\n %@", __func__, error.localizedDescription);
                                   }

                               }];
}

#pragma mark -- Parser RTCDataBuffer
- (void)parserBinaryData:(RTCDataBuffer *)dataBuffer
{
    if (!dataBuffer.isBinary)
    {
        NSAssert(0, @"Parser object is a JSON data!");
    }
    else
    {
        NSData * binaryData = dataBuffer.data;
        
        if (mCacheData.state == SADataStateBegin || mCacheData.state == SADataStateTransferring)
        {
            if (mCacheData.state == SADataStateBegin)
            {
                mCacheData.state = SADataStateTransferring;
            }
            
            [mCacheData addData:binaryData];
            
            CGFloat completed = (CGFloat)mCacheData.data.length;
            CGFloat total = (CGFloat)mCacheData.estimatedSize;
            CGFloat progress = completed / total;
            NSLog(@"Receive progress : %.2f%%", progress * 100);
            
            [self callBackReceiveProgress:progress];
            
            if (mCacheData.data.length < mCacheData.estimatedSize)
            {
                
            }
            else
            {
                mCacheData.state = SADataStateCompleted;
                
                RTCDataBuffer * offerDataBuffer = [mCurrentDataChannel CompletedOfferJSONStringWithData:mCacheData];
                [mCurrentDataChannel sendData:offerDataBuffer];
            }
        }
    }
}

- (void)parserJSONData:(RTCDataBuffer *)dataBuffer
{
    if (dataBuffer.isBinary)
    {
        NSAssert(0, @"Parser object is a binary data!");
    }
    else
    {
        SADataBufferType type = [mCurrentDataChannel dataBufferTypeWithData:dataBuffer];
        
        switch (type)
        {
            case SADataBufferTypeBeginOffer:
            {
                RTCDataBuffer * answerDataBuffer = [mCurrentDataChannel BeginAnswerJSONStringWithData:dataBuffer];
                [mCurrentDataChannel sendData:answerDataBuffer];
                
                mCacheData.estimatedSize = [mCurrentDataChannel estimatedSizeWithData:dataBuffer];
                mCacheData.dataType = [mCurrentDataChannel dataTypeStringWithData:dataBuffer];
                mCacheData.state = SADataStateBegin;
            }
                break;
            case SADataBufferTypeBeginAnswer:
            {
                // Should Send waiting data
                mShouldCheckIfSendWaitingData = YES;
                
                [self sendWaitingData];
            }
                break;
            case SADataBufferTypeCompletedOffer:
            {
                RTCDataBuffer * answerDataBuffer = [mCurrentDataChannel CompletedAnswerJSONStringWithData:dataBuffer];
                [mCurrentDataChannel sendData:answerDataBuffer];
                NSLog(@"%@ data send complete!", mDataSender.dataModel.dataTypeString);
                [mDataSender clearDataModel];
            }
                break;
            case SADataBufferTypeCompletedAnswer:
            {
                NSLog(@"%@ data receive complete!", mCacheData.dataType);
                [self dataReceiveCompleted];
            }
                break;
            case SADataBufferTypeError:
            {
                NSLog(@"%s\nError!", __func__);
            }
                break;
        }
    }
}

#pragma mark - Handler events

- (void)sendWaitingData
{
    if (mShouldSendWaitingData && mShouldCheckIfSendWaitingData)
    {
        mShouldSendWaitingData = NO;
        mShouldCheckIfSendWaitingData = NO;
        
        if ([self canSendDataUsingDataChannel] && mDataSender.dataModel)
        {
            [mDataSender sendDataUnderDataChannel:mCurrentDataChannel];
        }
        else
        {
            NSLog(@"");
        }
    }
    else
    {
        if (mShouldSendWaitingData && !mShouldCheckIfSendWaitingData)
        {
            NSLog(@"finish splite data, waiting send request!");
        }
        else if (!mShouldSendWaitingData && mShouldCheckIfSendWaitingData)
        {
            NSLog(@"Receive the send request, waiting splite data!");
        }
        else
        {
            NSLog(@" ");
        }
    }
}

- (void)callBackReceiveProgress:(CGFloat)progress
{
    if ([mDelegate respondsToSelector:@selector(peerClient:didReceiveProgress:)])
    {
        [mDelegate peerClient:self didReceiveProgress:progress];
    }
}

- (void)callBackSendProgress:(CGFloat)progress
{
    if ([mDelegate respondsToSelector:@selector(peerClient:didSendProgress:)])
    {
        [mDelegate peerClient:self didSendProgress:progress];
    }
}

- (void)dataReceiveCompleted
{
    SADataModel * dataModel = [SADataModel dataModelWith:mCacheData.dataType data:mCacheData.data sourceType:SADataModelSourceTypeRemote];
    
    [mCacheData clearData];
    
    if (dataModel)
    {
        if ([mDelegate respondsToSelector:@selector(peerClient:didReceiveDataWith:)])
        {
            [mDelegate peerClient:self didReceiveDataWith:dataModel];
        }
    }
    else
    {
        NSLog(@"%s\nFailed to construct data model!", __func__);
    }
}

@end

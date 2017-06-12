//
//  SADataSender.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/26/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataSender.h"
#import "SADataBuffer.h"
#import "SAPeerClient.h"

#pragma mark -
#pragma mark -
#pragma mark -- SABlockOperation

@interface SASendDataBlockOperation : NSBlockOperation

- (instancetype)initWithData:(NSData *)data dataChannel:(RTCDataChannel *)dataChannel;

@end

@interface SASendDataBlockOperation ()
{
    NSData * mData;
    RTCDataChannel * mCurrentDataChannel;
    BOOL mExecuting;
    BOOL mSendDataResult;
    BOOL mFinished;
}

@end

@implementation SASendDataBlockOperation

@synthesize finished = mFinished;
@synthesize executing = mExecuting;

- (instancetype)initWithData:(NSData *)data dataChannel:(RTCDataChannel *)dataChannel
{
    if (self = [super init])
    {
        mData = data;
        mCurrentDataChannel = dataChannel;
        mExecuting = NO;
        mSendDataResult = NO;
        mFinished = NO;
    }
    return self;
}

- (void)main
{
    RTCDataBuffer * dataBuffer = [[RTCDataBuffer alloc] initWithData:mData isBinary:YES];
    mSendDataResult = [mCurrentDataChannel sendData:dataBuffer];
    
    if (mSendDataResult)
    {
        NSLog(@"Send data successful!");
    }
    else
    {
        NSLog(@"Send data failed!");
    }
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    mExecuting = NO;
    mFinished = mSendDataResult;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start
{
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        mFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    mExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

@end

#pragma mark -
#pragma mark -
#pragma mark -- SADataSender

#define SADataChannelBufferPoolthreshold 1024*1024

@interface SADataSender () <SADataBufferDelegate>
{
    NSOperationQueue * mDataQueue;
    
    NSRecursiveLock * mLock;
    
    SADataModel * mDataModel;
    SADataBuffer * mDataBuffer;
    RTCDataChannel * mCurrentDataChannel;
    
    BOOL mHadCompletedSendData;
    
    NSUInteger mHadSentChunk;
    NSUInteger mCurrentShouldSendChunk;
}

@property (nonatomic, readwrite) SADataSenderState state;

@end

@implementation SADataSender

@synthesize dataModel = mDataModel;
@synthesize delegate = mDelegate;

- (instancetype)initWithDataModel:(SADataModel *)dataModel dataChannel:(RTCDataChannel *)dataChannel delegate:(id <SADataSenderDelegate>)delegate
{
    if (self = [super init])
    {
        mDataModel = dataModel;
        mCurrentDataChannel = dataChannel;
        mDelegate = delegate;
        [self initializationDataSender];
    }
    return self;
}

- (void)initializationDataSender
{
    mHadCompletedSendData = NO;
    
    mHadSentChunk = 0;
    mCurrentShouldSendChunk = 0;
    
    mDataBuffer = [[SADataBuffer alloc] initWithData:mDataModel.data delegate:self];
    
    mLock = [[NSRecursiveLock alloc] init];
}

#pragma mark - 
- (void)setState:(SADataSenderState)state
{
    if (_state != state)
    {
        _state = state;
        
        NSLog(@"Change sender state to %@", [self getDataSenderStateString]);
        
        if ([mDelegate respondsToSelector:@selector(dataSender:didChangedState:)])
        {
            [mDelegate dataSender:self didChangedState:_state];
        }
    }
}

#pragma mark - Public

- (void)clearDataModel
{
    mDataModel = nil;
    
    [mDataQueue waitUntilAllOperationsAreFinished];
    
    mDataQueue = nil;
    
    mHadCompletedSendData = NO;
    self.state = SADataSenderStateDefault;
}

- (void)sendDataUnderDataChannel:(RTCDataChannel *)dataChannel
{
    if (!dataChannel)
    {
        NSLog(@"Data channel is nil, so can not send data!");
    }
    else
    {
        if (dataChannel != mCurrentDataChannel)
        {
            NSLog(@"Data channel has changed!");
        }
        
        if (self.state == SADataSenderStateDataGeneratedSuccess)
        {
            mDataQueue = [[NSOperationQueue alloc] init];
            mDataQueue.name = @"com.peertwopeer.dataTransferQueue.%@", [NSDate date];
            mDataQueue.maxConcurrentOperationCount = 1;
            
            [self sendTheNextChunkDataUnderDataChannel:dataChannel];
        }
        else
        {
            NSLog(@"Need handler other state: %@", [self getDataSenderStateString]);
        }
    }
}

#pragma mark - Private
- (void)sendTheNextChunkDataUnderDataChannel:(RTCDataChannel *)dataChannel
{
    [mLock lock];
    
    if (mHadCompletedSendData || self.state == SADataSenderStateCompleted)
    {
        [mLock unlock];
        return;
    }
    
    NSUInteger dataCounts = mDataBuffer.datas.count;

    NSLog(@"data channel buffer amount :%llu", dataChannel.bufferedAmount);
    NSLog(@"data channel buffer pool threshold :%d",SADataChannelBufferPoolthreshold);
//    NSLog(<#NSString * _Nonnull format, ...#>)
    
    BOOL shouldSend = (mCurrentShouldSendChunk < dataCounts &&
                       ((dataChannel.bufferedAmount < SADataChannelBufferPoolthreshold) ? YES : NO) &&
                        (!mHadCompletedSendData || self.state != SADataSenderStateCompleted));
    
    if (shouldSend)
    {
        if (self.state == SADataSenderStateDataGeneratedSuccess ||
            self.state == SADataSenderStateSuspend ||
            self.state == SADataSenderStateSending)
        {
            self.state = SADataSenderStateSending;
        }
        else
        {
            NSLog(@"Data sender state : %@", [self getDataSenderStateString]);
        }
        
        NSData * waitingSendData = mDataBuffer.datas[mCurrentShouldSendChunk];
        
        if (waitingSendData)
        {
            SASendDataBlockOperation * sendOperation = [[SASendDataBlockOperation alloc] initWithData:waitingSendData dataChannel:mCurrentDataChannel];
            
            if (mDataQueue.operations.count > 0)
            {
                [sendOperation addDependency:mDataQueue.operations.lastObject];
            }
            
            __weak SASendDataBlockOperation * weakOperation = sendOperation;
            __weak SADataSender * weakSelf = self;
            
            CGFloat hadSendSize = mHadSentChunk * SADataChannelBufferChunkSize + (CGFloat)(waitingSendData.length);
            
            [sendOperation setCompletionBlock:^{
               
                if (weakOperation.isFinished)
                {
                    NSLog(@"Send RTCDataBuffer <Generated by %lu chunk data> successful", (unsigned long)mCurrentShouldSendChunk);
                    [weakSelf handlerCountForSendData];
                    [weakSelf calculationProgressWithHadSendDataLength:hadSendSize];
                }
                else
                {
                    NSLog(@"Send RTCDataBuffer <Generated by %lu chunk data> failed", (unsigned long)mCurrentShouldSendChunk);
//                    [weakSelf goOnSendNextChunkData];
                }
                
            }];
            
            [mDataQueue addOperation:sendOperation];
        }
        else
        {
            NSLog(@"Get waiting send data failed! Sending chunk : %ld", mCurrentShouldSendChunk);
//            [self goOnSendNextChunkData];
            self.state = SADataSenderStateSentFailed;
        }
    }
    else
    {
        BOOL shouldSuspend = NO;
        if (dataChannel.bufferedAmount >= SADataChannelBufferPoolthreshold && (!mHadCompletedSendData || self.state != SADataSenderStateCompleted))
        {
            NSLog(@"%s\nBuffer amount is more than buffer pool threshold!\nBuffered amount : %ld\nBuffer pool threshold : %d",__func__ , (long)(dataChannel.bufferedAmount), SADataChannelBufferPoolthreshold);
            
            shouldSuspend = YES;
        }
        
        if (mCurrentShouldSendChunk >= dataCounts)
        {
            NSLog(@"\nCurrent should send chunk is %ld\nThe count of datas is :%ld", mCurrentShouldSendChunk, dataCounts);
        }
        
        if (shouldSuspend)
        {
            self.state = SADataSenderStateSuspend;
        }
        else
        {
            if (self.state == SADataSenderStateCompleted || mHadCompletedSendData)
            {
                
            }
            else
            {
                self.state = SADataSenderStateSentFailed;
            }
        }
    }
    
    [mLock unlock];
}

- (void)calculationProgressWithHadSendDataLength:(CGFloat)hadSendSize
{
    CGFloat totalSize = mDataBuffer.totalSize;

    CGFloat progress = hadSendSize / totalSize;
    NSLog(@"Send progress:%.2f%%", progress * 100);

    if ([mDelegate respondsToSelector:@selector(dataSender:didSendProgress:)])
    {
        [mDelegate dataSender:self didSendProgress:progress];
    }
    
    if (hadSendSize >= totalSize)
    {
        mHadCompletedSendData = YES;
        self.state = SADataSenderStateCompleted;
    }
    else
    {
        [self goOnSendNextChunkData];
    }
}

- (void)handlerCountForSendData
{
    mCurrentShouldSendChunk += 1;
    mHadSentChunk += 1;
}

- (void)goOnSendNextChunkData
{
    [self sendTheNextChunkDataUnderDataChannel:mCurrentDataChannel];
}

- (NSString *)getDataSenderStateStringWithState:(SADataSenderState)state
{
    switch (state)
    {
        case SADataSenderStateDefault:
            return @"SADataSenderStateDefault";
            break;
        case SADataSenderStateDataGenerating:
            return @"SADataSenderStateDataGenerating";
            break;
        case SADataSenderStateDataGeneratedFailed:
            return @"SADataSenderStateDataGeneratedFailed";
            break;
        case SADataSenderStateDataGeneratedSuccess:
            return @"SADataSenderStateDataGeneratedSuccess";
            break;
        case SADataSenderStateSending:
            return @"SADataSenderStateSending";
            break;
        case SADataSenderStateSentFailed:
            return @"SADataSenderStateSentFailed";
            break;
        case SADataSenderStateSuspend:
            return @"SADataSenderStateSuspend";
            break;
        case SADataSenderStateResume:
            return @"SADataSenderStateResume";
            break;
        case SADataSenderStateCompleted:
            return @"SADataSenderStateCompleted";
            break;
    }
}

- (NSString *)getDataSenderStateString
{
    return [self getDataSenderStateStringWithState:_state];
}

#pragma mark - Over write
- (NSString *)description
{
    NSMutableString * string = [NSMutableString string];
    
    [string appendFormat:@"\nSADataSender: %p\n", &self];
    [string appendFormat:@"{\n"];
    [string appendFormat:@"    data sender state : %@\n", [self getDataSenderStateString]];
//    [string appendFormat:@"    Count of data : %ld\n", mDataArray.count];
    [string appendFormat:@"    Delegate class: %@\n", [mDelegate class]];
    [string appendFormat:@"    Delegate : %@\n", mDelegate];
    [string appendString:@"}"];
    
    return string;
}

#pragma mark - SADataBufferDelegate

- (void)dataBuffer:(SADataBuffer *)dataBuffer didChangedState:(SADataBufferState)newState
{
    switch (newState)
    {
        case SADataBufferStateDefault:
            self.state = SADataSenderStateDefault;
            break;
        case SADataBufferStateSpliting:
            self.state = SADataSenderStateDataGenerating;
            break;
        case SADataBufferStateSplitFailed:
            self.state = SADataSenderStateDataGeneratedFailed;
            break;
        case SADataBufferStateCompleted:
            self.state = SADataSenderStateDataGeneratedSuccess;
            break;
        default:
            break;
    }
}

#pragma mark - Private

@end

#pragma mark -
#pragma mark -
#pragma mark -- SADataSender + DataBufferAmount

@implementation SADataSender (DataBufferAmount)

- (void)dataBufferAmountDidChangeBufferedAmount:(uint64_t)amount dataChannel:(RTCDataChannel *)dataChannel
{
    if (dataChannel == mCurrentDataChannel)
    {
        NSLog(@"%s\nBuffer amount is more than buffer pool threshold!\nBuffered amount : %ld\nBuffer pool threshold : %d",__func__ , (long)(dataChannel.bufferedAmount), SADataChannelBufferPoolthreshold);
        if (dataChannel.bufferedAmount >= SADataChannelBufferPoolthreshold)
        {
            NSLog(@"%s\nCurrent sender state :%@\n State should be %@",__func__ , [self getDataSenderStateString], [self getDataSenderStateStringWithState:SADataSenderStateSuspend]);
        }
        else
        {
            NSLog(@"%s\nCurrent sender state :%@",__func__ , [self getDataSenderStateString]);
        }
        
        if (self.state == SADataSenderStateSuspend)
        {
            [self sendTheNextChunkDataUnderDataChannel:dataChannel];
        }
    }
    else
    {
        NSLog(@"%s\nData channel is different!",__func__ );
    }
}

@end

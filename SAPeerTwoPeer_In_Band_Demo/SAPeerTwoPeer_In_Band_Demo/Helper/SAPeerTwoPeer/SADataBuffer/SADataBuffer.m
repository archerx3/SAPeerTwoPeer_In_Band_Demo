//
//  SADataBuffer.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataBuffer.h"
#import "NSData+Split.h"

@interface SADataBuffer ()
{
    CGFloat mTotalSize;
    NSData * mData;
    NSArray * mDataArray;
    SADataBufferState mSplitState;
}

@property(nonatomic, readwrite) SADataBufferState splitState;

@end

@implementation SADataBuffer

@synthesize totalSize = mTotalSize;
@synthesize datas = mDataArray;
@synthesize splitState = mSplitState;
@synthesize delegate = mDelegate;

- (instancetype)initWithData:(NSData *)data delegate:(id <SADataBufferDelegate>)delegate
{
    if (self = [super init])
    {
        NSAssert(data, @"Data must be exist!");
        mData = data;
        mTotalSize = mData.length;
        mDelegate = delegate;
        [self initializationDataBuffer];
    }
    
    return self;
}

- (void)initializationDataBuffer
{
    self.splitState = SADataBufferStateDefault;
    mDataArray = [NSArray array];
    [self splitData];
}

- (void)setSplitState:(SADataBufferState)splitState
{
    if (mSplitState != splitState)
    {
        mSplitState = splitState;
    }
    
    if ([mDelegate respondsToSelector:@selector(dataBuffer:didChangedState:)])
    {
        [mDelegate dataBuffer:self didChangedState:mSplitState];
    }
}

#pragma mark - Private
- (void)splitData
{
    self.splitState = SADataBufferStateSpliting;
    
    __weak SADataBuffer * weakSelf = self;
    [mData splitDataWithSplitChunkSize:SADataChannelBufferChunkSize
                        completedBlock:^(BOOL completed, NSArray <NSData *>*datas, NSError *error) {
        
                            if (completed)
                            {
                                weakSelf.splitState = SADataBufferStateCompleted;
                                self->mDataArray = datas;
                            }
                            else
                            {
                                weakSelf.splitState = SADataBufferStateSplitFailed;
                            }
    
                        }];
}

- (NSString *)getSpliteSate
{
    switch (mSplitState)
    {
        case SADataBufferStateDefault:
            return @"SADataBufferStateDefault";
            break;
        case SADataBufferStateSpliting:
            return @"SADataBufferStateSpliting";
            break;
        case SADataBufferStateSplitFailed:
            return @"SADataBufferStateSplitFailed";
            break;
        case SADataBufferStateCompleted:
            return @"SADataBufferStateCompleted";
            break;
        default:
            break;
    }
}

#pragma mark - Over write
- (NSString *)description
{
    NSMutableString * string = [NSMutableString string];
    
    [string appendFormat:@"\nSADataBuffer: %p\n", &self];
    [string appendFormat:@"{\n"];
    [string appendFormat:@"    Split state : %@\n", [self getSpliteSate]];
    [string appendFormat:@"    Count of data : %ld\n", mDataArray.count];
    [string appendFormat:@"    Delegate class: %@\n", [mDelegate class]];
    [string appendFormat:@"    Delegate : %@\n", mDelegate];
    [string appendString:@"}"];
    
    return string;
}

@end

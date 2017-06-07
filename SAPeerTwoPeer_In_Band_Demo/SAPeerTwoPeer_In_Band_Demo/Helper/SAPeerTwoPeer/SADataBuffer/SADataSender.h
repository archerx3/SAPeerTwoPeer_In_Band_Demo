//
//  SADataSender.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/26/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SADataModel.h"

typedef NS_ENUM(NSUInteger, SADataSenderState) {
    
    SADataSenderStateDefault = 0,
    SADataSenderStateDataGenerating,
    SADataSenderStateDataGeneratedFailed,
    SADataSenderStateDataGeneratedSuccess,
    SADataSenderStateSending,
    SADataSenderStateSentFailed,
    SADataSenderStateSuspend,
    SADataSenderStateResume,
    SADataSenderStateCompleted,
};

@protocol SADataSenderDelegate;
@class SAPeerClient;

@interface SADataSender : NSObject

@property (nonatomic, strong, readonly) SADataModel * dataModel;

@property (nonatomic, readonly) SADataSenderState state;

@property (nonatomic, weak, readonly) id <SADataSenderDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDataModel:(SADataModel *)dataModel dataChannel:(RTCDataChannel *)dataChannel delegate:(id <SADataSenderDelegate>)delegate;

/**
 set data model to nil
 */
- (void)clearDataModel;

/**
 Send data in dataModel. Only can call when state is SADataSenderStateDataGeneratedSuccess

 @param dataChannel Send data using which data channel
 */
- (void)sendDataUnderDataChannel:(RTCDataChannel *)dataChannel;

@end

#pragma mark - SADataSenderDelegate
@protocol SADataSenderDelegate <NSObject>

- (void)dataSender:(SADataSender *)dataSender didChangedState:(SADataSenderState)newState;

- (void)dataSender:(SADataSender *)dataSender didSendProgress:(CGFloat)progress;

@end

#pragma mark - SADataSender + DataBufferAmount
@interface SADataSender (DataBufferAmount)

- (void)dataBufferAmountDidChangeBufferedAmount:(uint64_t)amount dataChannel:(RTCDataChannel *)dataChannel;

@end

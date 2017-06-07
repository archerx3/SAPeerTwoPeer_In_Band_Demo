//
//  RTCDataChannel+JSON.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <WebRTC/WebRTC.h>
#import "SADataModel.h"
#import "SAData.h"

typedef NS_ENUM(NSUInteger, SADataBufferType) {
    SADataBufferTypeError,
    SADataBufferTypeBeginOffer,
    SADataBufferTypeBeginAnswer,
    SADataBufferTypeCompletedOffer,
    SADataBufferTypeCompletedAnswer,
};

@interface RTCDataChannel (JSON)

- (RTCDataBuffer *)BeginOfferJSONStringWithDataModel:(SADataModel *)dataModel;
- (RTCDataBuffer *)BeginAnswerJSONStringWithData:(RTCDataBuffer *)dataBuffer;

- (CGFloat)estimatedSizeWithData:(RTCDataBuffer *)dataBuffer;
- (NSString *)dataTypeStringWithData:(RTCDataBuffer *)dataBuffer;
- (SADataBufferType)dataBufferTypeWithData:(RTCDataBuffer *)dataBuffer;

- (RTCDataBuffer *)CompletedOfferJSONStringWithData:(SAData *)data;
- (RTCDataBuffer *)CompletedAnswerJSONStringWithData:(RTCDataBuffer *)dataBuffer;

@end

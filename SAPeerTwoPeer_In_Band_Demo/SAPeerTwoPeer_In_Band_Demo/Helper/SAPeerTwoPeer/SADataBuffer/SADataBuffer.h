//
//  SADataBuffer.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SADataChannelBufferChunkSize 250*1024

typedef NS_ENUM(NSUInteger, SADataBufferState) {
    
    SADataBufferStateDefault,
    SADataBufferStateSpliting,
    SADataBufferStateSplitFailed,
    SADataBufferStateCompleted,
    
};

@protocol SADataBufferDelegate;

/**
 
 */
@interface SADataBuffer : NSObject

@property(nonatomic, readonly) CGFloat totalSize;
/** Data chunk array */
@property(nonatomic, readonly) NSArray <NSData *>*datas;

@property(nonatomic, readonly) SADataBufferState splitState;

@property(nonatomic, weak, readonly) id <SADataBufferDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initialize an SAataBuffer from NSData.
 */
- (instancetype)initWithData:(NSData *)data delegate:(id <SADataBufferDelegate>)delegate;

@end

@protocol SADataBufferDelegate <NSObject>

- (void)dataBuffer:(SADataBuffer *)dataBuffer didChangedState:(SADataBufferState)newState;

@end

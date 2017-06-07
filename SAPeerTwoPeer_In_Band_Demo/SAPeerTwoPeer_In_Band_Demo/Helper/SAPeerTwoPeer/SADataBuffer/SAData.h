//
//  SAData.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SADataState) {
    
    SADataStateDefault,
    SADataStateBegin,
    SADataStateTransferring,
    SADataStateCompleted,
    
};


/**
 Class of receive cache data
 */
@interface SAData : NSObject

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString * dataType;
@property (nonatomic) NSUInteger estimatedSize; 
@property (nonatomic) SADataState state;

+ (instancetype)data;

- (void)addData:(NSData *)data;
- (void)clearData;

@end

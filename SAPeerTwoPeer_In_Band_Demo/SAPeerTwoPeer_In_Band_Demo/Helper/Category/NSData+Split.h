//
//  NSData+Split.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SASplitDataCompletedBlock)(BOOL completed, NSArray <NSData *> * datas, NSError * error);

@interface NSData (Split)

- (void)splitDataWithSplitChunkSize:(NSUInteger)chunk completedBlock:(SASplitDataCompletedBlock)block;

@end

//
//  SADataModel+MediaInfo.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataModel.h"

@interface SADataModel (MediaInfo)

+ (SADataModel *)dataModelWithMediaInfo:(NSDictionary *)mediaInfo;
+ (NSArray <SADataModel *> *)dataModelWithMediaInfos:(NSArray <NSDictionary *>*)mediaInfos;

@end

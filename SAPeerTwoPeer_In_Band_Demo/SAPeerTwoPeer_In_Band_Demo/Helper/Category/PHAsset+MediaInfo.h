//
//  PHAsset+MediaInfo.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (MediaInfo)

+ (void)mediaInfoFromPHAsset:(PHAsset *)asset
               progressBlock:(void (^)(double progress, BOOL *stop))progressBlock
              completedBlock:(void(^)(NSDictionary *mediaInfo))completeblock;

@end

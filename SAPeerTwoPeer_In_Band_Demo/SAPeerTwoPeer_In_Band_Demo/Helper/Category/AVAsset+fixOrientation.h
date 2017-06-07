//
//  AVAsset+fixOrientation.h
//  StoAmigo
//
//  Created by simon.zeng on 5/28/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef void(^AVAssetExportCompleteHandler)(NSURL * outputURL, NSError * error);

@interface AVAsset (fixOrientation)

+ (AVMutableVideoComposition *)videoCompositionFor:(AVAsset *)asset;

- (AVAssetExportSession *)exportAssetWithExtension:(NSString *)fileExt completionHandler:(AVAssetExportCompleteHandler)handler;

- (AVAssetExportSession *)exportVideoWithFixedOrientationWithCompletionHandler:(AVAssetExportCompleteHandler)handler;

@end

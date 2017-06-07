//
//  AVAsset+fixOrientation.m
//  StoAmigo
//
//  Created by simon.zeng on 5/28/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import "AVAsset+fixOrientation.h"

#import "CryptoHelpers.h"
#import "NSString+MIMEType.h"


@implementation AVAsset (fixOrientation)

+ (AVMutableVideoComposition *)videoCompositionFor:(AVAsset *)asset
{
    if (!asset || !asset.tracks || asset.tracks.count == 0)
    {
        return nil;
    }
    
    AVAssetTrack *firstAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    //FIXING ORIENTATION//
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstAssetTrack];
    
    BOOL  isFirstAssetPortrait_  = NO;
    
    CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
    
    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)
    {
        
    }
    if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)
    {
        
    }
    if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)
    {
        isFirstAssetPortrait_ = YES;
    }
    if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0)
    {
        isFirstAssetPortrait_ = YES;
    }
    
    CGSize screenSize = firstAssetTrack.naturalSize;// Scale to a higher resolution is not supported on iOS5
    CGSize renderSize = CGSizeZero;
    
    if(isFirstAssetPortrait_)
    {
        renderSize = screenSize;
    }
    else
    {
        renderSize = CGSizeMake(screenSize.height, screenSize.width);
    }
    
    [firstlayerInstruction setTransform:firstTransform atTime:kCMTimeZero];
    
    [firstlayerInstruction setOpacity:0.0 atTime:asset.duration];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction,nil];;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, firstAssetTrack.nominalFrameRate);
    mainCompositionInst.renderSize = renderSize;
    
    return mainCompositionInst;
}

- (AVAssetExportSession *)exportAssetWithExtension:(NSString *)fileExt completionHandler:(AVAssetExportCompleteHandler)handler
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self presetName:AVAssetExportPresetPassthrough];
    
    exporter.shouldOptimizeForNetworkUse = YES;
    
    NSString * outputFileType = [NSString UTIStringFromExtension:fileExt];
    
    if ([exporter.supportedFileTypes containsObject:outputFileType])
    {
        exporter.outputFileType = outputFileType;
    }
    else
    {
        outputFileType = AVFileTypeQuickTimeMovie;
        
        if ([fileExt isEqualToString:@"wav"] ||
            [fileExt isEqualToString:@"wave"] ||
            [fileExt isEqualToString:@"bwf"]
            )
        {
            outputFileType = AVFileTypeWAVE;
        }
        else if ([fileExt isEqualToString:@"aif"] ||
                 [fileExt isEqualToString:@"aiff"]
                 )
        {
            outputFileType = AVFileTypeAIFF;
        }
        else if ([fileExt isEqualToString:@"aifc"] ||
                 [fileExt isEqualToString:@"cdda"]
                 )
        {
            outputFileType = AVFileTypeAIFC;
        }
        else if ([fileExt isEqualToString:@"amr"])
        {
            outputFileType = AVFileTypeAMR;
        }
        else if ([fileExt isEqualToString:@"m4a"] ||
                 [fileExt isEqualToString:@"au"] ||
                 [fileExt isEqualToString:@"snd"] ||
                 [fileExt isEqualToString:@"ac3"])
        {
            outputFileType = AVFileTypeAppleM4A;
        }
        
        exporter.outputFileType = outputFileType;
    }
    
    NSString * exportFileExt = [NSString extensionFromUTI:exporter.outputFileType];
    
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"temp-%@.%@", [CryptoHelpers createMD5:[[(AVURLAsset *)self URL] absoluteString]], exportFileExt]];
    
    [fileManager removeItemAtPath:tempPath error:NULL];
    
    exporter.outputURL = [NSURL fileURLWithPath:tempPath];
    
    NSLog(@"Supported type: %@ (Using:%@)", exporter.supportedFileTypes, outputFileType);
    
    __weak AVAssetExportSession * weakExporter = exporter;
    [exporter exportAsynchronouslyWithCompletionHandler:^ {
        
         if (handler)
         {
             AVAssetExportSessionStatus status = weakExporter.status;
             NSError * error = weakExporter.error;
             
             if (status == AVAssetExportSessionStatusCompleted)
             {
                 NSLog(@"Export succeeded: %@", self);
                 
                 NSURL *outputURL = weakExporter.outputURL;
                 
                 if ([[exportFileExt lowercaseString] isEqual:[fileExt lowercaseString]])
                 {
                     handler(outputURL, nil);
                 }
                 else
                 {
                     NSURL * correctedURL = [[outputURL URLByDeletingPathExtension] URLByAppendingPathExtension:fileExt];
                     
                     [fileManager removeItemAtURL:correctedURL error:NULL];
                     [fileManager moveItemAtURL:outputURL toURL:correctedURL error:NULL];
                     
                     handler(correctedURL, nil);
                 }
             }
             else if (status == AVAssetExportSessionStatusCancelled)
             {
                 NSLog(@"Export cancelled: %@", self);
                 handler(nil, weakExporter.error);
             }
             else
             {
                 NSLog(@"Export failed with error: %@ (%@): %@", error.localizedDescription, @(error.code), self);
                 handler(nil, weakExporter.error);
             }
         }
     }];
    
    return exporter;
}

- (AVAssetExportSession* )exportVideoWithFixedOrientationWithCompletionHandler:(AVAssetExportCompleteHandler)handler
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%lld-%d.MOV", (long long)[[NSDate date] timeIntervalSince1970], arc4random() % 1000]];
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self presetName:AVAssetExportPresetHighestQuality];
    
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.videoComposition = [[self class] videoCompositionFor:self];
    exporter.shouldOptimizeForNetworkUse = YES;
    
    __weak AVAssetExportSession * weakExporter = exporter;
    [exporter exportAsynchronouslyWithCompletionHandler:^ {
        
                  if (handler)
         {
             AVAssetExportSessionStatus status = weakExporter.status;
             NSError * error = weakExporter.error;
             
             if (status == AVAssetExportSessionStatusCompleted)
             {
                 NSLog(@"Export succeeded: %@", self);
                 
                 NSURL *outputURL = weakExporter.outputURL;
                 
                 handler(outputURL, nil);
             }
             else if (status == AVAssetExportSessionStatusCancelled)
             {
                 NSLog(@"Export cancelled: %@", self);
                 handler(nil, weakExporter.error);
             }
             else
             {
                 NSLog(@"Export failed with error: %@ (%@): %@", error.localizedDescription, @(error.code), self);
                 handler(nil, weakExporter.error);
             }
         }
     }];
    
    return exporter;
}

@end

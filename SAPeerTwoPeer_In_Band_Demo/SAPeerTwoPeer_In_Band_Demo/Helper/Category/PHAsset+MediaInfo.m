//
//  PHAsset+MediaInfo.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "PHAsset+MediaInfo.h"

@implementation PHAsset (MediaInfo)

+ (void)mediaInfoFromPHAsset:(PHAsset *)asset
               progressBlock:(void (^)(double progress, BOOL *stop))progressBlock
              completedBlock:(void(^)(NSDictionary *mediaInfo))completeblock
{
    __block NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    
    PHAssetMediaType assetType = asset.mediaType;
    
    [mediaInfo setObject:@(assetType) forKey:UIImagePickerControllerMediaType];
    
    PHContentEditingInputRequestOptions *options = [PHContentEditingInputRequestOptions new];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, BOOL *stop) {
        
        NSLog(@"cache image Asset: %f", progress);
        progressBlock(progress, stop);
    };
    
    NSString * localIdentifier = [[asset.localIdentifier componentsSeparatedByString:@"/"] firstObject];
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        
        if (contentEditingInput)
        {
            NSURL *imageURL = contentEditingInput.fullSizeImageURL;
            AVAsset * avAsset = contentEditingInput.audiovisualAsset;
            
            // Selected asset is an image
            if (imageURL)
            {
                NSString *fileName = [imageURL lastPathComponent];
                
                [mediaInfo setObject:[imageURL lastPathComponent] forKey:@"name"];
                
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                
                NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                
                if (imageData && [imageData writeToFile:tempPath atomically:YES])
                {
                    // Get file size
                    NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath
                                                                                                     error:NULL];
                    if (fileAttributes)
                    {
                        [mediaInfo setObject:fileAttributes[NSFileSize] forKey:NSFileSize];
                    }
                    
                    [mediaInfo setObject:[NSURL URLWithString:tempPath] forKey:UIImagePickerControllerReferenceURL];
                    completeblock(mediaInfo);
                }
                else
                {
                    completeblock(nil);
                }
            }
            // Selected asset is an AVAsset
            else if (avAsset)
            {
                NSURL * videoURL = [(AVURLAsset *)avAsset URL];
                
                if (videoURL)
                {
                    NSLog(@"\n\n%@\n\n", videoURL);
                    
                    NSString * fileName = videoURL.lastPathComponent;
                    
                    // In case video is a SLO-MO type, which is rendered with different name every time.
                    // We use its unique local identifier as file name
                    if (contentEditingInput.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate)
                    {
                        fileName = [localIdentifier stringByAppendingPathExtension:fileName.pathExtension];
                    }
                    
                    // Get file size
                    [mediaInfo setObject:fileName forKey:@"name"];
                    
                    // Get file size
                    NSError * error = nil;
                    
                    NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[videoURL path]
                                                                                                     error:&error];
                    if (fileAttributes)
                    {
                        [mediaInfo setObject:fileAttributes[NSFileSize] forKey:NSFileSize];
                    }
                    
                    [mediaInfo setObject:videoURL forKey:UIImagePickerControllerReferenceURL];
                    
                    completeblock(mediaInfo);
                }
                else
                {
                    completeblock(nil);
                }
            }
        }
        else
        {
            completeblock(nil);
        }
    }];
}

@end

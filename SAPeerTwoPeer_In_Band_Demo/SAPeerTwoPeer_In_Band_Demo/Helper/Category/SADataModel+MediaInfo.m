//
//  SADataModel+MediaInfo.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataModel+MediaInfo.h"
#import "CryptoHelpers.h"
#import "AVAsset+fixOrientation.h"

@implementation SADataModel (MediaInfo)

+ (SADataModel *)dataModelWithMediaInfo:(NSDictionary *)mediaInfo
{
    SADataModel * dataModel;
    
    NSNumber * assetTypeNumber = mediaInfo[UIImagePickerControllerMediaType];
    NSURL *assetReferenceURL = mediaInfo[UIImagePickerControllerReferenceURL];
    NSString * mediaName = mediaInfo[@"name"];
    NSNumber * fileSize = mediaInfo[NSFileSize];
    
    NSLog(@"\n%@\n%@\n%@\n%@\n",assetTypeNumber,assetReferenceURL, mediaName, fileSize);
    
    NSString * assetURLString = nil;
    if ([assetReferenceURL isFileURL])
    {
        assetURLString = assetReferenceURL.relativePath;
    }
    else
    {
        assetURLString = assetReferenceURL.absoluteString;
    }
    
    NSURL * referrenceURL = [NSURL URLWithString:assetURLString];
    if (!referrenceURL)
    {
        referrenceURL = [NSURL fileURLWithPath:assetURLString];
    }
    
    NSString * fileExt = [referrenceURL pathExtension];
    
    NSString * tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"temp-%@.%@", [CryptoHelpers createMD5:assetURLString], fileExt]];
    
    NSError * error = nil;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager copyItemAtPath:assetURLString toPath:tempPath error:&error];
    
    __block NSData * data = nil;
    if ([assetTypeNumber isEqualToNumber:@(1)])   // PHAssetMediaTypeImage   = 1
    {
        if (success)
        {
            data = [NSData dataWithContentsOfFile:tempPath];
            
            if (data)
            {
                dataModel = [SADataModel dataModelWith:@"image" data:data sourceType:SADataModelSourceTypeLocal];
            }
        }
        
    }
    else if ([assetTypeNumber isEqualToNumber:@(2)])  // PHAssetMediaTypeVideo   = 2
    {
        AVAsset * anAsset = nil;
        NSString *scheme = referrenceURL.scheme;
        if ([scheme isEqual:@"assets-library"])
        {
            anAsset = [AVAsset assetWithURL:referrenceURL];
        }
        else
        {
            NSString * string = [NSString stringWithFormat:@"file://%@",assetURLString];
            
            NSURL * url = [NSURL URLWithString:string];
            
            anAsset = [AVAsset assetWithURL:url];
        }
        
        if (anAsset)
        {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [anAsset exportAssetWithExtension:fileExt
                            completionHandler:^(NSURL *outputURL, NSError *error) {
                                
                                if ([referrenceURL isFileURL])
                                {
                                    [[NSFileManager defaultManager] removeItemAtURL:referrenceURL error:NULL];
                                }
                                
                                data = [NSData dataWithContentsOfURL:outputURL];
                                
                                dispatch_semaphore_signal(semaphore);
                            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        if (data)
        {
            dataModel = [SADataModel dataModelWith:@"video" data:data sourceType:SADataModelSourceTypeLocal];
        }
    }
    else if ([assetTypeNumber isEqualToNumber:@(3)])  // PHAssetMediaTypeAudio   = 3
    {
        
    }
    
    return dataModel;
}

+ (NSArray <SADataModel *> *)dataModelWithMediaInfos:(NSArray <NSDictionary *>*)mediaInfos
{
    NSMutableArray * dataModels = [NSMutableArray array];
    
    for (NSDictionary * mediaInfo in mediaInfos)
    {
        SADataModel * dataModel = [SADataModel dataModelWithMediaInfo:mediaInfo];
        
        if (dataModel)
        {
            [dataModels addObject:dataModel];
        }
    }
    
    return dataModels;
}

@end

//
//  SAImagePickerHandler.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAImagePickerHandler.h"
#import "PHAsset+MediaInfo.h"

@interface SAImagePickerHandler ()<QBImagePickerControllerDelegate>
{
    QBImagePickerController * mImagePickerVC;
}

@end

@implementation SAImagePickerHandler

@synthesize imagePickerController = mImagePickerVC;
@synthesize delegate = mDelegate;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initializationImagePickerHandler];
    }
    return self;
}

- (void)initializationImagePickerHandler
{
    [self initializationImagePickerViewController];
}

- (void)initializationImagePickerViewController
{
    mImagePickerVC = [[QBImagePickerController alloc] init];
    mImagePickerVC.allowsMultipleSelection = YES;
    mImagePickerVC.minimumNumberOfSelection = 1;
    mImagePickerVC.maximumNumberOfSelection = 2;

    mImagePickerVC.numberOfColumnsInPortrait = 4;
    mImagePickerVC.numberOfColumnsInLandscape = 7;

    mImagePickerVC.delegate = self;
}

- (void)exitImagePicker
{
    [mImagePickerVC.selectedAssets removeAllObjects];
    [mImagePickerVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    __block NSMutableArray * mediaInfos = [NSMutableArray array];
    __block NSInteger count = 0;
    
    for (PHAsset * asset in assets)
    {
        __weak SAImagePickerHandler * weakSelf = self;
        [PHAsset mediaInfoFromPHAsset:asset
                        progressBlock:nil
                       completedBlock:^(NSDictionary *mediaInfo) {
            
                           if (mediaInfo)
                           {
                               [mediaInfos addObject:mediaInfo];
                           }
                           
                           count += 1;
                           
                           if (count == assets.count)
                           {
                               if ([mDelegate respondsToSelector:@selector(imagePickerHandler:didFinishPickingMediaInfos:)])
                               {
                                   [mDelegate imagePickerHandler:weakSelf didFinishPickingMediaInfos:mediaInfos];
                               }
                               
                               [weakSelf exitImagePicker];
                               
                           }
        
                       }];
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    if ([mDelegate respondsToSelector:@selector(imagePickerHandlerDidCancel:)])
    {
        [mDelegate imagePickerHandlerDidCancel:self];
    }
    
    [self exitImagePicker];
}

@end

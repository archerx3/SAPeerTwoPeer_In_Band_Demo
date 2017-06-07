//
//  SAImagePickerHandler.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAImagePickerHandlerDelegate;

@interface SAImagePickerHandler : NSObject

@property (nonatomic, strong) QBImagePickerController * imagePickerController;
@property (nonatomic, weak) id <SAImagePickerHandlerDelegate> delegate;

@end

@protocol SAImagePickerHandlerDelegate <NSObject>

- (void)imagePickerHandler:(SAImagePickerHandler *)handler didFinishPickingMediaInfos:(NSArray<NSDictionary *>*)mediaInfos;
- (void)imagePickerHandlerDidCancel:(SAImagePickerHandler *)handler;

@end

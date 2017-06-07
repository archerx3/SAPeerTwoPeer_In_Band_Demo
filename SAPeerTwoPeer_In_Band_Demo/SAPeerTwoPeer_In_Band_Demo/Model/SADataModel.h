//
//  SADataModel.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SADataModelDefaultEstimatedHeight 44.0f

#define SADataModelImageWidth 260.0f
#define SADataModelImageHeight 90.0f

#define SADataModelTextWidth 240.0f

#define SADataModelTextFontSize 13.0f

#define SADataModelTextFontName @"Helvetica"

typedef NS_ENUM(NSUInteger, SADataModelType) {
    
    SADataModelTypeDefault,
    SADataModelTypeImage,
    SADataModelTypeVideo,
    SADataModelTypeAudio,
    SADataModelTypeText,
};

typedef NS_ENUM(NSUInteger, SADataModelSourceType) {
    SADataModelSourceTypeLocal,
    SADataModelSourceTypeRemote,
    SADataModelSourceTypeThirdParty,
};


/**
 Data model
 */
@interface SADataModel : NSObject

@property (nonatomic, readonly) SADataModelType dataType;
@property (nonatomic, readonly) SADataModelSourceType sourceType;
@property (nonatomic, strong, readonly) NSString * dataTypeString;

/**
 Record received data expected size
 */
@property (nonatomic, assign, readonly) CGFloat estimatedHeight;

/**
 Description of current data model, used to display in the relevant cell
 */
@property (nonatomic, strong, readonly) id content;

@property (nonatomic, strong, readonly) NSData * data;

+ (instancetype)dataModelWith:(NSString *)dataTypeString data:(NSData *)data sourceType:(SADataModelSourceType)sourceType;

- (void)setupThumbnailImageForVideo;

@end

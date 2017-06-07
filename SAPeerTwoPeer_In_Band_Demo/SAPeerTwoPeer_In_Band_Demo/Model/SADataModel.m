//
//  SADataModel.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataModel.h"

#import "UIImage+Utilities.h"

@interface SADataModel ()
{
    NSData * mData;
}
@property (nonatomic, readwrite) SADataModelType dataType;
@property (nonatomic, readwrite) SADataModelSourceType sourceType;
@property (nonatomic, strong, readwrite) NSString * dataTypeString;

@property (nonatomic, assign, readwrite) CGFloat estimatedHeight;
@property (nonatomic, strong, readwrite) id content;
@property (nonatomic, strong, readwrite) NSData * data;

@end

@implementation SADataModel

@synthesize data = mData;

+ (instancetype)dataModelWith:(NSString *)dataTypeString content:(id)content sourceType:(SADataModelSourceType)sourceType
{
    return [[SADataModel alloc] initWithDataTypeString:dataTypeString content:content sourceType:sourceType];
}

+ (instancetype)dataModelWith:(NSString *)dataTypeString data:(NSData *)data sourceType:(SADataModelSourceType)sourceType
{
    return [[SADataModel alloc] initWithDataTypeString:dataTypeString data:data sourceType:sourceType];
}

- (instancetype)initWithDataTypeString:(NSString *)dataTypeString content:(id)content sourceType:(SADataModelSourceType)sourceType
{
    if (self = [super init])
    {
        _dataTypeString = dataTypeString;
        _sourceType = sourceType;
        _content = content;
        [self initializationDataModel];
    }
    return self;
}

- (instancetype)initWithDataTypeString:(NSString *)dataTypeString data:(NSData *)data sourceType:(SADataModelSourceType)sourceType
{
    if (self = [super init])
    {
        _dataTypeString = dataTypeString;
        _sourceType = sourceType;
        mData = data;
        [self initializationDataModel];
    }
    return self;
}

- (void)initializationDataModel
{
    if (!_content)
    {
        if (mData)
        {
            _dataType = [self getDataModelType];
            _content = [self transferContent];
            [self calculateEstimatedHeight];
        }
        else
        {
            NSLog(@"Data and content are nil!");
        }
    }
    else
    {
        _dataType = [self getDataModelType];
        _content = [self transferContent];
        [self calculateEstimatedHeight];
    }
}

- (void)setupThumbnailImageForVideo
{
    
}

#pragma mark -- Private
- (SADataModelType)getDataModelType
{
    if ([_dataTypeString.lowercaseString isEqualToString:@"image"])
    {
        return SADataModelTypeImage;
    }
    else if ([_dataTypeString.lowercaseString isEqualToString:@"text"])
    {
        return SADataModelTypeText;
    }
    else if ([_dataTypeString.lowercaseString isEqualToString:@"video"])
    {
        return SADataModelTypeVideo;
    }
    else if ([_dataTypeString.lowercaseString isEqualToString:@"audio"])
    {
        return SADataModelTypeAudio;
    }
    else
    {
        return SADataModelTypeDefault;
    }
}

- (id)transferContent
{
    if (mData)
    {
        if (_dataType == SADataModelTypeImage)
        {
            UIImage * image = [UIImage imageWithData:mData];
            
            if (image.size.width > image.size.height)
            {
                return [UIImage imageWithOriginImage:image scaleToWidth:SADataModelImageWidth];
            }
            else
            {
                return [UIImage imageWithOriginImage:image scaleToHeight:SADataModelImageHeight];
            }
        }
        else if (_dataType == SADataModelTypeText)
        {
            NSString * string = [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
            return string;
        }
        else if (_dataType == SADataModelTypeVideo)
        {
            // Video
            UIImage * videoPlaceHolder = [UIImage imageNamed:@"Icon-VideoPlaceHolder"];
            return videoPlaceHolder;
        }
        else if (_dataType == SADataModelTypeAudio)
        {
            UIImage * audioPlaceHolder = [UIImage imageNamed:@"Icon-AudioPlaceHolder"];
            return audioPlaceHolder;
        }
        else
        {
            return mData;
        }
    }
    else
    {
        return _content;
    }
}

- (void)calculateEstimatedHeight
{
    if (_dataType == SADataModelTypeImage)
    {
        _estimatedHeight = [self calcuateImageHeight];
    }
    else if (_dataType == SADataModelTypeText)
    {
        _estimatedHeight = [self calcuateTextHeight];
    }
    else if (_dataType == SADataModelTypeVideo)
    {
        _estimatedHeight = SADataModelDefaultEstimatedHeight + 10.0f;
    }
    else if (_dataType == SADataModelTypeAudio)
    {
        _estimatedHeight = SADataModelDefaultEstimatedHeight;
    }
    else
    {
        NSLog(@"%@ type content should be handler!", [_content class]);
        _estimatedHeight = SADataModelDefaultEstimatedHeight;
    }
}

- (CGFloat)calcuateImageHeight
{
    return ((UIImage *)_content).size.height + 10.0f;
}

- (CGFloat)calcuateTextHeight
{
    CGFloat height = SADataModelDefaultEstimatedHeight;
    NSString * string = (NSString *)_content;
    
    NSDictionary * options = @{NSFontAttributeName : [UIFont systemFontOfSize:SADataModelTextFontSize]};
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SADataModelTextWidth, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:options
                                       context:nil];
    
    height = rect.size.height;
    
    return height + 10.0f;
}

@end

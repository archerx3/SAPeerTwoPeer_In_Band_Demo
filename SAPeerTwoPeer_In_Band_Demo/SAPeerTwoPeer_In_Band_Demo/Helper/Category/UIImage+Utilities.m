//
//  UIImage+Utilities.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)imageForName:(NSString *)name color:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    if (!image)
    {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [color setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

+ (UIImage *)imageWithOriginImage:(UIImage *)image scaleToWidth:(CGFloat)defineWidth
{
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = targetWidth * (height / width);
    
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)imageWithOriginImage:(UIImage *)image scaleToHeight:(CGFloat)defineHeight
{
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetHeight = defineHeight;
    CGFloat targetWidth = targetHeight * (width / height);
    
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end

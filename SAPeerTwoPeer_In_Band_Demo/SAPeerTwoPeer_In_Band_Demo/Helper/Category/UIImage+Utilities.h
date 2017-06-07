//
//  UIImage+Utilities.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utilities)

// Returns an color tinted version for the given image resource.
+ (UIImage *)imageForName:(NSString *)name color:(UIColor *)color;

+ (UIImage *)imageWithOriginImage:(UIImage *)image scaleToWidth:(CGFloat)defineWidth;
+ (UIImage *)imageWithOriginImage:(UIImage *)image scaleToHeight:(CGFloat)defineHeight;

@end

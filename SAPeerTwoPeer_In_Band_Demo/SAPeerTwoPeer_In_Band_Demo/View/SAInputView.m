//
//  SAInputView.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAInputView.h"

@implementation SAInputView

+ (instancetype)inputView
{
    return [[SAInputView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self = [[NSBundle mainBundle] loadNibNamed:@"SAInputView" owner:nil options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.addButton.enabled = NO;
}

@end

//
//  SATextCell.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SATextCell.h"

@interface SATextCell ()
{
    UILabel * label;
}

@end

@implementation SATextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initializationImageCell];
    }
    return self;
}

- (void)initializationImageCell
{
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:SADataModelTextFontSize];
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    
    [self.contentView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.contentView.mas_top).with.offset(5.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(20.0f);
        make.width.mas_equalTo(SADataModelTextWidth);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5.0f);
        
    }];
}

- (void)setupCell
{
    [super setupCell];
    
    label.text = self.dataModel.content;
}

@end

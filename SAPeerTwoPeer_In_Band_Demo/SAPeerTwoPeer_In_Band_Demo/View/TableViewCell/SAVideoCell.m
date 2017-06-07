//
//  SAVideoCell.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/25/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAVideoCell.h"

@interface SAVideoCell ()
{
    UIImageView * imageView;
}

@end

@implementation SAVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initializationVideoCell];
    }
    return self;
}

- (void)initializationVideoCell
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.updateExisting = YES;
        make.top.equalTo(self.contentView.mas_top).with.offset(5.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(20.0f);
        make.width.mas_equalTo(SADataModelDefaultEstimatedHeight);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5.0f);
        
    }];
}

- (void)setupCell
{
    [super setupCell];
    
    imageView.image = self.dataModel.content;
}

@end

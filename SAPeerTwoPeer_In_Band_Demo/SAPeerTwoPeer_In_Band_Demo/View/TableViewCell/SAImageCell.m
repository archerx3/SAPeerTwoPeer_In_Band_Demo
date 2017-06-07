//
//  SAImageCell.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAImageCell.h"

@interface SAImageCell ()
{
    UIImageView * imageView;
}

@end

@implementation SAImageCell

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
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.updateExisting = YES;
        make.top.equalTo(self.contentView.mas_top).with.offset(5.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(20.0f);
        make.width.mas_equalTo(SADataModelImageWidth);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5.0f);
        
    }];
}

- (void)updateImageViewFramework:(CGSize)size
{
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.updateExisting = YES;
        make.top.equalTo(self.contentView.mas_top).with.offset(5.0f);
        make.left.equalTo(self.contentView.mas_left).with.offset(20.0f);
        make.size.mas_equalTo(size);
        
    }];
}

- (void)setupCell
{
    [super setupCell];
    
    UIImage *image = self.dataModel.content;
    
    CGSize imageSize = image.size;
    [self updateImageViewFramework:imageSize];
    
    imageView.image = self.dataModel.content;
}

@end

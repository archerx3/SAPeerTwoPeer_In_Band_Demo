//
//  SARoomView.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SARoomView.h"
#import "SAInputView.h"

@interface SARoomView ()
{
    UIView * mTopView;
    UILabel * mRoomLabel;
    
    UIButton * mBackButton;
    
    SATableView * mTableView;
    
    SAInputView * mInputView;
}

@end

@implementation SARoomView

@synthesize roomLabel = mRoomLabel;
@synthesize backButton = mBackButton;
@synthesize tableView = mTableView;
@synthesize inputView = mInputView;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initializationSubview];
    }
    
    return self;
}

- (void)initializationSubview
{
    self.backgroundColor = [UIColor grayColor];
    
    mTopView = [[UIView alloc] init];
    mTopView.backgroundColor = [UIColor whiteColor];
    mTopView.layer.cornerRadius = 5.0;
    mTopView.layer.masksToBounds = YES;
    
    [self addSubview:mTopView];
    
    [mTopView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.top.and.right.equalTo(self);
        make.height.mas_equalTo(65.0f);
        
    }];
    
    mBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mBackButton setBackgroundImage:[UIImage imageNamed:@"Icon-BackButton"] forState:UIControlStateNormal];
    
    [self addSubview:mBackButton];
    
    [mBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).with.offset(20.0f);
        make.left.equalTo(self.mas_left).with.offset(20.0f);
        make.size.mas_equalTo(CGSizeMake(30.0f, 30.0f));
        
    }];
    
    mRoomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    mRoomLabel.font = [UIFont fontWithName:@"" size:15.0f];
    mRoomLabel.layer.backgroundColor = [UIColor grayColor].CGColor;
    mRoomLabel.layer.cornerRadius = 3.0f;
    mRoomLabel.textColor = [UIColor blackColor];
    mRoomLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:mRoomLabel];
    
    [mRoomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).with.offset(20.0f);
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(150.0f, 30.0f));
        
    }];
    
    mTableView = [[SATableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mTableView.layer.cornerRadius = 5.0f;
    mTableView.layer.masksToBounds = YES;
    
    [self addSubview:mTableView];
    
    [mTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(mRoomLabel.mas_bottom).with.offset(20.0f);
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).with.offset(-55.0f);
        
    }];
    
    mInputView = [SAInputView inputView];
    mInputView.layer.cornerRadius = 5.0f;
    mInputView.layer.masksToBounds = YES;
    [self addSubview:mInputView];
    
    [mInputView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(50.0f);
        
    }];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end

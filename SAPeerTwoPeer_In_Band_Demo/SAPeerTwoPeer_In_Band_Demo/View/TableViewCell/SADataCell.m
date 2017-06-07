//
//  SADataCell.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SADataCell.h"

@implementation SADataCell

#pragma mark -- Initialization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
    }
    return self;
}

#pragma mark --
- (void)initializationDataCell
{
    
}

#pragma mark -- 
- (void)setDataModel:(SADataModel *)dataModel
{
    if (_dataModel != dataModel)
    {
        _dataModel = dataModel;
    }
    
    [self setupCell];
}

- (void)setupCell
{
    
}

@end

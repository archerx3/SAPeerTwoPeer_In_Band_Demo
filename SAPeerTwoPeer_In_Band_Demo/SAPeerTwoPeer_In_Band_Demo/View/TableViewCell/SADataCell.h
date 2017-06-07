//
//  SADataCell.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SADataModel.h"

static NSString * const SADataCellIdentifier = @"SADataCellIdentifier";

@interface SADataCell : UITableViewCell

@property (nonatomic, strong) SADataModel * dataModel;

- (void)setupCell;

@end

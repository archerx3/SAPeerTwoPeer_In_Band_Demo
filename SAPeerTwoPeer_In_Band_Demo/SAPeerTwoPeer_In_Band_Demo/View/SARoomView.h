//
//  SARoomView.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAInputView.h"
#import "SATableView.h"

@interface SARoomView : UIView

@property (nonatomic, strong) UILabel * roomLabel;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) SATableView * tableView;
@property (nonatomic, strong) SAInputView * inputView;

@end

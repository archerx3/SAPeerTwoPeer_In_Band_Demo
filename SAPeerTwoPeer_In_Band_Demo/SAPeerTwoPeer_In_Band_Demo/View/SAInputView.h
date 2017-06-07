//
//  SAInputView.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/24/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAInputView : UIView

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

+ (instancetype)inputView;

@end

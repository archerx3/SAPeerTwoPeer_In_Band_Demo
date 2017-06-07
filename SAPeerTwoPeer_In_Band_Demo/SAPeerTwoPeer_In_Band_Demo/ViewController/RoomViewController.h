//
//  RoomViewController.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SABaseViewController.h"
#import "SARoomView.h"

@interface RoomViewController : SABaseViewController

@property (nonatomic, strong) SARoomView * roomView;
@property (nonatomic, strong, readonly) NSString * roomNumber;

- (instancetype)initWithRoomNumber:(NSString *)roomNumber;

@end

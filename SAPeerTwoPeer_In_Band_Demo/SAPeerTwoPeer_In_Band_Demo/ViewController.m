//
//  ViewController.m
//  SAPeerTwoPeer_In_Band_Demo
//
//  Created by archer.chen on 6/7/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "ViewController.h"
#import "RoomViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *clearCacheButton;

@property (weak, nonatomic) IBOutlet UILabel *RoomNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *joinRoomButton;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.textField.text = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)createRoomButtonAction:(UIButton *)sender
{
    [self jumpToRoomViewController];
}

- (IBAction)joinRoomButtonAction:(UIButton *)sender
{
    [self jumpToRoomViewController];
}

- (IBAction)clearCacheButtonAction:(UIButton *)sender
{
    
}

#pragma mark -
- (void)jumpToRoomViewController
{
    NSString * roomNumber = self.textField.text;
    RoomViewController * vc = [[RoomViewController alloc] initWithRoomNumber:roomNumber];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end

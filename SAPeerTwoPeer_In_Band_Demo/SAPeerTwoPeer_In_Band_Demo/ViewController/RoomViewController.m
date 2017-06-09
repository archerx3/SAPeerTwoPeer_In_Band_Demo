//
//  RoomViewController.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "RoomViewController.h"

#import "SAPeerClient.h"
#import "SAImagePickerHandler.h"

#import "SADataModel+MediaInfo.h"

#import "SAImageCell.h"
#import "SATextCell.h"
#import "SAVideoCell.h"

typedef NS_ENUM(NSUInteger, SADataType) {
    
    SADataTypeDefault,
    SADataTypeImage,
    SADataTypeText,
    
};

@interface RoomViewController ()<SAPeerClientDelegate, SAImagePickerHandlerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString * mRoomNumber;
    
    SAPeerClient * mPeerClient;
    
    SAImagePickerHandler *mImagePickerHandler;
    
    NSMutableArray <SADataModel *>* mDataSource;
    
    BOOL mNeedRefreshTableView;
    BOOL mShouldLeaveRoom;
}

@property (nonatomic, strong, readwrite) NSString * roomNumber;

@property (nonatomic, assign) BOOL dataChannelDidOpen;

@end

@implementation RoomViewController

@synthesize roomNumber = mRoomNumber;

#pragma mark - initialization
- (instancetype)initWithRoomNumber:(NSString *)roomNumber
{
    if (self = [super init])
    {
        mRoomNumber = roomNumber;
        [self initilazationRoomViewController];
    }
    return self;
}

- (void)initilazationRoomViewController
{
    mNeedRefreshTableView = NO;
    mShouldLeaveRoom = NO;
    mDataSource = [NSMutableArray array];
    [self initializationImagePickerHanlder];
    mPeerClient = [[SAPeerClient alloc] initWithDelegate:self];
}

- (void)loadView
{
    CGRect roomViewFrame;
    
    roomViewFrame.origin = CGPointZero;
    
    roomViewFrame.size = [UIScreen mainScreen].bounds.size;
    
    _roomView = [[SARoomView alloc] initWithFrame:roomViewFrame];
    
    self.view = _roomView;
}

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (mNeedRefreshTableView)
    {
        [self refreshTableView];
    }
    
    if (mShouldLeaveRoom)
    {
        mShouldLeaveRoom = NO;
        [self promptSignalingChannelClosed];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (mRoomNumber.length > 0)
    {
        [self setupRoomLabel];
    }
    
    [self.roomView.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.roomView.inputView.addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.roomView.tableView.delegate = self;
    self.roomView.tableView.dataSource = self;
    
    [self.roomView.tableView registerClass:[SAImageCell class] forCellReuseIdentifier:SAImageCellIdentifier];
    [self.roomView.tableView registerClass:[SATextCell class] forCellReuseIdentifier:SATextCellIdentifier];
    [self.roomView.tableView registerClass:[SAVideoCell class] forCellReuseIdentifier:SAVideoCellIdentifier];
    
}

#pragma mark - 

- (SARoomView *)roomView
{
    return (SARoomView *)self.view;
}

- (void)setRoomNumber:(NSString *)roomNumber
{
    if (mRoomNumber != roomNumber)
    {
        mRoomNumber = roomNumber;
        
        [self setupRoomLabel];
    }
}

- (NSString *)roomNumber
{
    return mRoomNumber;
}

- (void)setDataChannelDidOpen:(BOOL)dataChannelDidOpen
{
    if (_dataChannelDidOpen != dataChannelDidOpen)
    {
        _dataChannelDidOpen = dataChannelDidOpen;
        
        [self updateUIStatus];
    }
}

#pragma mark - Action
- (void)backButtonAction:(UIButton *)sender
{
    [mPeerClient disconnect];
    [self clearUpUI];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addButtonAction:(UIButton *)sender
{
    [self presentViewController:mImagePickerHandler.imagePickerController animated:YES completion:nil];
}

#pragma mark - SAPeerClientDelegate

- (void)peerClient:(SAPeerClient *)client didChangeSignalingChannelState:(SAPeerClientSignalingChannelState)state
{
    switch (state)
    {
        case kSAPeerClientSignalingChannelStateConnected:
            [self connecteRoom];
            break;
        case kSAPeerClientSignalingChannelStateConnecting:
        case kSAPeerClientSignalingChannelStateDisconnected:
        {
            NSLog(@"Connection is over!");
            [self leaveRoom];
        }
            break;
        default:
            break;
    }
}

- (void)peerClient:(SAPeerClient *)client didCreateRoom:(NSString *)roomNumber
{
    if (roomNumber)
    {
        self.roomNumber = roomNumber;
    }
}

- (void)peerClient:(SAPeerClient *)client didChangeDataChannelState:(SAPeerClientDataChannelState)state
{
    switch (state)
    {
        case kSAPeerClientDataChannelStateConnected:
        {
            // Data channel is opened
            NSLog(@"Data channel is opened!");
            self.dataChannelDidOpen = YES;
            [self promptDataChannelOpened];
        }
            break;
        case kSAPeerClientDataChannelStateConnecting:
        {
            NSLog(@"Data channel is connectioning!");
        }
            break;
        case kSAPeerClientDataChannelStateDisconnected:
        {
            //
            NSLog(@"Data channel is closed!");
            self.dataChannelDidOpen = NO;
            [self disconnectPeerClient];
        }
            break;
        default:
            break;
    }
}

- (void)peerClient:(SAPeerClient *)client didSendProgress:(CGFloat)prgress
{
    
}

- (void)peerClient:(SAPeerClient *)client didReceiveProgress:(CGFloat)progress
{
    
}

- (void)peerClient:(SAPeerClient *)client didReceiveDataWith:(SADataModel *)data
{
    [self addDataModelsToDataSource:@[data]];
}

- (void)peerClient:(SAPeerClient *)client didError:(NSError *)error
{
    NSLog(@"Some error happened!\n%@", error.localizedDescription);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SAImagePickerHandlerDelegate
- (void)imagePickerHandler:(SAImagePickerHandler *)handler didFinishPickingMediaInfos:(NSArray<NSDictionary *>*)mediaInfos
{
    NSArray * dataModels = [SADataModel dataModelWithMediaInfos:mediaInfos];
    
    [self sendDataModel:dataModels.firstObject];
}

- (void)imagePickerHandlerDidCancel:(SAImagePickerHandler *)handler
{
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SADataModel * dataModel = mDataSource[indexPath.row];
    SADataCell * cell = nil;
    
    if (dataModel.dataType == SADataModelTypeText)
    {
        cell = [self.roomView.tableView dequeueReusableCellWithIdentifier:SATextCellIdentifier forIndexPath:indexPath];
        
        if (!cell)
        {
            cell = [[SATextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SATextCellIdentifier];
        }
    }
    else if (dataModel.dataType == SADataModelTypeImage)
    {
        cell = [self.roomView.tableView dequeueReusableCellWithIdentifier:SAImageCellIdentifier forIndexPath:indexPath];
        
        if (!cell)
        {
            cell = [[SAImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SAImageCellIdentifier];
        }
    }
    else if (dataModel.dataType == SADataModelTypeVideo)
    {
        cell = [self.roomView.tableView dequeueReusableCellWithIdentifier:SAVideoCellIdentifier forIndexPath:indexPath];
        
        if (!cell)
        {
            cell = [[SAImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SAVideoCellIdentifier];
        }
    }
    
    cell.dataModel = dataModel;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SADataModel * dataModel = mDataSource[indexPath.row];
    
    return dataModel.estimatedHeight;
}

#pragma mark - Private
- (void)connecteRoom
{
    [mPeerClient connectToRoomWithId:mRoomNumber];
}

- (void)disconnectPeerClient
{
    [mPeerClient disconnect];
}

- (void)leaveRoom
{
    if (self.isAppeared)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        });
    }
    else
    {
        NSLog(@"Should leave room!");
        mShouldLeaveRoom = YES;
    }
}

- (void)promptDataChannelOpened
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Prompt" message:@"Data channel is opened" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:alertAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isAppeared)
        {
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    });
}

- (void)promptSignalingChannelClosed
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Prompt" message:@"Signaling channel is closed" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
                                                             [self leaveRoom];
        
                                                         }];
    
    [alertController addAction:alertAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isAppeared)
        {
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    });
}

- (void)setupRoomLabel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.roomView.roomLabel.text = mRoomNumber;
        
    });
}

- (void)clearUpUI
{
    self.roomView.roomLabel.text = @"";
}

- (void)initializationImagePickerHanlder
{
    mImagePickerHandler = [[SAImagePickerHandler alloc] init];
    mImagePickerHandler.delegate = self;
}

- (void)updateUIStatus
{
    if (_dataChannelDidOpen)
    {
        self.roomView.inputView.addButton.enabled = YES;
    }
    else
    {
        self.roomView.inputView.addButton.enabled = YES;
    }
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.roomView.tableView reloadData];
        
    });
}

- (void)addDataModelsToDataSource:(NSArray <SADataModel *>*)dataModels
{
    [mDataSource addObjectsFromArray:dataModels];
    
    if (self.isAppeared)
    {
        [self refreshTableView];
    }
    else
    {
        mNeedRefreshTableView = YES;
    }
}

- (void)sendDataModel:(SADataModel *)dataModel
{
    [self addDataModelsToDataSource:@[dataModel]];
    [mPeerClient sendData:dataModel];
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - temp
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end

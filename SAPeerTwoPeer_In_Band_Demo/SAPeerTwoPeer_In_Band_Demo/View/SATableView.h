//
//  SATableView.h
//  StoAmigo
//
//  Created by simon.zeng on 2/26/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * @brief: This subclass is an extended for iOS5 campitible of cell reuse
 *
 *
 */
@interface SATableView : UITableView

@property (nonatomic, assign) BOOL isScrolling; // KVO-compatable, need to Update this in delegate callback

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (id)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier;

@end

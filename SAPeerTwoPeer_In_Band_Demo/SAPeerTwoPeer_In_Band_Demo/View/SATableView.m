//
//  SATableView.m
//  StoAmigo
//
//  Created by simon.zeng on 2/26/14.
//  Copyright (c) 2014 StoAmigo. All rights reserved.
//

#import "SATableView.h"
#import "THBinder.h"

@interface SATableView ()

@property (nonatomic, assign) BOOL patchNeeded;

@property (nonatomic, strong) NSMutableDictionary * cellClassDict;
@property (nonatomic, strong) NSMutableDictionary * headerFooterClassDict;

@end

@implementation SATableView

- (id)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    if (NSOrderedAscending == [[UIDevice currentDevice].systemVersion compare:@"6.0" options:NSNumericSearch]) {
        _patchNeeded = YES;
    }
    
    if (_patchNeeded) {
        _cellClassDict = [[NSMutableDictionary alloc] init];
        _headerFooterClassDict = [[NSMutableDictionary alloc] init];
    }
    
    if ([self respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        [self setCellLayoutMarginsFollowReadableWidth:NO];
    }

}

- (void)dealloc
{
    _cellClassDict = nil;
    _headerFooterClassDict = nil;
}

- (void)setIsScrolling:(BOOL)isScrolling
{
    if (_isScrolling != isScrolling)
    {
        [self willChangeValueForKey:@"isScrolling"];
        _isScrolling = isScrolling;
        [self didChangeValueForKey:@"isScrolling"];
    }
}

#pragma mark - Extended methods

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    if (!_patchNeeded) {
        return [super registerClass:cellClass forCellReuseIdentifier:identifier];
    }
    else{
        // TODO: for iOS5
        NSParameterAssert(cellClass);
        NSParameterAssert(identifier);
        _cellClassDict[identifier] = cellClass;
    }
}

- (void)registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier
{
    if (!_patchNeeded) {
        return [super registerClass:aClass forHeaderFooterViewReuseIdentifier:identifier];
    }
    else{
        // TODO: for iOS5
        NSParameterAssert(aClass);
        NSParameterAssert(identifier);
        _cellClassDict[identifier] = aClass;
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    if (!_patchNeeded) {
        return [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    }
    else{
        // de-queue cell (if available)
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            if (_cellClassDict[identifier]) {
                Class cellClass = _cellClassDict[identifier];
                // compatibility layer
                cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:identifier];

            }
            else
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:identifier];
            }
        }
        
        return cell;
    }
}

- (id)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier
{
    if (!_patchNeeded) {
        return [super dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    }
    else{
        // TODO: for iOS5
        return nil;
    }
}

@end

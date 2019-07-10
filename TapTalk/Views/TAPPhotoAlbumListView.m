//
//  TAPPhotoAlbumListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPhotoAlbumListView.h"

@interface TAPPhotoAlbumListView ()

@property (strong, nonatomic) UIView *selectedItemView;
@property (strong, nonatomic) UILabel *selectedItemLabel;

@end

@implementation TAPPhotoAlbumListView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        if (IS_IPHONE_X_FAMILY) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding] + 30.0f, 0.0f);
        }
        else {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding], 0.0f);
        }
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (IS_IOS_11_OR_ABOVE) {
            [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        [self addSubview:self.tableView];
    
        self.tableView.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

#pragma mark - Custom Method


@end

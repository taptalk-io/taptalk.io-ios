//
//  TAPBlockedListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBlockedListView.h"

@interface TAPBlockedListView()

@property (strong, nonatomic) UIView *bgView;

@end

@implementation TAPBlockedListView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        _tableView = [[TAPBaseTableView alloc] initWithFrame:self.bgView.frame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.bgView addSubview:self.tableView];
        
        _emptyStateView = [[UIView alloc] initWithFrame:self.bgView.frame];
        CGFloat emptyImageWidth = 132.0f;
        CGFloat emptyImageHeight = 200.0f;
        
        CGFloat emptyImageHeightCenter = (CGRectGetHeight(self.bgView.frame) - emptyImageHeight) / 2;
        
        UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.emptyStateView.frame) - emptyImageWidth) / 2, emptyImageHeightCenter - 90.0f, emptyImageWidth, emptyImageHeight)];
        emptyImageView.image = [UIImage imageNamed:@"TAPEmptyBlocked" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.emptyStateView addSubview:emptyImageView];
        
        UILabel *emptyStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(emptyImageView.frame) + 24.0f, CGRectGetWidth(self.emptyStateView.frame), 24.0f)];
        emptyStateLabel.text = @"You don’t have any blocked contact";
        emptyStateLabel.textAlignment = NSTextAlignmentCenter;
        [self.emptyStateView addSubview:emptyStateLabel];
        
        
        [self.bgView addSubview:self.emptyStateView];
    }
    
    return self;
}

#pragma mark - Custom Method

@end

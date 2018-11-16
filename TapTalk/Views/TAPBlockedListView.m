//
//  TAPBlockedListView.m
//  TapTalk
//
//  Created by Welly Kencana on 14/9/18.
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
    
    if(self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        _tableView = [[UITableView alloc] initWithFrame:self.bgView.frame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.bgView addSubview:self.tableView];
    }
    
    return self;
}

#pragma mark - Custom Method

@end

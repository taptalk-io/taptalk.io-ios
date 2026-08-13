//
//  TAPBlockedListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPBaseTableView.h"

@interface TAPBlockedListView : TAPBaseView

@property (strong, nonatomic) TAPBaseTableView *tableView;
@property (strong, nonatomic) UIView *emptyStateView;

@end

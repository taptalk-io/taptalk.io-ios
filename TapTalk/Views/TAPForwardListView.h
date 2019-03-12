//
//  TAPForwardListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 26/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPSearchBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPForwardListView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) UITableView *recentChatTableView;
@property (strong, nonatomic) UITableView *searchResultTableView;

- (void)isShowEmptyState:(BOOL)isShow;
- (void)isShowRecentChatView:(BOOL)isShow animated:(BOOL)isAnimated;

@end

NS_ASSUME_NONNULL_END

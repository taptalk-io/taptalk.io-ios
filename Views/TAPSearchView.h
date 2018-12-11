//
//  TAPSearchView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPSearchView : TAPBaseView

@property (strong, nonatomic) UITableView *recentSearchTableView;
@property (strong, nonatomic) UITableView *searchResultTableView;
@property (strong, nonatomic) UIButton *clearHistoryButton;

- (void)isShowEmptyState:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END

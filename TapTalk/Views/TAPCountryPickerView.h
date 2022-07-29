//
//  TAPCountryPickerView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCountryPickerView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
@property (strong, nonatomic) UIButton *searchBarCancelButton;
@property (strong, nonatomic) TAPBaseTableView *tableView;
@property (strong, nonatomic) TAPBaseTableView *searchResultTableView;

- (void)isShowEmptyState:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END

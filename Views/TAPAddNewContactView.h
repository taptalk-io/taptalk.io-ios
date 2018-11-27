//
//  TAPAddNewContactView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPAddNewContactView : TAPBaseView

typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypeAdd = 0,
    ButtonTypeChat = 1,
};

typedef NS_ENUM(NSInteger, LayoutType) {
    LayoutTypeDefault = 0,
    LayoutTypeUser = 1,
    LayoutTypeExpert = 2,
};

@property (strong, nonatomic) UIButton *addExpertToContactButton;
@property (strong, nonatomic) UIButton *addUserToContactButton;
@property (strong, nonatomic) UIButton *userChatNowButton;
@property (strong, nonatomic) UIButton *expertChatNowButton;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
//@property (strong, nonatomic) UITextField *searchBarTextField;

- (void)isShowDefaultLabel:(BOOL)isShow;
- (void)isShowExpertVerifiedLogo:(BOOL)isShow;
- (void)setSearchViewLayoutWithType:(LayoutType)type;
- (void)setSearchExpertButtonWithType:(ButtonType)type;
- (void)setSearchUserButtonWithType:(ButtonType)type;
- (void)isShowEmptyState:(BOOL)isShow;
- (void)showNoInternetView:(BOOL)isShowed;

- (void)setContactWithUser:(TAPUserModel *)user;
- (void)showLoading:(BOOL)isLoading;

@end

NS_ASSUME_NONNULL_END

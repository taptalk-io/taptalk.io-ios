//
//  TAPCreateGroupView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomButtonView.h"

typedef NS_ENUM(NSInteger, TAPCreateGroupViewType) {
    TAPCreateGroupViewTypeDefault = 0,
    TAPCreateGroupViewTypeAddMember = 1,
    TAPCreateGroupViewTypeMemberList = 2
};

typedef NS_ENUM(NSInteger, TAPCreateGroupLoadingType) {
    TAPCreateGroupLoadingTypeAppointAdmin,
    TAPCreateGroupLoadingTypeRemoveAdmin,
    TAPCreateGroupLoadingTypeRemoveMember,
    TAPCreateGroupLoadingTypeDoneLoading,
};

typedef NS_ENUM(NSInteger, TAPCreateGroupActionExtensionType) {
    TAPCreateGroupActionExtensionTypePromoteAdmin = 0,
    TAPCreateGroupActionExtensionTypeDemoteAdmin = 1,
};

@interface TAPCreateGroupView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
//@property (strong, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) UIButton *searchBarCancelButton;
@property (strong, nonatomic) UITableView *contactsTableView;
@property (strong, nonatomic) UITableView *searchResultTableView;

@property (strong, nonatomic) UIView *selectedContactsView;
@property (strong, nonatomic) UIView *selectedContactsShadowView;
@property (strong, nonatomic) UILabel *selectedContactsTitleLabel;
@property (strong, nonatomic) UICollectionView *selectedContactsCollectionView;
//@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) TAPCustomButtonView *continueButtonView;
@property (strong, nonatomic) TAPCustomButtonView *addMembersButtonView;
@property (strong, nonatomic) TAPCustomButtonView *removeMembersButtonView;
@property (strong, nonatomic) TAPCustomButtonView *promoteAdminButtonView;
@property (strong, nonatomic) TAPCustomButtonView *demoteAdminButtonView;

@property (strong, nonatomic) UIView *loadingBackgroundView;

@property (nonatomic) TAPCreateGroupViewType tapCreateGroupViewType;

- (void)searchBarCancelButtonDidTapped;
- (void)showSelectedContacts:(BOOL)isVisible;
- (void)showOverlayView:(BOOL)isVisible;

- (void)showAddMembersButton;
- (void)showRemoveMembersButton;
- (void)showBottomActionButtonView:(BOOL)isVisible;
- (void)showBottomActionButtonViewExtension:(BOOL)isVisible withActiveButton:(TAPCreateGroupActionExtensionType)type;

- (void)showLoadingView:(BOOL)isShow;
- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPCreateGroupLoadingType)type;

- (void)showLoadingMembersView:(BOOL)isShow;

@end

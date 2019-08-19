//
//  TAPProfileView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPProfileLoadingType) {
    TAPProfileLoadingTypeAppointAdmin,
    TAPProfileLoadingTypeRemoveAdmin,
    TAPProfileLoadingTypeRemoveMember,
    TAPProfileLoadingTypeAddToContact,
    TAPProfileLoadingTypeLeaveGroup,
    TAPProfileLoadingTypeDeleteGroup,
    TAPProfileLoadingTypeDoneLoading,
};

@interface TAPProfileView : TAPBaseView

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *navigationNameLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *navigationBackButton;
@property (strong, nonatomic) UIButton *navigationEditButton;

@property (nonatomic) CGFloat nameLabelHeight;
@property (nonatomic) CGFloat nameLabelBottomPadding;
@property (nonatomic) CGFloat nameLabelYPosition;
@property (nonatomic) CGFloat navigationNameLabelHeight;
@property (nonatomic) CGFloat navigationNameLabelBottomPadding;
@property (nonatomic) CGFloat navigationNameLabelYPosition;
@property (nonatomic) CGFloat navigationBarHeight;

- (void)showLoadingView:(BOOL)isShow;
- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPProfileLoadingType)type;

@end

NS_ASSUME_NONNULL_END

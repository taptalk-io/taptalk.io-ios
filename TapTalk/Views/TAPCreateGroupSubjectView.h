//
//  TAPCreateGroupSubjectView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomTextFieldView.h"
#import "TAPCustomButtonView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPCreateGroupSubjectViewType) {
    TAPCreateGroupSubjectViewTypeDefault = 0,
    TAPCreateGroupSubjectViewTypeUpdate = 1
};

@interface TAPCreateGroupSubjectView : TAPBaseView
@property (strong, nonatomic) UIView *selectedContactsView;

@property (strong, nonatomic) UIView *additionalWhiteBounceView;

@property (strong, nonatomic) UILabel *selectedContactsTitleLabel;
@property (strong, nonatomic) UICollectionView *selectedContactsCollectionView;

@property (strong, nonatomic) UIScrollView *bgScrollView;
@property (strong, nonatomic) UIButton *groupPictureButton;

@property (strong, nonatomic) TAPCustomButtonView *createButtonView;

@property (strong, nonatomic) UIView *removePictureView;
@property (strong, nonatomic) UIButton *removePictureButton;
@property (strong, nonatomic) UIButton *changePictureButton;

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *navigationSeparatorView;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) TAPCustomTextFieldView *groupNameTextField;

@property (nonatomic) TAPCreateGroupSubjectViewType tapCreateGroupSubjectType;

@property (strong, nonatomic) TAPImageView *groupPictureImageView;

- (void)setGroupPictureImageViewWithImage:(UIImage *)image;
- (void)setGroupPictureWithImageURL:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END

//
//  TAPMyAccountView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomTextFieldView.h"
#import "TAPCustomButtonView.h"
#import "TAPImageView.h"
#import "TAPCustomLabelView.h"
#import "TAPCustomGrowingTextView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMyAccountLoadingType) {
    TAPMyAccountLoadingTypeSetProfilPicture,
    TAPMyAccountLoadingTypeUpadating,
    TAPMyAccountLoadingTypeSaveImage,
};

@interface TAPMyAccountView : TAPBaseView

@property (strong, nonatomic) UIView *navigationHeaderView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIImageView *cancelImageView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UILabel *navigationHeaderLabel;
@property (strong, nonatomic) UIView *navigationSeparatorView;
@property (strong, nonatomic) UIView *additionalWhiteBounceView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TAPCustomTextFieldView *fullNameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *usernameTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *mobileNumberTextField;
@property (strong, nonatomic) TAPCustomTextFieldView *emailTextField;
@property (strong, nonatomic) UIView *logoutView;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) TAPCustomButtonView *continueButtonView;
@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIButton *removeProfilePictureButton;
@property (strong, nonatomic) UIButton *changeProfilePictureButton;
@property (strong, nonatomic) TAPCustomGrowingTextView *bioTextView;

@property (strong, nonatomic) TAPCustomLabelView *bioLabelField;
@property (strong, nonatomic) TAPCustomLabelView *usernameLabelField;
@property (strong, nonatomic) TAPCustomLabelView *mobileNumberLabelField;
@property (strong, nonatomic) TAPCustomLabelView *emailLabelField;

@property (strong, nonatomic) UILabel *bioWordCounterLabel;

@property (strong, nonatomic) UICollectionView *profilImageCollectionView;
@property (strong, nonatomic) UICollectionView *pageIndicatorCollectionView;

@property (strong, nonatomic) UIView *editViewContainer;

- (void)refreshViewPosition;
- (void)setContinueButtonEnabled:(BOOL)enable;
- (void)setContentEditable:(BOOL)editable;
- (void)setAsLoading:(BOOL)loading;
- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showLogoutLoadingView:(BOOL)isShow;
- (void)animateLogoutLoading:(BOOL)isAnimate;
//DV Note
//UserFullName used to show initials when image is null or not found
//END DV Note
- (void)setProfilePictureWithImage:(UIImage *)image userFullName:(NSString *)userFullName;
- (void)setProfilePictureWithImageURL:(NSString *)imageURL userFullName:(NSString *)userFullName;
- (void)showAccountDetailView;
- (void)showEditAccountView;
- (void)updateGrowingTextViewPosition:(CGFloat)textViewHeight;
- (void)showMultipleProfilePicture;
- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPMyAccountLoadingType)type;
- (void)showLoadingView:(BOOL)isShow;
- (void)setCurrentWordCountWithCurrentCharCount:(NSInteger)charCount;
- (void)setEditPorfilPictureButtonVisible:(BOOL) isVisible;


@end

NS_ASSUME_NONNULL_END

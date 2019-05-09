//
//  TAPImagePreviewView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomGrowingTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPImagePreviewView : TAPBaseView

@property (strong, nonatomic) UICollectionView *imagePreviewCollectionView;
@property (strong, nonatomic) UICollectionView *thumbnailCollectionView;
@property (strong, nonatomic) TAPCustomGrowingTextView *captionTextView;

@property (strong, nonatomic) UIView *captionView;
@property (strong, nonatomic) UIView *captionSeparatorView;
@property (strong, nonatomic) UILabel *wordCountLabel;
@property (strong, nonatomic) UIView *bottomMenuView;
@property (strong, nonatomic) UIView *alertContainerView;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *morePictureButton;
@property (strong, nonatomic) UIButton *sendButton;

- (void)setItemNumberWithCurrentNumber:(NSInteger)current ofTotalNumber:(NSInteger)total;
- (void)setCurrentWordCountWithCurrentCharCount:(NSInteger)charCount;
- (void)isShowCounterCharCount:(BOOL)isShow;
- (void)isShowAsSingleImagePreview:(BOOL)isShow animated:(BOOL)animated;
- (void)showExcedeedFileSizeAlertView:(BOOL)isShow animated:(BOOL)animated;
- (void)enableSendButton:(BOOL)isEnable;

@end

NS_ASSUME_NONNULL_END

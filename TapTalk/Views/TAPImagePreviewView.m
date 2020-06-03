//
//  TAPImagePreviewView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewView.h"

@interface TAPImagePreviewView ()

@property (strong, nonatomic) UIView *contentBackgroundView;
@property (strong, nonatomic) UIView *thumbnailBackgroundGradientView;
@property (strong, nonatomic) UIView *topMenuView;
@property (strong, nonatomic) UILabel *numberOfImageInfoLabel;
@property (strong, nonatomic) UIImageView *morePictureImageView;

@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UILabel *alertTitleLabel;
@property (strong, nonatomic) UILabel *alertDetailLabel;
@property (strong, nonatomic) UIImageView *alertImageView;

@end

@implementation TAPImagePreviewView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _contentBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.contentBackgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.contentBackgroundView];
        
        CGFloat topMenuYPosition = 0.0f;
        CGFloat topMenuViewHeight = 44.0f;
        CGFloat bottomMenuViewHeight = 48.0f;
        CGFloat bottomMenuYPosition = CGRectGetHeight(self.frame) - bottomMenuViewHeight;
        CGFloat imagePreviewCollectionViewHeight = CGRectGetHeight(self.frame) - topMenuViewHeight - bottomMenuViewHeight;
        
        if (IS_IPHONE_X_FAMILY) {
            topMenuYPosition = [TAPUtil safeAreaTopPadding];
            bottomMenuYPosition = bottomMenuYPosition - [TAPUtil safeAreaBottomPadding];
            imagePreviewCollectionViewHeight = imagePreviewCollectionViewHeight - [TAPUtil safeAreaTopPadding] - [TAPUtil safeAreaBottomPadding];
        }
        
        //Top Menu View
        _topMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topMenuYPosition, CGRectGetWidth(self.frame), topMenuViewHeight)];
        self.topMenuView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.topMenuView];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _imagePreviewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), imagePreviewCollectionViewHeight) collectionViewLayout:collectionLayout];
        self.imagePreviewCollectionView.backgroundColor = [UIColor clearColor];
        self.imagePreviewCollectionView.pagingEnabled = YES;
        self.imagePreviewCollectionView.showsVerticalScrollIndicator = NO;
        self.imagePreviewCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.imagePreviewCollectionView];
        
        UIFont *itemCountFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewItemCount];
        UIColor *itemCountColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewItemCount];
        _numberOfImageInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 32.0f - 50.0f, (CGRectGetHeight(self.topMenuView.frame) - 21.0f) / 2.0f, 50.0f, 21.0f)];
        self.numberOfImageInfoLabel.font = itemCountFont;
        self.numberOfImageInfoLabel.textColor = itemCountColor;
        self.numberOfImageInfoLabel.textAlignment = NSTextAlignmentCenter;
        [self.topMenuView addSubview:self.numberOfImageInfoLabel];

        UIFont *cancelButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewCancelButton];
        UIColor *cancelButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewCancelButton];
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.topMenuView.frame) - 21.0f) / 2.0f, 60.0f, 21.0f)];
        [self.cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        self.cancelButton.titleLabel.font = cancelButtonFont;
        [self.cancelButton setTitleColor:cancelButtonColor forState:UIControlStateNormal];
        [self.topMenuView addSubview:self.cancelButton];
        
        _thumbnailBackgroundGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), 56.0f)];
        CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
        backgroundGradientLayer.frame = self.thumbnailBackgroundGradientView.bounds;
        backgroundGradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor, (id)[UIColor clearColor].CGColor];
        [self.thumbnailBackgroundGradientView.layer insertSublayer:backgroundGradientLayer atIndex:0];
        [self addSubview:self.thumbnailBackgroundGradientView];
        
        UICollectionViewFlowLayout *thumbnailCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
        thumbnailCollectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.topMenuView.frame), CGRectGetWidth(self.frame), 58.0f) collectionViewLayout:thumbnailCollectionLayout];
        self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
        self.thumbnailCollectionView.showsVerticalScrollIndicator = NO;
        self.thumbnailCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.thumbnailCollectionView];
        
        //Bottom Menu View
        _bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, bottomMenuYPosition, CGRectGetWidth(self.frame), bottomMenuViewHeight)];
        self.bottomMenuView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.bottomMenuView];
        
        _morePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 24.0f) / 2.0f, 24.0f, 24.0f)];
        self.morePictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.morePictureImageView.image = [UIImage imageNamed:@"TAPIconAddImage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.morePictureImageView.image = [self.morePictureImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconMediaPreviewAdd]];

        [self.bottomMenuView addSubview:self.morePictureImageView];
        
        _morePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.morePictureImageView.frame) - 8.0f, CGRectGetMinY(self.morePictureImageView.frame) - 8.0f, CGRectGetWidth(self.morePictureImageView.frame) + 16.0f, CGRectGetHeight(self.morePictureImageView.frame) + 16.0f)];
        [self.bottomMenuView addSubview:self.morePictureButton];
        
        UIFont *sendButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewSendButtonLabel];
        UIColor *sendButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewSendButtonLabel];
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bottomMenuView.frame) - 40.0f - 16.0f, (CGRectGetHeight(self.bottomMenuView.frame) - 21.0f) / 2.0f, 40.0f, 21.0f)];
        [self.sendButton setTitle:NSLocalizedStringFromTableInBundle(@"Send", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
        self.sendButton.backgroundColor = [UIColor clearColor];
        self.sendButton.titleLabel.font = sendButtonFont;
        [self.sendButton setTitleColor:sendButtonColor forState:UIControlStateNormal];
        self.sendButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.bottomMenuView addSubview:self.sendButton];
        
        //Caption View
        //top gap + textview height + textview bottom gap + separator height + bottom gap
        CGFloat captionViewInitialHeight = 12.0f + 22.0f + 12.0f + 1.0f + 10.0f;
        _captionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - captionViewInitialHeight, CGRectGetWidth(self.frame), captionViewInitialHeight)];
        self.captionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [self addSubview:self.captionView];
        
        UIFont *captionTextViewFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewCaption];
        UIColor *captionTextViewColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewCaption];
        UIColor *captionPlaceholderTextViewColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewCaptionPlaceholder];
        CGFloat wordCountLabelWidth = 50.0f;
        CGFloat captionTextViewWidth = CGRectGetWidth(self.captionView.frame) - 16.0f - 16.0f - 8.0f - wordCountLabelWidth;
        _captionTextView = [[TAPCustomGrowingTextView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, captionTextViewWidth, 22.0f)];
        [self.captionTextView setCharacterCountLimit:TAP_LIMIT_OF_CAPTION_CHARACTER];
        [self.captionTextView setFont:captionTextViewFont];
        [self.captionTextView setTextColor:captionTextViewColor];
        [self.captionTextView setPlaceholderColor:captionPlaceholderTextViewColor];
        self.captionTextView.tintColor = captionTextViewColor;
        [self.captionView addSubview:self.captionTextView];
        
        _captionSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.captionTextView.frame) + 12.0f, CGRectGetWidth(self.frame) - 32.0f, 1.0f)];
        self.captionSeparatorView.backgroundColor = [UIColor whiteColor];
        [self.captionView addSubview:self.captionSeparatorView];
        
        UIFont *captionLetterCountFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewCaptionLetterCount];
        UIColor *captionLetterCountColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewCaptionLetterCount];
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - wordCountLabelWidth - 16.0f, CGRectGetMinY(self.captionSeparatorView.frame) - 15.0f - 13.0f, wordCountLabelWidth, 13.0f)];
        self.wordCountLabel.textAlignment = NSTextAlignmentRight;
        self.wordCountLabel.font = captionLetterCountFont;
        self.wordCountLabel.textColor = captionLetterCountColor;
        [self.captionView addSubview:self.wordCountLabel];
        
        //Alert View
        _alertContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.bottomMenuView.frame) - 92.0f, CGRectGetWidth(self.frame), 92.0f)];
        self.alertContainerView.alpha = 0.0f;
        self.alertContainerView.backgroundColor = [UIColor clearColor];
        self.alertContainerView.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.alertContainerView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.4f].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.alertContainerView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.alertContainerView];
        
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 20.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0f, 62.0f)];
        self.alertView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorMediaPreviewWarningBackgroundColor];
        self.alertView.layer.borderWidth = 1.0f;
        self.alertView.layer.borderColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError].CGColor;
        self.alertView.layer.cornerRadius = 8.0f;
        [self.alertContainerView addSubview:self.alertView];
        
        _alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0f, 14.0f, 16.0f, 16.0f)];
        self.alertImageView.image = [UIImage imageNamed:@"TAPIconWarning" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.alertImageView.image = [self.alertImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconMediaPreviewWarning]];
        self.alertImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.alertImageView.clipsToBounds = YES;
        self.alertImageView.layer.cornerRadius = CGRectGetHeight(self.alertImageView.frame) / 2.0f;
        [self.alertView addSubview:self.alertImageView];
        
        TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
        NSNumber *maxFileSize = coreConfigs.chatMediaMaxFileSize;
        NSInteger maxFileSizeInMB = [maxFileSize integerValue] / 1024 / 1024; //Convert to MB
        
        UIFont *imagePreviewAlertTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewWarningTitle];
        UIColor *imagePreviewAlertTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewWarningTitle];
        _alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.alertImageView.frame) + 6.0f, 12.0f, CGRectGetWidth(self.alertView.frame) - CGRectGetWidth(self.alertImageView.frame) - 6.0f - 10.0f - 10.0f, 20.0f)];
        self.alertTitleLabel.font = imagePreviewAlertTitleFont;
        self.alertTitleLabel.textColor = imagePreviewAlertTitleColor;
        self.alertTitleLabel.text = [NSString stringWithFormat:@"Exceeded %ldMB upload limit", (long)maxFileSizeInMB];
        [self.alertView addSubview:self.alertTitleLabel];

        UIFont *imagePreviewAlertContentFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaPreviewWarningBody];
        UIColor *imagePreviewAlertContentColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaPreviewWarningBody];
        _alertDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.alertTitleLabel.frame), CGRectGetMaxY(self.alertTitleLabel.frame), CGRectGetWidth(self.alertTitleLabel.frame), 16.0f)];
        self.alertDetailLabel.font = imagePreviewAlertContentFont;
        self.alertDetailLabel.textColor = imagePreviewAlertContentColor;
        self.alertDetailLabel.text = NSLocalizedStringFromTableInBundle(@"Please remove this video to continue", nil, [TAPUtil currentBundle], @"");
        [self.alertView addSubview:self.alertDetailLabel];
        
        _mentionTableBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.captionView.frame) - 0.0f, CGRectGetWidth(self.frame), 0.0f)];
        self.mentionTableBackgroundView.alpha = 0.0f;
        self.mentionTableBackgroundView.layer.shadowRadius = 20.0f;
        self.mentionTableBackgroundView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
        self.mentionTableBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.mentionTableBackgroundView.layer.shadowOpacity = 1.0f;
        self.mentionTableBackgroundView.layer.masksToBounds = NO;
        [self addSubview:self.mentionTableBackgroundView];
        
        _mentionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.captionView.frame) - 0.0f, CGRectGetWidth(self.frame), 0.0f)];
        self.mentionTableView.alpha = 0.0f;
        self.mentionTableView.clipsToBounds = YES;
        self.mentionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.mentionTableView];
    }
    
    return self;
}

#pragma mark - Lifecycle
- (void)setItemNumberWithCurrentNumber:(NSInteger)current ofTotalNumber:(NSInteger)total {
    NSString *formattedTotalString = [NSString stringWithFormat:@"%ld of %ld", current, total];
    self.numberOfImageInfoLabel.text = formattedTotalString;
    
    //resize label
    CGSize contentSize = [self.numberOfImageInfoLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.numberOfImageInfoLabel.frame))];
    self.numberOfImageInfoLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 32.0f - contentSize.width, CGRectGetMinY(self.numberOfImageInfoLabel.frame), contentSize.width, CGRectGetHeight(self.numberOfImageInfoLabel.frame));
}

- (void)setCurrentWordCountWithCurrentCharCount:(NSInteger)charCount {
    NSString *wordCountString = [NSString stringWithFormat:@"%ld/100", charCount];
    self.wordCountLabel.text = wordCountString;
}

- (void)isShowCounterCharCount:(BOOL)isShow {
    if (isShow) {
        self.wordCountLabel.alpha = 1.0f;
    }
    else {
        self.wordCountLabel.alpha = 0.0f;
    }
}

- (void)isShowAsSingleImagePreview:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.numberOfImageInfoLabel.alpha = 0.0f;
                self.thumbnailCollectionView.alpha = 0.0f;
                self.thumbnailCollectionView.userInteractionEnabled = NO;
                self.thumbnailBackgroundGradientView.alpha = 0.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.numberOfImageInfoLabel.alpha = 1.0f;
                self.thumbnailCollectionView.alpha = 1.0f;
                self.thumbnailCollectionView.userInteractionEnabled = YES;
                self.thumbnailBackgroundGradientView.alpha = 1.0f;
            }];
        }
    }
    else {
        if (isShow) {
            self.numberOfImageInfoLabel.alpha = 0.0f;
            self.thumbnailCollectionView.alpha = 0.0f;
            self.thumbnailCollectionView.userInteractionEnabled = NO;
            self.thumbnailBackgroundGradientView.alpha = 0.0f;
        }
        else {
            self.numberOfImageInfoLabel.alpha = 1.0f;
            self.thumbnailCollectionView.alpha = 1.0f;
            self.thumbnailCollectionView.userInteractionEnabled = YES;
            self.thumbnailBackgroundGradientView.alpha = 1.0f;
        }
    }
}

- (void)showExcedeedFileSizeAlertView:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertContainerView.alpha = 1.0f;
                self.captionView.alpha = 0.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertContainerView.alpha = 0.0f;
                self.captionView.alpha = 1.0f;
            }];
        }
    }
    else {
        if (isShow) {
            self.alertContainerView.alpha = 1.0f;
            self.captionView.alpha = 0.0f;
        }
        else {
            self.alertContainerView.alpha = 0.0f;
            self.captionView.alpha = 1.0f;
        }
    }
}

- (void)enableSendButton:(BOOL)isEnable {
    if (isEnable) {
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.userInteractionEnabled = YES;
    }
    else {
        [self.sendButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateNormal];
        self.sendButton.userInteractionEnabled = NO;
    }
}

- (void)showMentionTableView:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        if (show) {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionTableBackgroundView.alpha = 1.0f;
                self.mentionTableView.alpha = 1.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionTableBackgroundView.alpha = 0.0f;
                self.mentionTableView.alpha = 0.0f;
            }];
        }
    }
    else {
        if (show) {
            self.mentionTableBackgroundView.alpha = 1.0f;
            self.mentionTableView.alpha = 1.0f;
        }
        else {
            self.mentionTableBackgroundView.alpha = 0.0f;
            self.mentionTableView.alpha = 0.0f;
        }
    }
}

@end

//
//  TAPSetupRoomListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSetupRoomListView.h"

@interface TAPSetupRoomListView ()

@property (strong, nonatomic) UIView *firstLoadOverlayView;
@property (strong, nonatomic) UIView *firstLoadView;
@property (strong, nonatomic) UIImageView *firstLoadImageView;
@property (strong, nonatomic) UIImageView *firstLoadCenterIconImageView;
@property (strong, nonatomic) UIImageView *retryIconImageView;
@property (strong, nonatomic) UILabel *titleFirstLoadLabel;
@property (strong, nonatomic) UILabel *descriptionFirstLoadLabel;
@property (strong, nonatomic) UILabel *retryLabel;
@property (nonatomic) BOOL notShowLoadingFlow;

@end

@implementation TAPSetupRoomListView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _firstLoadOverlayView = [[UIView alloc] initWithFrame:self.frame];
        self.firstLoadOverlayView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        [self addSubview:self.firstLoadOverlayView];
        
        _firstLoadView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.frame) - 220.0f) / 2.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 220.0f)];
        self.firstLoadView.backgroundColor = [UIColor whiteColor];
        self.firstLoadView.layer.cornerRadius = 8.0f;
        self.firstLoadView.clipsToBounds = YES;
        [self.firstLoadOverlayView addSubview:self.firstLoadView];
        
        _firstLoadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.firstLoadView.frame) - 110.0f) / 2.0f, 32.0f, 110.0f, 110.0f)];
        self.firstLoadImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadImageView.image = [self.firstLoadImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        [self.firstLoadView addSubview:self.firstLoadImageView];
        
        _firstLoadCenterIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.firstLoadImageView.frame) + 31.0f, CGRectGetMinY(self.firstLoadImageView.frame) + 31.0f, 48.0f, 48.0f)];
        self.firstLoadCenterIconImageView.image = [UIImage imageNamed:@"TAPIconNewSettingUp" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.firstLoadView addSubview:self.firstLoadCenterIconImageView];
    
        UIFont *popupTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogTitle];
        UIColor *popupTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogTitle];
        _titleFirstLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.firstLoadImageView.frame) + 8.0f, CGRectGetWidth(self.firstLoadView.frame) - 16.0f - 16.0f, 20.0f)];
        self.titleFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Setting up Your Chat Room", nil, [TAPUtil currentBundle], @"");
        self.titleFirstLoadLabel.textColor = popupTitleLabelColor;
        self.titleFirstLoadLabel.font = popupTitleLabelFont;
        NSMutableDictionary *titleFirstLoadAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat titleFirstLoadLetterSpacing = -0.4f;
        [titleFirstLoadAttributesDictionary setObject:@(titleFirstLoadLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *titleFirstLoadAttributedString = [[NSMutableAttributedString alloc] initWithString:self.titleFirstLoadLabel.text];
        [titleFirstLoadAttributedString addAttributes:titleFirstLoadAttributesDictionary
                                                range:NSMakeRange(0, [self.titleFirstLoadLabel.text length])];
        self.titleFirstLoadLabel.attributedText = titleFirstLoadAttributedString;
        self.titleFirstLoadLabel.textAlignment = NSTextAlignmentCenter;
        [self.firstLoadView addSubview:self.titleFirstLoadLabel];
    
        UIFont *popupBodyLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupDialogBody];
        UIColor *popupBodyLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupDialogBody];
        _descriptionFirstLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleFirstLoadLabel.frame), CGRectGetMaxY(self.titleFirstLoadLabel.frame), CGRectGetWidth(self.titleFirstLoadLabel.frame), 18.0f)];
        self.descriptionFirstLoadLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Make sure you have a stable conection", nil, [TAPUtil currentBundle], @"");
        self.descriptionFirstLoadLabel.textColor = popupBodyLabelColor;
        self.descriptionFirstLoadLabel.font = popupBodyLabelFont;
        NSMutableDictionary *descriptionFirstLoadAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat descriptionFirstLoadLetterSpacing = -0.2f;
        [descriptionFirstLoadAttributesDictionary setObject:@(descriptionFirstLoadLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *descriptionFirstLoadAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionFirstLoadLabel.text];
        [descriptionFirstLoadAttributedString addAttributes:descriptionFirstLoadAttributesDictionary
                                                      range:NSMakeRange(0, [self.descriptionFirstLoadLabel.text length])];
        self.descriptionFirstLoadLabel.attributedText = descriptionFirstLoadAttributedString;
        [self.firstLoadView addSubview:self.descriptionFirstLoadLabel];
        
        UIFont *retryLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *retryLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _retryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleFirstLoadLabel.frame), CGRectGetMaxY(self.titleFirstLoadLabel.frame), CGRectGetWidth(self.titleFirstLoadLabel.frame), 18.0f)];
        self.retryLabel.textAlignment = NSTextAlignmentCenter;
        self.retryLabel.text = NSLocalizedStringFromTableInBundle(@"Retry Setup", nil, [TAPUtil currentBundle], @"");
        self.retryLabel.textColor = retryLabelColor;
        self.retryLabel.font = retryLabelFont;
        [self.retryLabel sizeToFit];
        self.retryLabel.frame = CGRectMake((CGRectGetWidth(self.firstLoadView.frame) - CGRectGetWidth(self.retryLabel.frame) - 20.0f) / 2, CGRectGetMinY(self.retryLabel.frame), CGRectGetWidth(self.retryLabel.frame), 18.0f);
        [self.firstLoadView addSubview:self.retryLabel];
        
        _retryIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.retryLabel.frame), CGRectGetMinY(self.retryLabel.frame), 20.0f, 20.0f)];
        self.retryIconImageView.image = [UIImage imageNamed:@"TAPIconRetryCounterClockwise" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.retryIconImageView.image = [self.retryIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListRetrySetUpButton]];
 
        [self.firstLoadView addSubview:self.retryIconImageView];
        
        _retryButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.retryLabel.frame), CGRectGetMinY(self.retryLabel.frame), CGRectGetWidth(self.retryLabel.frame) + CGRectGetWidth(self.retryIconImageView.frame), CGRectGetHeight(self.retryIconImageView.frame))];
        [self.firstLoadView addSubview:self.retryButton];
        
        self.firstLoadOverlayView.alpha = 0.0f;
        self.alpha = 0.0f;
    }
    return self;
}

#pragma mark - Custom Method
- (void)showSetupViewWithType:(TAPSetupRoomListViewType)type {
    if ([[TAPDataManager getAccessToken] isEqualToString:@""] || [TAPDataManager getAccessToken] == nil) {
        // Do not show if user is not logged in
        return;
    }
    
    BOOL isHide = [[TapUI sharedInstance] getSetupLoadingFlowHiddenState];
    if (isHide) {
        //Don't show any loading animation if the boolean is true
        return;
    }
    
    if (type == TAPSetupRoomListViewTypeSettingUp) {
        self.titleFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Setting up Your Chat Room", nil, [TAPUtil currentBundle], @"");
        self.descriptionFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Make sure you have a stable conection", nil, [TAPUtil currentBundle], @"");
        self.firstLoadImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadImageView.image = [self.firstLoadImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        self.firstLoadCenterIconImageView.image = [UIImage imageNamed:@"TAPIconNewSettingUp" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadCenterIconImageView.image = [self.firstLoadCenterIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListSettingUp]];

        self.descriptionFirstLoadLabel.alpha = 1.0f;
        self.retryLabel.alpha = 0.0f;
        self.retryIconImageView.alpha = 0.0f;
        self.retryButton.alpha = 0.0f;
    }
    else if (type == TAPSetupRoomListViewTypeSuccess) {
        self.titleFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Setup successful", nil, [TAPUtil currentBundle], @"");
        self.descriptionFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"You are all set and ready to go!", nil, [TAPUtil currentBundle], @"");
        self.firstLoadImageView.image = [UIImage imageNamed:@"TAPIconLoaderSuccess" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadImageView.image = [self.firstLoadImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListSetUpSuccess]];
        self.firstLoadCenterIconImageView.image = [UIImage imageNamed:@"TAPIconNewSetupSuccess" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadCenterIconImageView.image = [self.firstLoadCenterIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListSetUpSuccess]];
        self.descriptionFirstLoadLabel.alpha = 1.0f;
        self.retryLabel.alpha = 0.0f;
        self.retryIconImageView.alpha = 0.0f;
        self.retryButton.alpha = 1.0f;
    }
    else if (type == TAPSetupRoomListViewTypeFailed) {
        self.titleFirstLoadLabel.text = NSLocalizedStringFromTableInBundle(@"Setup failed", nil, [TAPUtil currentBundle], @"");
        self.descriptionFirstLoadLabel.text = @"";
        self.firstLoadImageView.image = [UIImage imageNamed:@"TAPIconLoaderSuccess" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadImageView.image = [self.firstLoadImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListSetUpFailure]];
        self.firstLoadCenterIconImageView.image = [UIImage imageNamed:@"TAPIconSetupFailed" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.firstLoadCenterIconImageView.image = [self.firstLoadCenterIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListSetUpFailure]];
        self.descriptionFirstLoadLabel.alpha = 0.0f;
        self.retryLabel.alpha = 1.0f;
        self.retryIconImageView.alpha = 1.0f;
        self.retryButton.alpha = 1.0f;
    }
}

- (void)showFirstLoadingView:(BOOL)isVisible withType:(TAPSetupRoomListViewType)type {
    
    BOOL isHide = [[TapUI sharedInstance] getSetupLoadingFlowHiddenState];
    if (isHide) {
        //Don't show any loading animation if the boolean is true
        return;
    }
    
    if (isVisible) {
        self.alpha = 1.0f;
        self.firstLoadOverlayView.alpha = 1.0f;
        
        if (type == TAPSetupRoomListViewTypeSettingUp) {
            //Remove Existing Animation
            if ([self.firstLoadImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.firstLoadImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
            
            //Add Animation
            if ([self.firstLoadImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.removedOnCompletion = NO;
                [self.firstLoadImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
            }
        }
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.firstLoadOverlayView.alpha = 0.0f;
            self.alpha = 0.0f;

            //Remove Animation
            if ([self.firstLoadImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.firstLoadImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }];
    }
}

@end

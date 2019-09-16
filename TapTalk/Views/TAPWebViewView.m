//
//  TAPWebViewView.m
//  TapTalk
//
//  Created by Cundy Sunardy on 28/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPWebViewView.h"

@interface TAPWebViewView()

@property (strong, nonatomic) UIView *statusBarView;
@property (strong, nonatomic) UIView *customNavigationView;
@property (strong, nonatomic) UIView *bottomBarView;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) UIImageView *backImageView;
@property (strong, nonatomic) UIImageView *forwardImageView;
@property (strong, nonatomic) UIImageView *shareImageView;
@property (strong, nonatomic) UIImageView *safariImageView;

@end

@implementation TAPWebViewView
#pragma mark - LifeCycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), [TAPUtil safeAreaTopPadding])];
        self.statusBarView.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
        [self addSubview:self.statusBarView];
        
        _customNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.statusBarView.frame), CGRectGetWidth(self.frame), 44.0f)];
        self.customNavigationView.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
        [self addSubview:self.customNavigationView];
        
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, 0.0f, 50.0f, CGRectGetHeight(self.customNavigationView.frame))];
        [self.doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[TAPUtil getColor:@"007AFF"] forState:UIControlStateNormal];
        [self.customNavigationView addSubview:self.doneButton];
        
        _refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 24.0f - 13.0f, (CGRectGetHeight(self.customNavigationView.frame) - 24.0f)/2, 24.0f, 24.0f)];
        self.refreshImageView.image = [UIImage imageNamed:@"TAPIconWebRefresh" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.customNavigationView addSubview:self.refreshImageView];
        
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.refreshImageView.frame) - ((40.0f - CGRectGetWidth(self.refreshImageView.frame))/2), CGRectGetMinY(self.refreshImageView.frame) - ((40.0f - CGRectGetWidth(self.refreshImageView.frame))/2), 40.0f, 40.0f)];
        [self.customNavigationView addSubview:self.refreshButton];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85.0f, 0.0f, CGRectGetWidth(self.frame) - 85.0f - 85.0f, CGRectGetHeight(self.customNavigationView.frame))];
        UIFont *obtainedFont = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
        obtainedFont = [obtainedFont fontWithSize:16.0f];
        self.titleLabel.font = obtainedFont;
        self.titleLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorCustomWebViewNavigationTitleLabel];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.customNavigationView addSubview:self.titleLabel];
        
        UIView *customNavigationSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.customNavigationView.frame) - 1.0f, CGRectGetWidth(self.customNavigationView.frame), 1.0f)];
        customNavigationSeparatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];
        [self.customNavigationView addSubview:customNavigationSeparatorView];
        
        _bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 44.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.frame), 44.0f + [TAPUtil safeAreaBottomPadding])];
        self.bottomBarView.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
        [self addSubview:self.bottomBarView];
        
        UIView *bottomBarSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.customNavigationView.frame), 1.0f)];
        bottomBarSeparatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];
        [self.bottomBarView addSubview:bottomBarSeparatorView];
        
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13.0f, 10.0f, 24.0f, 24.0f)];
        self.backImageView.image = [UIImage imageNamed:@"TAPIconWebBackOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomBarView addSubview:self.backImageView];
        
        CGFloat iconSpacing = (CGRectGetWidth(self.frame) - 26.0f - 24.0f*4)/3;
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.backImageView.frame) - ((40.0f - CGRectGetWidth(self.backImageView.frame))/2), CGRectGetMinY(self.backImageView.frame) - ((40.0f - CGRectGetWidth(self.backImageView.frame))/2), 40.0f, 40.0f)];
        [self.bottomBarView addSubview:self.backButton];
        
        _forwardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backImageView.frame) + iconSpacing, 10.0f, 24.0f, 24.0f)];
        self.forwardImageView.image = [UIImage imageNamed:@"TAPIconWebForwardOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomBarView addSubview:self.forwardImageView];
        
        _forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.forwardImageView.frame) - ((40.0f - CGRectGetWidth(self.forwardImageView.frame))/2), CGRectGetMinY(self.forwardImageView.frame) - ((40.0f - CGRectGetWidth(self.forwardImageView.frame))/2), 40.0f, 40.0f)];
        [self.bottomBarView addSubview:self.forwardButton];
        
        _shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.forwardImageView.frame) + iconSpacing, 10.0f, 24.0f, 24.0f)];
        self.shareImageView.image = [UIImage imageNamed:@"TAPIconWebShare" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomBarView addSubview:self.shareImageView];
        
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.shareImageView.frame) - ((40.0f - CGRectGetWidth(self.shareImageView.frame))/2), CGRectGetMinY(self.shareImageView.frame) - ((40.0f - CGRectGetWidth(self.shareImageView.frame))/2), 40.0f, 40.0f)];
        [self.bottomBarView addSubview:self.shareButton];
        
        _safariImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.shareImageView.frame) + iconSpacing, 10.0f, 24.0f, 24.0f)];
        self.safariImageView.image = [UIImage imageNamed:@"TAPIconWebSafari" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bottomBarView addSubview:self.safariImageView];
        
        _safariButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.safariImageView.frame) - ((40.0f - CGRectGetWidth(self.safariImageView.frame))/2), CGRectGetMinY(self.safariImageView.frame) - ((40.0f - CGRectGetWidth(self.safariImageView.frame))/2), 40.0f, 40.0f)];
        [self.bottomBarView addSubview:self.safariButton];
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.customNavigationView.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - (CGRectGetHeight(self.customNavigationView.frame) + CGRectGetHeight(self.statusBarView.frame) + CGRectGetHeight(self.bottomBarView.frame)))];
        [self addSubview:self.webView];
        
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.customNavigationView.frame), 0.0f, 3.0f)];
        self.progressView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        [self addSubview:self.progressView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setProgressViewWithProgress:(CGFloat)progress {
    
    [UIView animateWithDuration:0.2f animations:^{
        self.progressView.frame = CGRectMake(CGRectGetMinX(self.progressView.frame), CGRectGetMinY(self.progressView.frame), CGRectGetWidth(self.frame)*progress, CGRectGetHeight(self.progressView.frame));
        self.progressView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if(progress == 1.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.progressView.alpha = 0.0f;
            }];
        }
    }];
}

- (void)setBackButtonEnabled:(BOOL)enable {
    if (enable) {
        self.backImageView.image = [UIImage imageNamed:@"TAPIconWebBackOn" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.backButton.enabled = YES;
    }
    else {
        self.backImageView.image = [UIImage imageNamed:@"TAPIconWebBackOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.backButton.enabled = NO;
    }
}

- (void)setForwardButtonEnabled:(BOOL)enable {
    if (enable) {
        self.forwardImageView.image = [UIImage imageNamed:@"TAPIconWebForwardOn" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.forwardButton.enabled = YES;
    }
    else {
        self.forwardImageView.image = [UIImage imageNamed:@"TAPIconWebForwardOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.forwardButton.enabled = NO;
    }
}
@end

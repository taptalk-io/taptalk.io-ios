//
//  TAPImageSelectView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageSelectView.h"

@interface TAPImageSelectView ()

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UIView *continueContainerView;

@property (strong, nonatomic) NSMutableArray *imageSequenceArray;

@end

@implementation TAPImageSelectView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        CGFloat additionalSpacing = 0.0f;
        if(IS_IPHONE_X_FAMILY) {
            additionalSpacing = 16.0f;
        }
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 48.0f - additionalSpacing, CGRectGetWidth(self.frame), 48.0f)];
        [self addSubview:self.bottomView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bottomView.frame), 1.0f)];
        separatorView.backgroundColor = [TAPUtil getColor:@"DDDDDD"];
        [self.bottomView addSubview:separatorView];
        
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 50.0f, CGRectGetHeight(self.bottomView.frame) - 1.0f)];
        [self.clearButton setTitle:NSLocalizedString(@"Clear", @"") forState:UIControlStateNormal];
        self.clearButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
        [self.clearButton setTitleColor:[TAPUtil getColor:@"777777"] forState:UIControlStateNormal];
        [self.bottomView addSubview:self.clearButton];
        
        _continueContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bottomView.frame) - 110.0f, 0.0f, 110.0f, CGRectGetHeight(self.bottomView.frame))];
        [self.bottomView addSubview:self.continueContainerView];
        
        _itemNumberView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (CGRectGetHeight(self.continueContainerView.frame) - 22.0f) / 2.0f, 26.0f, 22.0f)];
        self.itemNumberView.backgroundColor = [TAPUtil getColor:@"2DCCAC"];
        self.itemNumberView.layer.cornerRadius = CGRectGetHeight(self.itemNumberView.frame) / 2.0f;
        self.itemNumberView.clipsToBounds = YES;
        [self.continueContainerView addSubview:self.itemNumberView];
        
        _itemNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.0f, 3.0f, CGRectGetWidth(self.itemNumberView.frame) - 6.0f, CGRectGetHeight(self.itemNumberView.frame) - 6.0f)];
        self.itemNumberLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.itemNumberLabel.text = @"0";
        self.itemNumberLabel.textAlignment = NSTextAlignmentCenter;
        self.itemNumberLabel.textColor = [UIColor whiteColor];
        [self.itemNumberView addSubview:self.itemNumberLabel];
        
        _continueButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.itemNumberView.frame)+ 6.0f, 0.0f, 65.0f, CGRectGetHeight(self.continueContainerView.frame))];
        [self.continueButton setTitle:NSLocalizedString(@"Continue", @"") forState:UIControlStateNormal];
        self.continueButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:15.0f];
        [self.continueButton setTitleColor:[TAPUtil getColor:@"2DCCAC"] forState:UIControlStateNormal];
        [self.continueContainerView addSubview:self.continueButton];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.activityIndicatorView.frame = CGRectMake((CGRectGetWidth(self.frame) - CGRectGetWidth(self.activityIndicatorView.frame))/2.0f, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.activityIndicatorView.frame))/2.0f, CGRectGetWidth(self.activityIndicatorView.frame), CGRectGetHeight(self.activityIndicatorView.frame));
        [self.continueContainerView addSubview:self.activityIndicatorView];
        self.activityIndicatorView.center = self.continueButton.center;
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 48.0f - additionalSpacing) collectionViewLayout:collectionLayout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        
        if(IS_IPHONE_X_FAMILY) {
            _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO] - 49.0f - [TAPUtil safeAreaBottomPadding])];
        }
        else {
            _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO] - 49.0f)];
        }
        
        self.loadingView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loadingView];
        
        _loadingIndicator = [[UIActivityIndicatorView alloc] init];
        self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.loadingIndicator.center = CGPointMake(self.frame.size.width / 2.0f, (self.frame.size.height - 64.0f) / 2.0f);
        [self.loadingIndicator startAnimating];
        self.loadingIndicator.alpha = 0.0f;
        [self.loadingView addSubview:self.loadingIndicator];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)startLoadingAnimation {
    self.loadingView.alpha = 1.0f;
}

- (void)endLoadingAnimation {
    self.loadingView.alpha = 0.0f;
}

@end

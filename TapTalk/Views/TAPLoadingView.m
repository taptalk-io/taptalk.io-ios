//
//  TAPLoadingView.m
//  TapTalk
//
//  Created by Cundy Sunardy on 30/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLoadingView.h"

@interface TAPLoadingView ()

@property (strong, nonatomic) UIView *popupWhiteView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *loadingImageView;
- (void)animateLoading:(BOOL)isAnimate;

@end

@implementation TAPLoadingView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        
        _popupWhiteView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 128.0f) / 2.0f, (CGRectGetHeight(self.frame) - 128.0f) / 2.0f, 128.0f, 128.0f)];
        self.popupWhiteView.layer.cornerRadius = 6.0f;
        self.popupWhiteView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.popupWhiteView];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(34.0f, 28.0f, 60.0f, 60.0f)];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaving"];
        [self.popupWhiteView addSubview:self.loadingImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(self.loadingImageView.frame) + 4.0f, CGRectGetWidth(self.popupWhiteView.frame) - 20.0f, 20.0f)];
        self.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_MEDIUM size:14.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93];
        self.titleLabel.text = NSLocalizedString(@"Syncing…", @"");
        [self.popupWhiteView addSubview:self.titleLabel];
        
        [self animateLoading:YES];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)animateLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
    }
    else {
        [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
    }
}

@end

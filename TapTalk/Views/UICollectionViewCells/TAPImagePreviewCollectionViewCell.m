//
//  TAPImagePreviewCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewCollectionViewCell.h"

@interface TAPImagePreviewCollectionViewCell ()

@property (strong, nonatomic) UIImageView *selectedPictureImageView;
@property (strong, nonatomic) UIImageView *playVideoButtonImageView;
@property (strong, nonatomic) UIButton *playVideoButton;
@property (strong, nonatomic) UIView *progressBackgroundView;
@property (strong, nonatomic) UIView *progressBarView;

@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat pathWidth;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) NSInteger updateInterval;

- (void)playVideoButtonDidTapped;

@end

@implementation TAPImagePreviewCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _selectedPictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        self.selectedPictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.selectedPictureImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.selectedPictureImageView];
        
        CGFloat imagePreviewCollectionViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        if (IS_IPHONE_X_FAMILY) {
            imagePreviewCollectionViewHeight = imagePreviewCollectionViewHeight - [TAPUtil safeAreaTopPadding] - [TAPUtil safeAreaBottomPadding];
        }
        
        _playVideoButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 80.0f) / 2.0f, (imagePreviewCollectionViewHeight - 80.0f) / 2.0f, 80.0f, 80.0f)];
        self.playVideoButtonImageView.alpha = 0.0f;
        self.playVideoButtonImageView.layer.cornerRadius = CGRectGetHeight(self.playVideoButtonImageView.frame) / 2.0f;
        self.playVideoButtonImageView.image = [UIImage imageNamed:@"TAPIconButtonPlay" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.contentView addSubview:self.playVideoButtonImageView];
        
        _playVideoButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 90.0f) / 2.0f, (imagePreviewCollectionViewHeight - 90.0f) / 2.0f, 90.0f, 90.0f)];
        self.playVideoButton.alpha = 0.0f;
        self.playVideoButton.userInteractionEnabled = NO;
        [self.playVideoButton addTarget:self action:@selector(playVideoButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playVideoButton];
        
        _progressBackgroundView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 64.0f) / 2.0f, (imagePreviewCollectionViewHeight - 64.0f) / 2.0f, 64.0f, 64.0f)];
        self.progressBackgroundView.alpha = 0.0f;
        self.progressBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.contentView addSubview:self.progressBackgroundView];
        
        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.progressBackgroundView.frame) - 53.0f) / 2.0f, (CGRectGetHeight(self.progressBackgroundView.frame) - 53.0f) / 2.0f, 53.0f, 53.0f)];
        [self.progressBackgroundView addSubview:self.progressBarView];
        
        self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
        self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
        
        _startAngle = M_PI * 1.5;
        _endAngle = self.startAngle + (M_PI * 2);
        _borderWidth = 0.0f;
        _pathWidth = 4.0f;
        _newProgress = 0.0f;
        _updateInterval = 1;
        
        _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
        [self.progressBarView addSubview:self.syncProgressSubView];
        _progressLayer = [CAShapeLayer layer];
        _lastProgress = 0.0f;
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectedPictureImageView.image = nil;
    
    _startAngle = M_PI * 1.5;
    _endAngle = self.startAngle + (M_PI * 2);
    _borderWidth = 0.0f;
    _pathWidth = 4.0f;
    _newProgress = 0.0f;
    _updateInterval = 1;
    
    _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
    [self.progressBarView addSubview:self.syncProgressSubView];
    _progressLayer = [CAShapeLayer layer];
    _lastProgress = 0.0f;
    
    [self showPlayButton:NO animated:NO];
}

#pragma mark - Custom Method
- (void)setImagePreviewImage:(UIImage *)image {
    self.selectedPictureImageView.image = image;
}

- (void)setImagePreviewCollectionViewCellType:(TAPImagePreviewCollectionViewCellType)imagePreviewCollectionViewCellType {
    _imagePreviewCollectionViewCellType = imagePreviewCollectionViewCellType;
    
    if (self.imagePreviewCollectionViewCellType == TAPImagePreviewCollectionViewCellTypeImage) {
        [self showPlayButton:NO animated:NO];
    }
    else if (self.imagePreviewCollectionViewCellType == TAPImagePreviewCollectionViewCellTypeVideo) {
        [self showPlayButton:YES animated:NO];
    }
}

- (void)setImagePreviewCollectionViewCellStateType:(TAPImagePreviewCollectionViewCellStateType)imagePreviewCollectionViewCellStateType {
    _imagePreviewCollectionViewCellStateType = _imagePreviewCollectionViewCellStateType;
    
    // borderWidth is a float representing a value used as a margin (outer border).
    // pathwidth is the width of the progress path (inner).
    _startAngle = M_PI * 1.5;
    _endAngle = self.startAngle + (M_PI * 2);
    _borderWidth = 0.0f;
    _pathWidth = 4.0f;
    
    // progress is a float storing current progress
    // newProgress is a float storing updated progress
    // updateInterval is a float specifying the duration of the animation.
    _newProgress = 0.0f;
    _updateInterval = 1;
    
    if (self.imagePreviewCollectionViewCellStateType == TAPImagePreviewCollectionViewCellStateTypeDefault) {
        [self showProgressView:NO animated:NO];
    }
    else if (self.imagePreviewCollectionViewCellStateType == TAPImagePreviewCollectionViewCellStateTypeDownloading) {
        [self showProgressView:YES animated:NO];
        
//        _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
//        [self.progressBarView addSubview:self.syncProgressSubView];
//        _progressLayer = [CAShapeLayer layer];
//        _lastProgress = 0.0f;
    }
}

- (void)animateProgressMediaWithProgress:(CGFloat)progress total:(CGFloat)total {
    
    [self showPlayButton:NO animated:NO];
    
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;
    
    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));    
    //Circular Progress Bar using CAShapeLayer and UIBezierPath
    _progressLayer = [CAShapeLayer layer];
    [self.progressLayer setFrame:self.progressBarView.bounds];
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height - self.borderWidth - self.pathWidth) / 2 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.strokeColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorFileProgressBackgroundWhite].CGColor;
    self.progressLayer.lineWidth = 3.0f;
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.position = CGPointMake(self.progressBarView.layer.frame.size.width / 2 - self.borderWidth / 2, self.progressBarView.layer.frame.size.height / 2 - self.borderWidth / 2);
    [self.progressLayer setStrokeEnd:0.0f];
    [self.syncProgressSubView.layer addSublayer:self.progressLayer];
    
    [self.progressLayer setStrokeEnd:self.newProgress];
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = self.updateInterval;
    [strokeEndAnimation setFillMode:kCAFillModeForwards];
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.lastProgress];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:self.newProgress];
    _lastProgress = self.newProgress;
    [self.progressLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
}

- (void)animateFinishedDownload {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.progressBackgroundView.alpha = 0.0f;
    }];
}

- (void)showProgressView:(BOOL)show animated:(BOOL)isAnimated {
    if (isAnimated) {
        if (show) {
            [UIView animateWithDuration:0.2f animations:^{
                [self showPlayButton:NO animated:NO];
                self.progressBackgroundView.alpha = 1.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.progressBackgroundView.alpha = 0.0f;
            }];
        }
    }
    else {
        if (show) {
            [self showPlayButton:NO animated:NO];
            self.progressBackgroundView.alpha = 1.0f;
        }
        else {
            self.progressBackgroundView.alpha = 0.0f;
        }
    }
}

- (void)showPlayButton:(BOOL)show animated:(BOOL)isAnimated {
    if (isAnimated) {
        if (show) {
            [UIView animateWithDuration:0.2f animations:^{
                self.playVideoButtonImageView.alpha = 1.0f;
                self.playVideoButton.alpha = 1.0f;
                self.playVideoButton.userInteractionEnabled = YES;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.playVideoButtonImageView.alpha = 0.0f;
                self.playVideoButton.alpha = 0.0f;
                self.playVideoButton.userInteractionEnabled = NO;
            }];
        }
    }
    else {
        if (show) {
            self.playVideoButtonImageView.alpha = 1.0f;
            self.playVideoButton.alpha = 1.0f;
            self.playVideoButton.userInteractionEnabled = YES;
        }
        else {
            self.playVideoButtonImageView.alpha = 0.0f;
            self.playVideoButton.alpha = 0.0f;
            self.playVideoButton.userInteractionEnabled = NO;

        }
    }

}

- (void)playVideoButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(imagePreviewCollectionViewCellDidPlayVideoButtonDidTappedWithMediaPreview:indexPath:)]) {
        [self.delegate imagePreviewCollectionViewCellDidPlayVideoButtonDidTappedWithMediaPreview:self.mediaPreviewData indexPath:self.currentIndexPath];
    }
}

@end

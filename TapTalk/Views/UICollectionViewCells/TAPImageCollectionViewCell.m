//
//  TAPImageCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageCollectionViewCell.h"

@interface TAPImageCollectionViewCell ()

@property (strong, nonatomic) TAPImageView *videoIndicatorImageView;
@property (strong, nonatomic) UILabel *infoLabel;

@property (strong, nonatomic) UIView *downloadButtonView;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIView *progressBarView;
@property (strong, nonatomic) UIView *bottomGradientView;

@property (strong, nonatomic) UIButton *downloadButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat pathWidth;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) NSInteger updateInterval;

- (void)downloadButtonDidTapped;
- (void)cancelButtonDidTapped;
- (void)showDownloadButtonView:(BOOL)show;
- (void)showProgressView:(BOOL)show;

@end

@implementation TAPImageCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _thumbnailImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.thumbnailImageView.clipsToBounds = YES;
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.thumbnailImageView];
        
        _imageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
        
        _bottomGradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(frame)/2, CGRectGetWidth(frame), CGRectGetHeight(frame)/2)];
        self.bottomGradientView.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bottomGradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"04040F"].CGColor, (id)[UIColor clearColor].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 1.0f);
        gradient.endPoint = CGPointMake(0.0f, 0.0f);
        [self.bottomGradientView.layer insertSublayer:gradient atIndex:0];
        [self.contentView addSubview:self.bottomGradientView];
        
        _downloadButtonView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame) - 48.0f)/2, (CGRectGetWidth(frame) - 48.0f)/2, 48.0f, 48.0f)];
        self.downloadButtonView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.downloadButtonView.layer.cornerRadius = CGRectGetWidth(self.downloadButtonView.frame)/2;
        [self.contentView addSubview:self.downloadButtonView];
        
        UIImageView *downloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.downloadButtonView.frame) - 32.0f)/2, (CGRectGetWidth(self.downloadButtonView.frame) - 32.0f) / 2, 32.0f, 32.0f)];
        downloadImageView.image = [UIImage imageNamed:@"TAPIconDownload" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.downloadButtonView addSubview:downloadImageView];
        
        _downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.downloadButtonView.bounds), CGRectGetWidth(self.downloadButtonView.bounds))];
        [self.downloadButtonView addSubview:self.downloadButton];
        
        _progressView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame) - 48.0f)/2, (CGRectGetWidth(frame) - 48.0f)/2, 48.0f, 48.0f)];
        self.progressView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.progressView.layer.cornerRadius = CGRectGetWidth(self.progressView.frame)/2;
        [self.contentView addSubview:self.progressView];
        
        _progressBarView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.progressView.frame) - 40.0f)/2, (CGRectGetWidth(self.progressView.frame) - 40.0f)/2, 40.0f, 40.0f)];
        self.progressBarView.backgroundColor = [UIColor clearColor];
        [self.progressView addSubview:self.progressBarView];
        
        UIImageView *cancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.downloadButtonView.frame) - 32.0f)/2, (CGRectGetWidth(self.downloadButtonView.frame) - 32.0f) / 2, 32.0f, 32.0f)];
        UIImage *abortImage = [UIImage imageNamed:@"TAPIconAbort" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        abortImage = [abortImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconCancelUploadDownloadWhite]];
        cancelImageView.image = abortImage;
        [self.progressView addSubview:cancelImageView];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.progressView.bounds), CGRectGetWidth(self.progressView.bounds))];
        [self.progressView addSubview:self.cancelButton];
        
        _videoIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, CGRectGetHeight(frame) - 14.0f - 5.0f, 14.0f, 14.0f)];
        self.videoIndicatorImageView.image = [UIImage imageNamed:@"TAPIconThumbnailVideo" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.videoIndicatorImageView.image = [self.videoIndicatorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconMediaListVideo]];

        [self.contentView addSubview:self.videoIndicatorImageView];
        
        UIFont *mediaInfoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaListInfoLabel];
        UIColor *mediaInfoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorMediaListInfoLabel];
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.videoIndicatorImageView.frame) + 4.0f, CGRectGetMinY(self.videoIndicatorImageView.frame), CGRectGetWidth(frame) - CGRectGetMaxX(self.videoIndicatorImageView.frame) - 4.0f - 8.0f, 14.0f)];
        self.infoLabel.font = mediaInfoLabelFont;
        self.infoLabel.textColor = mediaInfoLabelColor;
        self.infoLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.infoLabel];
        
        [self.downloadButton addTarget:self action:@selector(downloadButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];

        _startAngle = M_PI * 1.5;
        _endAngle = self.startAngle + (M_PI * 2);
        _borderWidth = 0.0f;
        _pathWidth = 4.0f;
        _newProgress = 0.0f;
        _updateInterval = 1;
        
    }
    
    return self;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [self showDownloadButtonView:NO];
    [self showProgressView:NO];
}

#pragma mark - Custom Method
- (void)setImageCollectionViewCellWithURL:(NSString *)imageURL {
    [self.imageView setImageWithURLString:imageURL];
}

- (void)setImageCollectionViewCellWithMessage:(TAPMessageModel *)message {
    
    _currentMessage = message;
    
    NSString *thumbnailImageString = [message.data objectForKey:@"thumbnail"];
    thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
    
    NSDictionary *dataDictionary = message.data;
    
    if (![thumbnailImageString isEqualToString:@""]) {
      NSData *thumbnailImageData = [[NSData alloc] initWithBase64EncodedString:thumbnailImageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailImageData];
        self.thumbnailImageView.image = thumbnailImage;
    }
    
    if (message.type == TAPChatMessageTypeImage) {
        self.videoIndicatorImageView.alpha = 0.0f;
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        self.videoIndicatorImageView.alpha = 1.0f;
        self.bottomGradientView.alpha = 1.0f;
    }
}

- (void)animateFinishedDownloadingMedia {

    [self animateProgressDownloadingMediaWithProgress:1.0f total:1.0f];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.progressView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.progressLayer removeAllAnimations];
        self.lastProgress = 0.0f;
        self.progressLayer.strokeEnd = 0.0f;
        self.progressLayer.strokeStart = 0.0f;
        
        _progressLayer = nil;
    }];
}

- (void)animateFailedDownloadingMedia {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    _progressLayer = nil;
    [self showProgressView:NO];
    [self showDownloadButtonView:YES];
}

- (void)animateProgressDownloadingMediaWithProgress:(CGFloat)progress total:(CGFloat)total {
    
    [self showDownloadButtonView:NO];
    [self showProgressView:YES];
    
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
    self.progressLayer.position = CGPointMake(self.progressView.layer.frame.size.width / 2 - self.borderWidth / 2, self.progressView.layer.frame.size.height / 2 - self.borderWidth / 2);
    [self.progressLayer setStrokeEnd:0.0f];
    [self.progressView.layer addSublayer:self.progressLayer];

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

- (void)setInfoLabelWithString:(NSString *)infoString {
    self.infoLabel.text = infoString;
}

- (void)setImageCollectionViewCellImageWithImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)downloadButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewCellDidTappedDownloadWithMessage:)]) {
        [self.delegate imageCollectionViewCellDidTappedDownloadWithMessage:self.currentMessage];
    }
}

- (void)cancelButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(imageCollectionViewCellDidTappedCancelWithMessage:)]) {
        [self.delegate imageCollectionViewCellDidTappedCancelWithMessage:self.currentMessage];
    }
}

- (void)setAsDownloaded {
    [self showDownloadButtonView:NO];
    [self showProgressView:NO];
    if (self.currentMessage.type == TAPChatMessageTypeImage) {
        self.bottomGradientView.alpha = 0.0f;
        self.infoLabel.alpha = 0.0f;
    }
}

- (void)showDownloadButtonView:(BOOL)show {
    if (show) {
        self.downloadButtonView.alpha = 1.0f;
    }
    else {
        self.downloadButtonView.alpha = 0.0f;
    }
}

- (void)showProgressView:(BOOL)show {
    if (show) {
        self.progressView.alpha = 1.0f;
    }
    else {
        self.progressView.alpha = 0.0f;
    }
}

- (void)setInitialAnimateDownloadingMedia {
    
    [self showDownloadButtonView:NO];
    self.progressView.alpha = 1.0f;
    
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
    
    // set initial
    _progressLayer = [CAShapeLayer layer];
    _lastProgress = 0.0f;
}

- (void)setAsNotDownloaded {
    [self showProgressView:NO];
    [self showDownloadButtonView:YES];
    self.infoLabel.alpha = 1.0f;
    self.bottomGradientView.alpha = 1.0f;
}

- (void)setThumbnailImageForVideoWithMessage:(TAPMessageModel *)message {
    [TAPImageView imageFromCacheWithMessage:message
    success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        if (savedImage != nil) {
            [self.imageView setImage:savedImage];
            CGFloat width = savedImage.size.width;
            CGFloat height = savedImage.size.height;
        }
    }
    failure:^(NSError *error, TAPMessageModel *receivedMessage) {
        //Get from message.data
        NSDictionary *dataDictionary = message.data;
        NSString *thumbnailImageBase64String = [dataDictionary objectForKey:@"thumbnail"];
        NSData *thumbnailImageData = [[NSData alloc] initWithBase64EncodedString:thumbnailImageBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:thumbnailImageData];
        if (image != nil) {
            self.thumbnailImageView.image = image;
        }
    }];
}

@end

//
//  TAPMyImageBubbleTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMyImageBubbleTableViewCell.h"

@interface TAPMyImageBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;
@property (strong, nonatomic) IBOutlet TAPImageView *thumbnailBubbleImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBubbleRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelBottomConstraint;

@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;

@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat pathWidth;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) NSInteger updateInterval;

- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showImageCaption:(BOOL)show;
- (void)setImageCaptionWithString:(NSString *)captionString;

@end

@implementation TAPMyImageBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _startAngle = M_PI * 1.5;
    _endAngle = self.startAngle + (M_PI * 2);
    _borderWidth = 0.0f;
    _pathWidth = 4.0f;
    _newProgress = 0.0f;
    _updateInterval = 1;
    
    _maxWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0f / 3.0f) - 16.0f; //two third of screen, and 16.0f is right padding.
    _maxHeight = self.maxWidth / 234.0f * 300.0f; //234.0f and 300.0f are width and height constraint on design
    _minWidth = (self.maxWidth / 3.0f); //one third of max Width
    _minHeight = self.minWidth / 78.0f * 100.0f; //78.0f and 100.0f are width and height constraint on design
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    _isDownloaded = NO;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));

    self.progressBackgroundView.alpha = 0.0f;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.thumbnailBubbleImageView.image = nil;
    self.bubbleImageView.image = nil;
    self.progressBackgroundView.alpha = 0.0f;
    self.captionLabel.text = @"";
}

#pragma mark - Custom Method
- (void)setMessage:(TAPMessageModel *)message {
    [super setMessage:message];
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];

    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    UIImage *selectedImage = nil;
    if (fileID == nil || [fileID isEqualToString:@""]) {
        selectedImage = [dataDictionary objectForKey:@"dummyImage"];
        [self getImageSizeFromImage:selectedImage];
        
        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
        [self.bubbleImageView setImage:selectedImage];
    }
    else {        
        //already called fetchImageDataWithMessage function in view controller for fetch image
        //so no need to set the image here
        //just save the height and width constraint
        
        CGFloat obtainedCellWidth = [[message.data objectForKey:@"width"] floatValue];
        CGFloat obtainedCellHeight = [[message.data objectForKey:@"height"] floatValue];
        [self getResizedImageSizeWithHeight:obtainedCellHeight width:obtainedCellWidth];
        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
    
//        [TAPImageView imageFromCacheWithKey:fileID success:^(UIImage *savedImage) {
//            self.bubbleImageView.image = savedImage;
//        }];
    }
    
//    if (!self.isDownloaded) {
//        self.blurView.frame = CGRectMake(CGRectGetMinX(self.blurView.frame), CGRectGetMinY(self.blurView.frame), self.bubbleImageViewWidthConstraint.constant, self.bubbleImageViewHeightConstraint.constant);
//        [self.bubbleImageView insertSubview:self.blurView atIndex:0];
//    }
}

- (void)receiveSentEvent {
    [super receiveSentEvent];
}

- (void)receiveDeliveredEvent {
    [super receiveDeliveredEvent];
}

- (void)receiveReadEvent {
    [super receiveReadEvent];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon {
    [super showStatusLabel:isShowed animated:animated updateStatusIcon:updateStatusIcon];
}

- (IBAction)replyButtonDidTapped:(id)sender {
    [super replyButtonDidTapped:sender];
    
    if ([self.delegate respondsToSelector:@selector(myImageReplyDidTapped)]) {
        [self.delegate myImageReplyDidTapped];
    }
}

- (IBAction)cancelButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myImageCancelDidTappedWithMessage:)]) {
        [self.delegate myImageCancelDidTappedWithMessage:self.message];
    }
}

- (void)getImageSizeFromImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        if (imageWidth > self.maxWidth) {
            imageWidth = self.maxWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / image.size.width) * image.size.height;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
        else if (imageWidth < self.minWidth) {
            imageWidth = self.minWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / image.size.width) * image.size.height;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
    }
    else {
        if (imageHeight > self.maxHeight) {
            imageHeight = self.maxHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / image.size.height) * image.size.width;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
        else if (imageHeight < self.minHeight) {
            imageHeight = self.minHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / image.size.height) * image.size.width;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
    }
}

- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width {
    
    CGFloat previousImageWidth = width;
    CGFloat previousImageHeight = height;
    
    CGFloat imageWidth = width;
    CGFloat imageHeight = height;
    
    if (imageWidth > imageHeight) {
        if (imageWidth > self.maxWidth) {
            imageWidth = self.maxWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
        else if (imageWidth < self.minWidth) {
            imageWidth = self.minWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
    }
    else {
        if (imageHeight > self.maxHeight) {
            imageHeight = self.maxHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
        else if (imageHeight < self.minHeight) {
            imageHeight = self.minHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
    }
}

- (void)animateFinishedUploadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.blurView.alpha = 0.0f;
        self.progressBackgroundView.alpha = 0.0f;
    }];
}

- (void)animateFailedUploadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
}

- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total {
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;

    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
    NSLog(@"PERCENT %@",[NSString stringWithFormat:@"%ld%%", (long)lastPercentage]);

    //Circular Progress Bar using CAShapeLayer and UIBezierPath
    _progressLayer = [CAShapeLayer layer];
    [self.progressLayer setFrame:self.progressBarView.bounds];
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height - self.borderWidth - self.pathWidth) / 2 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];

    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
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

- (void)showProgressUploadView:(BOOL)show {
    if (show) {
        self.progressBackgroundView.alpha = 1.0f;
    }
    else {
        self.progressBackgroundView.alpha = 0.0f;
    }
}

- (void)setInitialAnimateUploadingImageWithCancelButton:(BOOL)withCancelButton {
    
    if (withCancelButton) {
        self.cancelImageView.alpha = 1.0f;
        self.downloadImageView.alpha = 0.0f;
        self.cancelButton.alpha = 1.0f;
        self.cancelButton.userInteractionEnabled = YES;
    }
    else {
        self.downloadImageView.alpha = 1.0f;
        self.cancelImageView.alpha = 0.0f;
        self.cancelButton.alpha = 0.0f;
        self.cancelButton.userInteractionEnabled = NO;
    }
    
    self.progressBackgroundView.alpha = 1.0f;
    
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
    _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
    [self.progressBarView addSubview:self.syncProgressSubView];
    _progressLayer = [CAShapeLayer layer];
    _lastProgress = 0.0f;
    
}

//- (void)animateLoadingWithImageData:(NSData *)imageData roomID:(NSString *)roomID {
//    // borderWidth is a float representing a value used as a margin (outer border).
//    // pathwidth is the width of the progress path (inner).
//    CGFloat startAngle = M_PI * 1.5;
//    CGFloat endAngle = startAngle + (M_PI * 2);
//    CGFloat borderWidth = 0.0f;
//    CGFloat pathWidth = 4.0f;
//
//    // progress is a float storing current progress
//    // newProgress is a float storing updated progress
//    // updateInterval is a float specifying the duration of the animation.
//    CGFloat newProgress = 0.0f;
//    NSInteger updateInterval = 1;
//
//    // set initial
//    _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
//    [self.progressBarView addSubview:self.syncProgressSubView];
//    _progressLayer = [CAShapeLayer layer];
//    self.lastProgress = 0.0f;
//
//    __block CGFloat blockNewProgress = 0.0f;
//
//    //CALL API UPLOAD
//    [TAPDataManager callAPIUploadFileWithFileData:imageData roomID:roomID caption:@"" completionBlock:^{
//        self.lastProgress = 0.0f;
//        self.progressLayer.strokeEnd = 0.0f;
//        self.progressLayer.strokeStart = 0.0f;
//        [self.progressLayer removeAllAnimations];
//        [self.syncProgressSubView removeFromSuperview];
//        _progressLayer = nil;
//        _syncProgressSubView = nil;
//
//        [UIView animateWithDuration:0.2f animations:^{
//            self.blurView.alpha = 0.0f;
//            self.progressBackgroundView.alpha = 0.0f;
//        }];
//    } progressBlock:^(CGFloat progress, CGFloat total) {
//        CGFloat lastProgress = self.lastProgress;
//        blockNewProgress = progress/total;
//
//        NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
//        NSLog(@"PERCENT %@",[NSString stringWithFormat:@"%ld%%", (long)lastPercentage]);
//
//        //Circular Progress Bar using CAShapeLayer and UIBezierPath
//        _progressLayer = [CAShapeLayer layer];
//        [self.progressLayer setFrame:self.progressBarView.bounds];
//        UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height - borderWidth - pathWidth) / 2 startAngle:startAngle endAngle:endAngle clockwise:YES];
//
//        self.progressLayer.lineCap = kCALineCapRound;
//        self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
//        self.progressLayer.lineWidth = 3.0f;
//        self.progressLayer.path = progressPath.CGPath;
//        self.progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
//        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
//        self.progressLayer.position = CGPointMake(self.progressBarView.layer.frame.size.width / 2 - borderWidth / 2, self.progressBarView.layer.frame.size.height / 2 - borderWidth / 2);
//        [self.progressLayer setStrokeEnd:0.0f];
//        [self.syncProgressSubView.layer addSublayer:self.progressLayer];
//
//        [self.progressLayer setStrokeEnd:newProgress];
//        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        strokeEndAnimation.duration = updateInterval;
//        [strokeEndAnimation setFillMode:kCAFillModeForwards];
//        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        strokeEndAnimation.removedOnCompletion = NO;
//        strokeEndAnimation.fromValue = [NSNumber numberWithFloat:lastProgress];
//        strokeEndAnimation.toValue = [NSNumber numberWithFloat:blockNewProgress];
//        _lastProgress = blockNewProgress;
//        [self.progressLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
//    } failureBlock:^(NSError *error) {
//        self.lastProgress = 0.0f;
//        self.progressLayer.strokeEnd = 0.0f;
//        self.progressLayer.strokeStart = 0.0f;
//        [self.progressLayer removeAllAnimations];
//        [self.syncProgressSubView removeFromSuperview];
//        _progressLayer = nil;
//        _syncProgressSubView = nil;
//    }];
//
//    newProgress = blockNewProgress;
//}

- (void)showImageCaption:(BOOL)show {
    if (show) {
        self.captionLabelTopConstraint.constant = 10.0f;
        self.captionLabelBottomConstraint.constant = 10.0f;
    }
    else {
        self.captionLabelTopConstraint.constant = 0.0f;
        self.captionLabelBottomConstraint.constant = 0.0f;
    }
}

- (void)setImageCaptionWithString:(NSString *)captionString {
    self.captionLabel.text = [TAPUtil nullToEmptyString:captionString];
    if([captionString isEqualToString:@""]) {
        [self showImageCaption:NO];
    }
    else {
        [self showImageCaption:YES];
    }
}

- (void)setFullImage:(UIImage *)image {
    self.bubbleImageView.image = image;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    self.thumbnailBubbleImageView.image = thumbnailImage;
}

@end

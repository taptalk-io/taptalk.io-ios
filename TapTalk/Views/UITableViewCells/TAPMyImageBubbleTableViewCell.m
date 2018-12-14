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
@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
//@property (strong, nonatomic) IBOutlet UIImageView *cancelImageView; //WK Temp - probably not required.
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBubbleRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonRightConstraint;

@property (strong, nonatomic) UIVisualEffectView *blurView;

@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat cellHeight;

@end

@implementation TAPMyImageBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _maxWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0f / 3.0f) - 16.0f; //two third of screen, and 16.0f is right padding.
    _maxHeight = self.maxWidth / 234.0f * 300.0f; //234.0f and 300.0f are width and height constraint on design
    _minWidth = (self.maxWidth / 3.0f); //one third of max Width
    _minHeight = self.minWidth / 78.0f * 100.0f; //78.0f and 100.0f are width and height constraint on design
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    _isDownloaded = NO;
    
    //WK Temp
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));
    
    CGPoint centerPoint = CGPointMake(-CGRectGetWidth(self.progressBarView.bounds) / 2.0f, CGRectGetHeight(self.progressBarView.bounds) / 2.0f); //because the progressBarLayer will be rotated -90°.
    CAShapeLayer *progressBarLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *progressBarPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                   radius:CGRectGetWidth(self.progressBarView.bounds) / 2.0f
                                                               startAngle:0.0f //WK Note - avoid rotation here because rotation here will cause misvalue.
                                                                 endAngle:2 * M_PI clockwise:YES];
    progressBarLayer.path = progressBarPath.CGPath;
    progressBarLayer.strokeColor = [UIColor whiteColor].CGColor;
    progressBarLayer.lineCap = kCALineCapRound;
    progressBarLayer.lineWidth = 3.0f;
    progressBarLayer.strokeEnd = 0.0f; //WK Note - probably, only strokEnd will be changed as the upload progress changes. and put in async
    progressBarLayer.strokeStart = 0.0f;
    progressBarLayer.transform = CATransform3DMakeRotation(-M_PI / 2.0f, 0.0f, 0.0f, 1.0f); //WK Note - Rotate 90° to make starting point from top.
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [UIView animateWithDuration:0.2f animations:^{
            self.progressBackgroundView.alpha = 0.0f;
            self.blurView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.blurView removeFromSuperview];
            [self receiveSentEvent];
            _isDownloaded = YES;
        }];
    }];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.toValue = [NSNumber numberWithFloat:1.0f];//this will be percentage of the upload progress. 1.0f is the maximum value.
    animation.duration = 3.0f;
    animation.removedOnCompletion = YES;
    [progressBarLayer addAnimation:animation forKey:@"ProgressAnimation"];
    [self.progressBarView.layer addSublayer:progressBarLayer];
    [CATransaction commit];
    //End Temp
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.bubbleImageView.image = nil;
    
    if (self.isDownloaded) {
        self.progressBackgroundView.alpha = 0.0f;
    }
    else {
        self.progressBackgroundView.alpha = 1.0f;
    }
}

#pragma mark - Custom Method
- (void)setMessage:(TAPMessageModel *)message {
   
    [super setMessage:message];
    
    UIImage *selectedImage = [TAPImageView imageFromCacheWithKey:message.localID];
    selectedImage = [self compressImage:selectedImage];
    
    self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
    self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
    
    if (!self.isDownloaded) {
        self.blurView.frame = CGRectMake(CGRectGetMinX(self.blurView.frame), CGRectGetMinY(self.blurView.frame), self.bubbleImageViewWidthConstraint.constant, self.bubbleImageViewHeightConstraint.constant);
        [self.bubbleImageView insertSubview:self.blurView atIndex:0];
    }

    [self.bubbleImageView setImage:selectedImage];
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
    if ([self.delegate respondsToSelector:@selector(myImageCancelDidTapped)]) {
        [self.delegate myImageCancelDidTapped];
    }
}

- (UIImage *)compressImage:(UIImage *)image {
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
    
    return image;
}

@end

//
//  TAPYourImageBubbleTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPYourImageBubbleTableViewCell.h"

@interface TAPYourImageBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;

@property (strong, nonatomic) IBOutlet TAPImageView *thumbnailBubbleImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;

@property (strong, nonatomic) IBOutlet UIView *bubbleView;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelBottomConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeftConstraint;

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


- (IBAction)replyButtonDidTapped:(id)sender;
- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showImageCaption:(BOOL)show;
- (void)setImageCaptionWithString:(NSString *)captionString;

@end

@implementation TAPYourImageBubbleTableViewCell

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
    
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    
    self.bubbleView.clipsToBounds = YES;
    
    self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));
    
    self.progressBackgroundView.alpha = 0.0f;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.thumbnailBubbleImageView.image = nil;
    self.bubbleImageView.image = nil;
    self.progressBackgroundView.alpha = 0.0f;
    self.captionLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (IBAction)replyButtonDidTapped:(id)sender {
    
}

- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];

    UIImage *selectedImage = nil;
    if (fileID == nil || [fileID isEqualToString:@""]) {
        [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
            if (savedImage != nil) {
                [self getImageSizeFromImage:savedImage];
                
                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
                [self.bubbleImageView setImage:savedImage];
            }
            else {
                self.bubbleImageViewWidthConstraint.constant = 0.0f;
                self.bubbleImageViewHeightConstraint.constant = 0.0f;
            }
        }];

//        selectedImage = [dataDictionary objectForKey:@"dummyImage"];
//        [self getImageSizeFromImage:selectedImage];
//
//        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
//        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
//        [self.bubbleImageView setImage:selectedImage];
//        [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
//            if (savedImage != nil) {
//                [self getImageSizeFromImage:savedImage];
//                
//                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
//                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
//                [self.bubbleImageView setImage:savedImage];
//            }
//            else {
//                self.bubbleImageViewWidthConstraint.constant = 0.0f;
//                self.bubbleImageViewHeightConstraint.constant = 0.0f;
//            }
//        }];
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
    
    NSString *thumbnailImageString = [message.data objectForKey:@"thumbnail"];
    thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
    
    if (![thumbnailImageString isEqualToString:@""]) {
        NSData *thumbnailImageData = [[NSData alloc]
                                      initWithBase64EncodedString:thumbnailImageString options:0];
        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailImageData];
        self.thumbnailBubbleImageView.image = thumbnailImage;
        
    }
    
    //    if (!self.isDownloaded) {
    //        self.blurView.frame = CGRectMake(CGRectGetMinX(self.blurView.frame), CGRectGetMinY(self.blurView.frame), self.bubbleImageViewWidthConstraint.constant, self.bubbleImageViewHeightConstraint.constant);
    //        [self.bubbleImageView insertSubview:self.blurView atIndex:0];
    //    }
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated {
//    self.chatBubbleButton.userInteractionEnabled = NO;
    
    if (isShowed) {
        NSTimeInterval lastMessageTimeInterval = [self.message.created doubleValue] / 1000.0f; //change to second from milisecond
        
        NSDate *currentDate = [NSDate date];
        NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
        
        NSTimeInterval timeGap = currentTimeInterval - lastMessageTimeInterval;
        NSDateFormatter *midnightDateFormatter = [[NSDateFormatter alloc] init];
        [midnightDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // POSIX to avoid weird issues
        midnightDateFormatter.dateFormat = @"dd-MMM-yyyy";
        NSString *midnightFormattedCreatedDate = [midnightDateFormatter stringFromDate:currentDate];
        
        NSDate *todayMidnightDate = [midnightDateFormatter dateFromString:midnightFormattedCreatedDate];
        NSTimeInterval midnightTimeInterval = [todayMidnightDate timeIntervalSince1970];
        
        NSTimeInterval midnightTimeGap = currentTimeInterval - midnightTimeInterval;
        
        NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
        NSString *lastMessageDateString = @"";
        if (timeGap <= midnightTimeGap) {
            //Today
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm";
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
        }
        else if (timeGap <= 86400.0f + midnightTimeGap) {
            //Yesterday
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm";
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"yesterday at %@", @""), dateString];
        }
        else {
            //Set date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
            
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
        }
        
        NSString *statusString = [NSString stringWithFormat:NSLocalizedString(@"Sent %@", @""), lastMessageDateString];
        self.statusLabel.text = statusString;
        
        CGFloat animationDuration = 0.2f;
        
        if (!animated) {
            animationDuration = 0.0f;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.statusLabel.alpha = 1.0f;
//            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
            self.statusLabelTopConstraint.constant = 2.0f;
            self.statusLabelHeightConstraint.constant = 13.0f;
            self.replyButton.alpha = 1.0f;
            self.replyButtonLeftConstraint.constant = 2.0f;
        } completion:^(BOOL finished) {
//            self.chatBubbleButton.userInteractionEnabled = YES;
        }];
    }
    else {
        CGFloat animationDuration = 0.2f;
        
        if (!animated) {
            animationDuration = 0.0f;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
//            self.chatBubbleButton.backgroundColor = [UIColor clearColor];
            self.statusLabelTopConstraint.constant = 0.0f;
            self.statusLabelHeightConstraint.constant = 0.0f;
            self.replyButton.alpha = 0.0f;
            self.replyButtonLeftConstraint.constant = -28.0f;
        } completion:^(BOOL finished) {
//            self.chatBubbleButton.userInteractionEnabled = YES;
            self.statusLabel.alpha = 0.0f;
        }];
    }
}

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

- (void)animateFinishedDownloadingImage {
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

- (void)animateFailedDownloadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
}

- (void)animateProgressDownloadingImageWithProgress:(CGFloat)progress total:(CGFloat)total {
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

- (void)showProgressDownloadView:(BOOL)show {
    if (show) {
        self.progressBackgroundView.alpha = 1.0f;
    }
    else {
        self.progressBackgroundView.alpha = 0.0f;
    }
}

- (void)setInitialAnimateDownloadingImage {
    
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

- (void)setFullImage:(UIImage *)image {
    self.bubbleImageView.image = image;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    self.thumbnailBubbleImageView.image = thumbnailImage;
}

@end

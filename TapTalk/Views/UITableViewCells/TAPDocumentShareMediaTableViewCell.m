//
//  TAPDocumentShareMediaTableViewCell.m
//  TapTalk
//
//  Created by TapTalk.io on 19/08/22.
//

#import "TAPDocumentShareMediaTableViewCell.h"

@interface TAPDocumentShareMediaTableViewCell ()
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *documentTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *documentInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *documentStatusIconView;

@property (weak, nonatomic) IBOutlet UIView *downloadView;
@property (weak, nonatomic) IBOutlet UIView *doneDownloadView;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UIView *retryDownloadView;
@property (weak, nonatomic) IBOutlet UIView *progressBarView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat pathWidth;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) NSInteger updateInterval;


@end

@implementation TAPDocumentShareMediaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.documentStatusIconView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPinBackground];
    self.documentStatusIconView.layer.cornerRadius = 8.0f;
    
    UIFont *documentTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftFileBubbleName];
    UIFont *documentInfoFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMediaInfo];
    UIColor *textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTitleLabel];
    
    self.documentTitleLabel.font = documentTitleFont;
    self.documentTitleLabel.textColor = textColor;
    
    self.documentInfoLabel.font = documentInfoFont;
    self.documentInfoLabel.textColor = [textColor colorWithAlphaComponent:0.8f];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleLongPress:)];
    self.longPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.contentView addGestureRecognizer:self.longPressGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleBubbleViewTap:)];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)prepareForReuse {
    self.downloadView.alpha = 0.0f;
    self.doneDownloadView.alpha = 0.0f;
    self.cancelView.alpha = 0.0f;
    self.retryDownloadView.alpha = 0.0f;
    self.progressBarView.alpha = 0.0f;
}

- (void)setDocumentTitleInfoWithMessage:(TAPMessageModel *)message {
    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
    NSString *fileName = [message.data objectForKey:@"fileName"];
    
    NSTimeInterval messageTimeInterval = [message.created doubleValue] / 1000.0f;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:messageTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yy";
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";

    NSString *dateString = [dateFormatter stringFromDate:messageDate];
    NSString *timeString = [timeFormatter stringFromDate:messageDate];
    
    self.documentInfoLabel.text = [NSString stringWithFormat:@"%@ • %@ • %@", fileSize, dateString, timeString];
    
    self.documentTitleLabel.text = fileName;
    
}


- (IBAction)downloadButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(documentShareManagerDownloadButtonDidTapped:)]) {
        [self.delegate documentShareManagerDownloadButtonDidTapped:self.message];
        
    }
    
}

- (IBAction)cancelButtonDidTapped:(id)sender {
    
}

- (IBAction)retryButtonDidTapped:(id)sender {
    
}

- (IBAction)doneDownloadButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(documentShareManagerOpenFileButtonDidTapped:)]) {
        [self.delegate documentShareManagerOpenFileButtonDidTapped:self.message];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(documentShareManagerLongPressedWithMessage:)]) {
            [self.delegate documentShareManagerLongPressedWithMessage:self.message];
        }
    }
}

- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer {
    if(self.downloadView.alpha == 1.0f) {
        if ([self.delegate respondsToSelector:@selector(documentShareManagerDownloadButtonDidTapped:)]) {
            [self.delegate documentShareManagerDownloadButtonDidTapped:self.message];
            
        }
    }
    else if(self.doneDownloadView.alpha == 1.0f) {
        if ([self.delegate respondsToSelector:@selector(documentShareManagerOpenFileButtonDidTapped:)]) {
            [self.delegate documentShareManagerOpenFileButtonDidTapped:self.message];
        }
    }
}

- (void)showDownloadedState:(BOOL)isShow {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    if (isShow) {
        [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeDoneDownloadedUploaded];
    }
    else {
        [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeNotDownloaded];
    }
}

- (void)showFileBubbleStatusWithType:(TAPDocumentShareManagerStateType)type {
    
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
    
    if (type == TAPDocumentShareManagerStateTypeDoneDownloadedUploaded) {
        self.cancelView.alpha = 0.0f;
        self.progressBarView.alpha = 0.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 1.0f;
        self.retryDownloadView.alpha = 0.0f;
    }
    else if (type == TAPDocumentShareManagerStateTypeNotDownloaded) {
        self.cancelView.alpha = 0.0f;
        self.progressBarView.alpha = 0.0f;
        self.downloadView.alpha = 1.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;
    }
    else if (type == TAPDocumentShareManagerStateTypeUploading) {
        self.cancelView.alpha = 1.0f;
        self.progressBarView.alpha = 0.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;
    }
    else if (type == TAPDocumentShareManagerStateTypeDownloading) {
        self.cancelView.alpha = 1.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;
        self.progressBarView.alpha = 1.0f;
    }
    else if (type == TAPDocumentShareManagerStateTypeRetryUpload) {
        self.cancelView.alpha = 0.0f;
        self.progressBarView.alpha = 0.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 1.0f;
        NSString *statusString = NSLocalizedStringFromTableInBundle(@"Failed to send, tap to retry", nil, [TAPUtil currentBundle], @"");
        [self.contentView layoutIfNeeded];
    }
    else if (type == TAPDocumentShareManagerStateTypeRetryDownload) {
        self.cancelView.alpha = 0.0f;
        self.progressBarView.alpha = 0.0f;
        self.downloadView.alpha = 1.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;;
    }
}

- (void)animateFinishedUploadFile {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeDoneDownloadedUploaded];
}

- (void)animateFinishedDownloadFile {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeDoneDownloadedUploaded];
}

- (void)animateCancelDownloadFile {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeNotDownloaded];
}

- (void)animateFailedUploadFile {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeRetryUpload];
    
    /**
    self.chatBubbleRightConstraint.constant = 16.0f;
    self.statusIconRightConstraint.constant = 2.0f;
    
    self.sendingIconLeftConstraint.constant = 4.0f;
    self.sendingIconImageView.alpha = 0.0f;
    self.sendingIconBottomConstraint.constant = -5.0f;
    
    self.statusIconImageView.alpha = 0.0f;
    */
    
    
    [self.contentView layoutIfNeeded];
}

- (void)animateFailedDownloadFile {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
  //  [self.progressLayer removeAllAnimations];
   // [self.syncProgressSubView removeFromSuperview];
  //  _progressLayer = nil;
   // _syncProgressSubView = nil;
    
    [self showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeRetryUpload];
}

- (void)animateProgressUploadingFileWithProgress:(CGFloat)progress total:(CGFloat)total {
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;
    
    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
    
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

- (void)animateProgressDownloadingFileWithProgress:(CGFloat)progress total:(CGFloat)total {
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;
    
    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
    //Circular Progress Bar using CAShapeLayer and UIBezierPath
    _progressLayer = [CAShapeLayer layer];
    [self.progressLayer setFrame:self.progressBarView.bounds];
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height - self.borderWidth - self.pathWidth) / 2 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    
    self.progressBarView.alpha = 1.0f;
    
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth = 3.0f;
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.position = CGPointMake(self.progressBarView.layer.frame.size.width / 2 - self.borderWidth / 2, self.progressBarView.layer.frame.size.height / 2 - self.borderWidth / 2);
    [self.progressLayer setStrokeEnd:0.0f];
    [self.syncProgressSubView.layer addSublayer:self.progressLayer];
    
    NSLog(@"sycnhView: %f %lf", self.syncProgressSubView.alpha, self.progressBarView.alpha);
    NSLog(@"sycnhView prog: %f %lf", self.lastProgress, self.newProgress);
    
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



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  TAPYourImageBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPYourImageBubbleTableViewCell.h"
#import "ZSWTappableLabel.h"

@interface TAPYourImageBubbleTableViewCell () <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIGestureRecognizerDelegate, TAPImageViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;
@property (strong, nonatomic) IBOutlet UIView *replyDecorationView;
@property (strong, nonatomic) IBOutlet UIView *quoteDecorationView;
@property (strong, nonatomic) IBOutlet UIView *fileBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fileImageView;

@property (strong, nonatomic) IBOutlet TAPImageView *thumbnailBubbleImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *replyInnerView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UIView *imageTimestampContainerView;
@property (strong, nonatomic) IBOutlet UIView *visualEffectView;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *openImageButton;

@property (strong, nonatomic) IBOutlet UIView *senderInitialView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialLabel;
@property (strong, nonatomic) IBOutlet UIButton *senderProfileImageButton;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *imageTimestampLabel;
@property (strong, nonatomic) IBOutlet ZSWTappableLabel *captionLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewInnerViewLeadingContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyNameLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyNameLabelTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyMessageLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyMessageLabelTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timestampLabelHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderProfileImageButtonWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewHeightConstraint;

@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;

@property (nonatomic) BOOL isShowForwardView;
@property (nonatomic) BOOL isShowSenderInfoView;
@property (nonatomic) BOOL isShowQuoteView;
@property (nonatomic) BOOL isShowReplyView;

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

@property (strong, nonatomic) NSString *currentFileID;
@property (strong, nonatomic) NSString *currentProfileImageURLString;

- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)quoteViewButtonDidTapped:(id)sender;
- (IBAction)replyViewButtonDidTapped:(id)sender;
- (IBAction)senderProfileImageButtonDidTapped:(id)sender;
- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showImageCaption:(BOOL)show;
- (void)setImageCaptionWithString:(NSString *)captionString;

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)setBubbleCellStyle;
- (void)showSenderInfo:(BOOL)show;
- (void)updateSpacingConstraint;

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
    [self.contentView layoutIfNeeded];

    self.statusLabel.alpha = 0.0f;
    
    self.bubbleView.clipsToBounds = YES;
    
    self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.imageTimestampContainerView.layer.cornerRadius = 10.0f;
    self.imageTimestampContainerView.clipsToBounds = YES;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    
    self.thumbnailBubbleImageView.layer.cornerRadius = 12.0f;
    self.thumbnailBubbleImageView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.thumbnailBubbleImageView.clipsToBounds = YES;
    self.thumbnailBubbleImageView.layer.masksToBounds = YES;
    
    self.bubbleImageView.layer.cornerRadius = 12.0f;
    self.bubbleImageView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleImageView.clipsToBounds = YES;
    self.bubbleImageView.layer.masksToBounds = YES;

    self.visualEffectView.layer.cornerRadius = 12.0f;
    self.visualEffectView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.visualEffectView.clipsToBounds = YES;
    self.visualEffectView.layer.masksToBounds = YES;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));
    
    self.swipeReplyView.layer.cornerRadius = CGRectGetHeight(self.swipeReplyView.frame) / 2.0f;
    self.swipeReplyView.backgroundColor = [[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.3f];
    
    UIImage *swipeReplyImage;
    if (IS_BELOW_IOS_13) {
        swipeReplyImage = [UIImage imageNamed:@"TAPIconReplyChatOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        swipeReplyImage = [UIImage imageNamed:@"TAPIconReplyChatOrange" inBundle:[TAPUtil currentBundle] withConfiguration:nil];
    }
    
    swipeReplyImage = [swipeReplyImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIconPrimary]];
    self.swipeReplyImageView.image = swipeReplyImage;
    
    self.progressBackgroundView.alpha = 0.0f;
    
    self.replyView.layer.cornerRadius = 4.0f;
    self.replyView.clipsToBounds = YES;
    
    self.quoteView.layer.cornerRadius = 8.0f;
    self.quoteView.clipsToBounds = YES;
    
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.delegate = self;
    
    self.fileBackgroundView.layer.cornerRadius = 24.0f;
    
    [self showQuoteView:NO];
    [self showReplyView:NO withMessage:nil];
    [self showForwardView:NO];
    
    self.captionLabel.tapDelegate = self;
    self.captionLabel.longPressDelegate = self;
    self.captionLabel.longPressDuration = 0.05f;
    
    self.senderImageView.clipsToBounds = YES;
    self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame)/2.0f;
    
    [self setBubbleCellStyle];
    [self showSenderInfo:NO];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    self.panGestureRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    _mentionIndexesArray = [[NSArray alloc] init];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.thumbnailBubbleImageView.image = nil;
    self.progressBackgroundView.alpha = 0.0f;
    self.captionLabel.text = @"";
    self.openImageButton.alpha = 0.0f;
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    [self showSenderInfo:NO];
    [self showQuoteView:NO];
    [self showReplyView:NO withMessage:nil];
    
    _bubbleViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleBubbleViewLongPress:)];
    self.bubbleViewLongPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.bubbleView addGestureRecognizer:self.bubbleViewLongPressGestureRecognizer];
    
    self.mentionIndexesArray = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Delegate
#pragma mark UIGestureRecognizer
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        if (fabs(velocity.x) > fabs(velocity.y)) {
            return YES;
        }
    }

    return NO;
}

- (void)handlePanGestureAction:(UIPanGestureRecognizer *)recognizer {
    if (![[TapUI sharedInstance] isReplyMessageMenuEnabled]) {
        return;
    }
    
     if (recognizer.state == UIGestureRecognizerStateBegan) {
            _disableTriggerHapticFeedbackOnDrag = NO;
        }
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:self];
            
            if (translation.x < 0) {
                //Cannot swipe left
                return;
            }
            
            if (translation.x > 50.0f && !self.disableTriggerHapticFeedbackOnDrag) {
                [TAPUtil tapticImpactFeedbackGenerator];
                
                [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
                    self.swipeReplyView.alpha = 0.0f;
                    self.swipeReplyViewHeightConstraint.constant = 15.0f;
                    self.swipeReplyViewWidthConstraint.constant = 15.0f;
                    [self.contentView layoutIfNeeded];
                    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;

                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
                        self.swipeReplyView.alpha = 1.0f;
                        self.swipeReplyViewHeightConstraint.constant = 30.0f;
                        self.swipeReplyViewWidthConstraint.constant = 30.0f;
                        [self.contentView layoutIfNeeded];
                        self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
                    } completion:nil];
                }];
                
                _disableTriggerHapticFeedbackOnDrag = YES;
            }
            
            if (translation.x > 70.0f) {
                translation.x = 70.0f;
            }
            
            self.bubbleView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.senderImageView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.senderInitialView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.senderProfileImageButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.replyButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.statusLabel.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.swipeReplyView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            
            self.swipeReplyView.alpha = translation.x / 50.0f;
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x > 50.0f) {
                if ([self.delegate respondsToSelector:@selector(yourImageBubbleDidTriggerSwipeToReplyWithMessage:)]) {
                    [self.delegate yourImageBubbleDidTriggerSwipeToReplyWithMessage:self.message];
                }
            }
            
            _disableTriggerHapticFeedbackOnDrag = NO;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.senderImageView.transform = CGAffineTransformIdentity;
                self.senderInitialView.transform = CGAffineTransformIdentity;
                self.senderProfileImageButton.transform = CGAffineTransformIdentity;
                self.replyButton.transform = CGAffineTransformIdentity;
                self.statusLabel.transform = CGAffineTransformIdentity;
                self.swipeReplyView.transform = CGAffineTransformIdentity;
                
                self.swipeReplyView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.swipeReplyViewHeightConstraint.constant = 30.0f;
                self.swipeReplyViewWidthConstraint.constant = 30.0f;
                [self.contentView layoutIfNeeded];
                self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
            }];
        }
        else if (recognizer.state == UIGestureRecognizerStateCancelled) {
            _disableTriggerHapticFeedbackOnDrag = NO;
            
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.senderImageView.transform = CGAffineTransformIdentity;
                self.senderInitialView.transform = CGAffineTransformIdentity;
                self.senderProfileImageButton.transform = CGAffineTransformIdentity;
                self.replyButton.transform = CGAffineTransformIdentity;
                self.statusLabel.transform = CGAffineTransformIdentity;
                self.swipeReplyView.transform = CGAffineTransformIdentity;
                
                self.swipeReplyView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.swipeReplyViewHeightConstraint.constant = 30.0f;
                self.swipeReplyViewWidthConstraint.constant = 30.0f;
                [self.contentView layoutIfNeeded];
                self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
            }];
        }
}

#pragma mark - ZSWTappedLabelDelegate
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    
    //get selected word by tapped/selected index
    NSArray *wordArray = [tappableLabel.text componentsSeparatedByString:@" "];
    NSInteger currentWordLength = 0;
    NSString *selectedWord = @"";
    for (NSString *word in wordArray) {
        currentWordLength = currentWordLength + [word length];
        if(idx <= currentWordLength) {
            selectedWord = word;
            break;
        }
    }
    
    NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
    if (result) {
        switch (result.resultType) {
            case NSTextCheckingTypeAddress:
//                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber:
//                NSLog(@"Phone number: %@", result.phoneNumber);
                if([self.delegate respondsToSelector:@selector(yourImageDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate yourImageDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourImageDidTappedUrl:originalString:)]) {
                    [self.delegate yourImageDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourImageBubblePressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourImageBubblePressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
        }
    }
}

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel longPressedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    //get selected word by tapped/selected index
    NSArray *wordArray = [tappableLabel.text componentsSeparatedByString:@" "];
    NSInteger currentWordLength = 0;
    NSString *selectedWord = @"";
    for (NSString *word in wordArray) {
        currentWordLength = currentWordLength + [word length];
        if(idx <= currentWordLength) {
            selectedWord = word;
            break;
        }
    }
    
    NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
    if (result) {
        switch (result.resultType) {
            case NSTextCheckingTypeAddress:
//                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber:
//                NSLog(@"Phone number: %@", result.phoneNumber);
                if([self.delegate respondsToSelector:@selector(yourImageLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate yourImageLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourImageLongPressedUrl:originalString:)]) {
                    [self.delegate yourImageLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourImageBubbleLongPressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourImageBubbleLongPressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
        }
    }
}

#pragma mark - TAPImageViewDelegate

- (void)imageViewDidFinishLoadImage:(TAPImageView *)imageView {
    if (imageView == self.quoteImageView) {
        if (imageView.image == nil) {
            [self showQuoteView:NO];
            [self showReplyView:YES withMessage:self.message];
        }
    }
}

#pragma mark - Custom Method
- (void)setBubbleCellStyle {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleBackground];
    self.quoteView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleQuoteBackground];
    self.replyInnerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleQuoteBackground];
    self.replyDecorationView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleQuoteDecorationBackground];
    self.quoteDecorationView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleQuoteDecorationBackground];
    self.fileBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconQuotedFileBackgroundLeft];
    
    UIFont *quoteTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleQuoteTitle];
    UIColor *quoteTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleQuoteTitle];
    
    UIFont *quoteContentFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleQuoteContent];
    UIColor *quoteContentColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleQuoteContent];
    
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleMessageBody];
    UIColor *bubbleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageBody];
    
    UIFont *statusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMessageStatus];
    UIColor *statusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMessageStatus];

    UIFont *timestampLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleMessageTimestamp];
    UIColor *timestampLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageTimestamp];

    UIFont *imageTimestampLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMediaInfo];
    UIColor *imageTimestampLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMediaInfo];
    
    UIFont *senderNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleSenderName];
    UIColor *senderNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleSenderName];
    
    UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarSmallLabel];
    UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarSmallLabel];
    
    self.senderInitialLabel.textColor = initialNameLabelColor;
    self.senderInitialLabel.font = initialNameLabelFont;
    self.senderInitialView.layer.cornerRadius = CGRectGetWidth(self.senderInitialView.frame) / 2.0f;
    self.senderInitialView.clipsToBounds = YES;

    self.replyNameLabel.textColor = quoteTitleColor;
    self.replyNameLabel.font = quoteTitleFont;
    
    self.replyMessageLabel.textColor = quoteContentColor;
    self.replyMessageLabel.font = quoteContentFont;
    
    self.quoteTitleLabel.textColor = quoteTitleColor;
    self.quoteTitleLabel.font = quoteTitleFont;
    
    self.quoteSubtitleLabel.textColor = quoteContentColor;
    self.quoteSubtitleLabel.font = quoteContentFont;
    
    self.forwardTitleLabel.textColor = quoteContentColor;
    self.forwardTitleLabel.font = quoteContentFont;
    
    self.forwardFromLabel.textColor = quoteContentColor;
    self.forwardFromLabel.font = quoteContentFont;
    
    self.captionLabel.textColor = bubbleLabelColor;
    self.captionLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;

    self.timestampLabel.textColor = timestampLabelColor;
    self.timestampLabel.font = timestampLabelFont;

    self.imageTimestampLabel.textColor = imageTimestampLabelColor;
    self.imageTimestampLabel.font = imageTimestampLabelFont;
    
    self.senderNameLabel.font = senderNameLabelFont;
    self.senderNameLabel.textColor = senderNameLabelColor;
    
    UIImage *documentsImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentsImage = [documentsImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileWhite]];
    self.fileImageView.image = documentsImage;
}

- (IBAction)senderProfileImageButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageBubbleDidTappedProfilePictureWithMessage:)]) {
        [self.delegate yourImageBubbleDidTappedProfilePictureWithMessage:self.message];
    }
}

- (IBAction)replyButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageReplyDidTappedWithMessage:)]) {
        [self.delegate yourImageReplyDidTappedWithMessage:self.message];
    }
}

- (IBAction)openImageButtonDidTapped:(id)sender  {
    if ([self.delegate respondsToSelector:@selector(yourImageDidTapped:)]) {
        [self.delegate yourImageDidTapped:self];
    }
}

- (void)setMessage:(TAPMessageModel *)message {
    if(message == nil) {
        return;
    }
    
    _message = message;
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    CGFloat imageTimestampContainerWidthWithMargin = CGRectGetWidth(self.imageTimestampContainerView.frame) + (6.0f * 2);
    if (self.minWidth < imageTimestampContainerWidthWithMargin) {
        _minWidth = imageTimestampContainerWidthWithMargin;
    }
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    
    if (fileID == nil || [fileID isEqualToString:@""]) {
        [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
            if (savedImage != nil) {
                [self getImageSizeFromImage:savedImage];
                
                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
                [self.contentView layoutIfNeeded];
                [self.bubbleImageView setImage:savedImage];
            }
            else {
                NSString *fileURL = [dataDictionary objectForKey:@"url"];
                if (fileURL == nil || [fileURL isEqualToString:@""]) {
                    NSString *fileURL = [dataDictionary objectForKey:@"fileURL"];
                }
                if (fileURL != nil || ![fileURL isEqualToString:@""]) {
                    [self.bubbleImageView setImageWithURLString:fileURL];
                    if (self.bubbleImageViewWidthConstraint.constant == 0.0f) {
                        self.bubbleImageViewWidthConstraint.constant = 240.0f;
                    }
                    if (self.bubbleImageViewHeightConstraint.constant == 0.0f) {
                        self.bubbleImageViewHeightConstraint.constant = 240.0f;
                    }
                    [self.contentView layoutIfNeeded];
                }
                else {
                    self.bubbleImageViewWidthConstraint.constant = 0.0f;
                    self.bubbleImageViewHeightConstraint.constant = 0.0f;
                    [self.contentView layoutIfNeeded];
                }
            }
        }];
    }
    else {
        if(_currentFileID == nil || ![self.currentFileID isEqualToString:fileID]) {
            //Cell is reused for different image, set image to nil first to prevent last image shown when load new image
            self.bubbleImageView.image = nil;
        }
        
        //already called fetchImageDataWithMessage function in view controller for fetch image
        //so no need to set the image here
        //just save the height and width constraint
        
        CGFloat obtainedCellWidth = [[message.data objectForKey:@"width"] floatValue];
        CGFloat obtainedCellHeight = [[message.data objectForKey:@"height"] floatValue];
        [self getResizedImageSizeWithHeight:obtainedCellHeight width:obtainedCellWidth];
        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
            
        _currentFileID = fileID;
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
    
    if (![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) {
        [self showForwardView:YES];
        [self setForwardData:message.forwardFrom];
        _isShowForwardView = YES;
    }
    else {
        [self showForwardView:NO];
        _isShowForwardView = NO;
    }

    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""] && message.quote != nil && message.replyTo != nil) {
        //reply to exists
        
        //if reply exists check if image in quote exists
        //if image exists  change view to Quote View
        
        if (self.isShowForwardView) {
            self.senderNameTopConstraint.constant = 10.0f;
        }
        else {
            self.senderNameTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        if((message.quote.fileID && ![message.quote.fileID isEqualToString:@""]) || (message.quote.imageURL  && ![message.quote.fileID isEqualToString:@""])) {
            [self showReplyView:NO withMessage:nil];
            [self showQuoteView:YES];
            [self setQuote:message.quote userID:message.replyTo.userID];
        }
        else {
            [self showReplyView:YES withMessage:message];
            [self showQuoteView:NO];
        }
    }
    else if (![message.quote.title isEqualToString:@""] && message.quote != nil) {
        //quote exists
        
        if (self.isShowForwardView) {
            self.senderNameTopConstraint.constant = 10.0f;
        }
        else {
            self.senderNameTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote userID:@""];
        [self showQuoteView:YES];
    }
    else {
        
        if (self.isShowForwardView) {
            self.senderNameTopConstraint.constant = 10.0f;
        }
        else {
            self.senderNameTopConstraint.constant = 10.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }
    
    if (![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) {
        [self showForwardView:YES];
        [self setForwardData:message.forwardFrom];
    }
    else {
        [self showForwardView:NO];
    }
    
    //CS NOTE - check chat room type, show sender info if group type
    if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
        [self showSenderInfo:NO];
        //DV Note - Set sender image to show only sender image, because show sender info view yes will update quote view top constraint to 4.0f making white space in the top of the media
        self.senderImageViewWidthConstraint.constant = 30.0f;
        self.senderImageViewTrailingConstraint.constant = 4.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 30.0f;
        self.senderProfileImageButton.userInteractionEnabled = YES;
        
        NSString *thumbnailImageString = @"";
        TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:message.user.userID];
        if (obtainedUser != nil && ![obtainedUser.imageURL.thumbnail isEqualToString:@""]) {
           thumbnailImageString = obtainedUser.imageURL.thumbnail;
           thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
        }
        else {
           thumbnailImageString = message.user.imageURL.thumbnail;
           thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
        }

        NSString *fullNameString = @"";
        if (obtainedUser != nil && ![obtainedUser.fullname isEqualToString:@""]) {
           fullNameString = obtainedUser.fullname;
           fullNameString = [TAPUtil nullToEmptyString:fullNameString];
        }
        else {
           fullNameString = message.user.fullname;
           fullNameString = [TAPUtil nullToEmptyString:fullNameString];
        }

        if ([thumbnailImageString isEqualToString:@""]) {
            //No photo found, get the initial
            self.senderInitialView.alpha = 1.0f;
            self.senderImageView.alpha = 0.0f;
            self.senderInitialView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:fullNameString];
            self.senderInitialLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:fullNameString isGroup:NO];
        }
        else {
            if(![self.currentProfileImageURLString isEqualToString:thumbnailImageString]) {
                self.senderImageView.image = nil;
            }
            
            self.senderInitialView.alpha = 0.0f;
            self.senderImageView.alpha = 1.0f;
            [self.senderImageView setImageWithURLString:thumbnailImageString];
            _currentProfileImageURLString = thumbnailImageString;
        }
        
        //DV Note - Set sender name to empty string because image and video bubble not showing sender name
        self.senderNameLabel.text = @"";
    }
    else {
        [self showSenderInfo:NO];
        self.senderImageView.image = nil;
        self.senderNameLabel.text = @"";
    }
    
    self.timestampLabel.text = [TAPUtil getMessageTimestampText:self.message.created];
    
    //CS NOTE - Update Spacing should be placed at the bottom
    [self updateSpacingConstraint];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated {
//    self.chatBubbleButton.userInteractionEnabled = NO;
    
//    if (isShowed) {
//        NSTimeInterval lastMessageTimeInterval = [self.message.created doubleValue] / 1000.0f; //change to second from milisecond
//
//        NSDate *currentDate = [NSDate date];
//        NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
//
//        NSTimeInterval timeGap = currentTimeInterval - lastMessageTimeInterval;
//        NSDateFormatter *midnightDateFormatter = [[NSDateFormatter alloc] init];
//        [midnightDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // POSIX to avoid weird issues
//        midnightDateFormatter.dateFormat = @"dd-MMM-yyyy";
//        NSString *midnightFormattedCreatedDate = [midnightDateFormatter stringFromDate:currentDate];
//
//        NSDate *todayMidnightDate = [midnightDateFormatter dateFromString:midnightFormattedCreatedDate];
//        NSTimeInterval midnightTimeInterval = [todayMidnightDate timeIntervalSince1970];
//
//        NSTimeInterval midnightTimeGap = currentTimeInterval - midnightTimeInterval;
//
//        NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
//        NSString *lastMessageDateString = @"";
//        if (timeGap <= midnightTimeGap) {
//            //Today
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"HH:mm";
//            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
//            NSString *appendedLastDateString = NSLocalizedStringFromTableInBundle(@"at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedLastDateString, dateString];
//        }
//        else if (timeGap <= 86400.0f + midnightTimeGap) {
//            //Yesterday
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"HH:mm";
//            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
//            NSString *appendedLastDateString = NSLocalizedStringFromTableInBundle(@"yesterday at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedLastDateString, dateString];
//        }
//        else {
//            //Set date
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
//
//            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
//            NSString *appendedLastDateString = NSLocalizedStringFromTableInBundle(@"at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedLastDateString, dateString];
//        }
//
//        NSString *appendedStatusString = NSLocalizedStringFromTableInBundle(@"Sent ", nil, [TAPUtil currentBundle], @"");
//        NSString *statusString = [NSString stringWithFormat:@"%@%@", appendedStatusString, lastMessageDateString];
//        self.statusLabel.text = statusString;
//
//        self.statusLabel.alpha = 1.0f;
//
//        self.statusLabelTopConstraint.constant = 2.0f;
//        self.statusLabelHeightConstraint.constant = 13.0f;
//        self.replyButton.alpha = 1.0f;
//        self.replyButtonLeftConstraint.constant = 2.0f;
//    }
//    else {
//        self.statusLabelTopConstraint.constant = 0.0f;
//        self.statusLabelHeightConstraint.constant = 0.0f;
//        self.replyButton.alpha = 0.0f;
//        self.replyButtonLeftConstraint.constant = -28.0f;
//
//        self.statusLabel.alpha = 0.0f;
//    }
//    [self.contentView layoutIfNeeded];
}

- (void)showImageCaption:(BOOL)show {
    if (show) {
        self.captionLabelTopConstraint.constant = 4.0f;
        self.captionLabelBottomConstraint.constant = 2.0f;
        self.timestampLabelHeightConstraint.constant = 16.0f;
        
        self.timestampLabel.alpha = 1.0f;
        self.imageTimestampContainerView.alpha = 0.0f;
        
        CGSize captionLabelSize = [self.captionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.captionLabel.bounds), CGFLOAT_MAX)];
        self.captionLabelHeightConstraint.constant = captionLabelSize.height;
    }
    else {
        self.captionLabelTopConstraint.constant = 0.0f;
        self.captionLabelBottomConstraint.constant = 0.0f;
        self.captionLabelHeightConstraint.constant = 0.0f;
        self.timestampLabelHeightConstraint.constant = 0.0f;
        
        self.timestampLabel.alpha = 0.0f;
        self.imageTimestampContainerView.alpha = 1.0f;
        self.imageTimestampLabel.text = [TAPUtil getMessageTimestampText:self.message.created];
    }
    [self.contentView layoutIfNeeded];
}

- (void)setImageCaptionWithString:(NSString *)captionString {
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    self.captionLabel.text = captionString;
    
    if ([captionString isEqualToString:@""]) {
        [self showImageCaption:NO];
        return;
    }
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    NSDataDetector *detectorPhoneNumber = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL];
    
    UIColor *highlightedTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageBodyURLHighlighted];
    UIColor *defaultTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageBodyURL];

    NSString *messageText = [TAPUtil nullToEmptyString:self.captionLabel.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:messageText attributes:nil];
    // the next line throws an exception if string is nil - make sure you check
    [linkDetector enumerateMatchesInString:messageText options:0 range:NSMakeRange(0, messageText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[NSForegroundColorAttributeName] = defaultTextColor;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = highlightedTextColor;
        attributes[@"NSTextCheckingResult"] = result;
        
        [attributedString addAttributes:attributes range:result.range];
    }];
    [detectorPhoneNumber enumerateMatchesInString:messageText options:0 range:NSMakeRange(0, messageText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[NSForegroundColorAttributeName] = defaultTextColor;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = highlightedTextColor;
        attributes[@"NSTextCheckingResult"] = result;
        
        [attributedString addAttributes:attributes range:result.range];
    }];
    
    if (self.message.room.type == RoomTypeGroup || self.message.room.type == RoomTypeChannel) {
        for (NSInteger counter = 0; counter < [self.mentionIndexesArray count]; counter++) {
            NSArray *mentionRangeArray = self.mentionIndexesArray;
            NSRange userRange = [[mentionRangeArray objectAtIndex:counter] rangeValue];
            
            NSString *mentionString = [messageText substringWithRange:userRange];
            NSString *mentionedUserString = [mentionString substringFromIndex:1];
            
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
            attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
            attributes[NSForegroundColorAttributeName] = defaultTextColor;
            attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = highlightedTextColor;
            [attributedString addAttributes:attributes range:userRange];
        }
    }
    
    // Add line spacing
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:self.captionLabel.font.pointSize * 0.25f];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, [attributedString length])];
    
    self.captionLabel.attributedText = attributedString;
    
    [self showImageCaption:YES];
}

- (void)getImageSizeFromImage:(UIImage *)image {
    
    if ((![self.message.replyTo.messageID isEqualToString:@"0"] && ![self.message.replyTo.messageID isEqualToString:@""] && self.message.replyTo != nil) || (![self.message.quote.title isEqualToString:@""] && self.message.quote != nil)) {
        //if replyTo or quote exists set image width and height to default width = maxWidth height = 244.0f
        _cellWidth = self.maxWidth;
        _cellHeight = self.cellWidth / image.size.width * image.size.height;
        if (self.cellHeight > self.maxHeight) {
            _cellHeight = self.maxHeight;
        }
        else if (self.cellHeight < self.minHeight) {
            _cellHeight = self.minHeight;
        }
        return;
    }
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    _cellWidth = imageWidth;
    _cellHeight = imageHeight;
    
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
    if ((![self.message.replyTo.messageID isEqualToString:@"0"] && ![self.message.replyTo.messageID isEqualToString:@""] && self.message.replyTo != nil) || (![self.message.quote.title isEqualToString:@""] && self.message.quote != nil)) {
        //if replyTo or quote exists set image width and height to default width = maxWidth height = 244.0f
        _cellWidth = self.maxWidth;
        _cellHeight = self.cellWidth / width * height;
        
        if (self.cellHeight > self.maxHeight) {
            _cellHeight = self.maxHeight;
        }
        else if (self.cellHeight < self.minHeight) {
            _cellHeight = self.minHeight;
        }
        return;
    }

    CGFloat ratio = width / height;
    CGFloat dimensionRatio = 0.86f;
    CGFloat resultWidth;
    CGFloat resultHeight;
    
    if (ratio > (self.maxWidth / self.minHeight)) {
        // Image width is higher than maxWidth, but height is lower than minHeight
        // Set width to maxWidth, height to minHeight and crop image
        resultWidth = self.maxWidth;
        resultHeight = self.minHeight;
//        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (ratio < (self.minWidth / self.maxHeight)) {
        // Image height is higher than maxHeight, but width is lower than minWidth
        // Set width to minWidth, height to maxHeight and crop image
        resultWidth = self.minWidth;
        resultHeight = self.maxHeight;
//        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (ratio > dimensionRatio) {
        // Width ratio is higher than limit -> use maxWidth
        if (width > self.maxWidth) {
            resultWidth = self.maxWidth;
            resultHeight = resultWidth / ratio;
        } else if (width < self.minWidth) {
            resultWidth = self.minWidth;
            resultHeight = resultWidth / ratio;
        } else {
            resultWidth = width;
            resultHeight = height;
        }
//        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        // Height ratio is higher than limit -> use maxHeight
        if (height > self.maxHeight) {
            resultHeight = self.maxHeight;
            resultWidth = resultHeight * ratio;
        } else if (height < self.minHeight) {
            resultHeight = self.minHeight;
            resultWidth = resultHeight * ratio;
        } else {
            resultWidth = width;
            resultHeight = height;
        }
//        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    _cellWidth = resultWidth;
    _cellHeight = resultHeight;
    
//    CGFloat previousImageWidth = width;
//    CGFloat previousImageHeight = height;
//    
//    CGFloat imageWidth = width;
//    CGFloat imageHeight = height;
//    
//    _cellWidth = imageWidth;
//    _cellHeight = imageHeight;
//    
//    if (imageWidth > imageHeight) {
//        if (imageWidth > self.maxWidth) {
//            imageWidth = self.maxWidth;
//            _cellWidth = imageWidth;
//            
//            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//            _cellHeight = imageHeight;
//            
//            if (imageHeight > self.maxHeight) {
//                imageHeight = self.maxHeight;
//                _cellHeight = imageHeight;
//                
//                imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//                _cellWidth = imageWidth;
//            }
//            else if (imageHeight < self.minHeight) {
//                imageHeight = self.minHeight;
//                _cellHeight = imageHeight;
//                
//                imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//                _cellWidth = imageWidth;
//            }
//        }
//        else if (imageWidth < self.minWidth) {
//            imageWidth = self.minWidth;
//            _cellWidth = imageWidth;
//            
//            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//            _cellHeight = imageHeight;
//            
//            if (imageHeight > self.maxHeight) {
//                imageHeight = self.maxHeight;
//                _cellHeight = imageHeight;
//                
//                imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//                _cellWidth = imageWidth;
//            }
//            else if (imageHeight < self.minHeight) {
//                imageHeight = self.minHeight;
//                _cellHeight = imageHeight;
//                
//                imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//                _cellWidth = imageWidth;
//            }
//        }
//    }
//    else {
//        if (imageHeight > self.maxHeight) {
//            imageHeight = self.maxHeight;
//            _cellHeight = imageHeight;
//            
//            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//            _cellWidth = imageWidth;
//            
//            if (imageWidth > self.maxWidth) {
//                imageWidth = self.maxWidth;
//                _cellWidth = imageWidth;
//
//                imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//                _cellHeight = imageHeight;
//            }
//            else if (imageWidth < self.minWidth) {
//                imageWidth = self.minWidth;
//                _cellWidth = imageWidth;
//
//                imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//                _cellHeight = imageHeight;
//            }
//        }
//        else if (imageHeight < self.minHeight) {
//            imageHeight = self.minHeight;
//            _cellHeight = imageHeight;
//            
//            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
//            _cellWidth = imageWidth;
//            
//            if (imageWidth > self.maxWidth) {
//                imageWidth = self.maxWidth;
//                _cellWidth = imageWidth;
//
//                imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//                _cellHeight = imageHeight;
//            }
//            else if (imageWidth < self.minWidth) {
//                imageWidth = self.minWidth;
//                _cellWidth = imageWidth;
//
//                imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
//                _cellHeight = imageHeight;
//            }
//        }
//    }
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
        self.openImageButton.alpha = 1.0f;
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
    if (image == nil) {
        return;
    }

    self.bubbleImageView.image = image;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    if (thumbnailImage == nil) {
        return;
    }

    self.thumbnailBubbleImageView.image = thumbnailImage;
}

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message {
    _isShowReplyView = show;
    if (show) {
        //check id message sender is equal to active user id, if yes change the title to "You"
        if ([message.replyTo.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            self.replyNameLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
        }
        else {
            self.replyNameLabel.text = message.quote.title;
        }

        self.replyMessageLabel.text = message.quote.content;
        self.replyViewHeightContraint.constant = 60.0f;
        self.replyViewBottomConstraint.constant = 10.0f;
        self.replyViewInnerViewLeadingContraint.constant = 4.0f;
        self.replyNameLabelLeadingConstraint.constant = 8.0f;
        self.replyNameLabelTrailingConstraint.constant = 8.0f;
        self.replyMessageLabelLeadingConstraint.constant = 8.0f;
        self.replyMessageLabelTrailingConstraint.constant = 8.0f;
        self.replyButtonLeadingConstraint.active = YES;
        self.replyButtonTrailingConstraint.active = YES;
        self.replyView.alpha = 1.0f;
        
        if (self.isShowForwardView) {
            self.replyViewTopConstraint.constant = 4.0f;
        }
        else {
            self.replyViewTopConstraint.constant = 0.0f;
        }
    }
    else {
        self.replyNameLabel.text = @"";
        self.replyMessageLabel.text = @"";
        self.replyViewHeightContraint.constant = 0.0f;
        
        if (self.isShowForwardView) {
            self.replyViewBottomConstraint.constant = 8.0f;
        }
        else {
            self.replyViewBottomConstraint.constant = 10.0f;
        }
        
        self.replyViewInnerViewLeadingContraint.constant = 0.0f;
        self.replyNameLabelLeadingConstraint.constant = 0.0f;
        self.replyNameLabelTrailingConstraint.constant = 0.0f;
        self.replyMessageLabelLeadingConstraint.constant = 0.0f;
        self.replyMessageLabelTrailingConstraint.constant = 0.0f;
        self.replyButtonLeadingConstraint.active = NO;
        self.replyButtonTrailingConstraint.active = NO;
        self.replyView.alpha = 0.0f;
    }
    [self.contentView layoutIfNeeded];
}

- (void)showQuoteView:(BOOL)show {
    _isShowQuoteView = show;
    if (show) {
        self.quoteViewLeadingConstraint.active = YES;
        self.quoteViewTrailingConstraint.active = YES;
        self.quoteViewTopConstraint.active = YES;
        self.quoteViewBottomConstraint.active = YES;
        self.quoteView.alpha = 1.0f;
        self.replyViewBottomConstraint.active = NO;
    }
    else {
        self.quoteViewLeadingConstraint.active = NO;
        self.quoteViewTrailingConstraint.active = NO;
        self.quoteViewTopConstraint.active = NO;
        self.quoteViewBottomConstraint.active = NO;
        self.quoteView.alpha = 0.0f;
        self.replyViewBottomConstraint.active = YES;
    }
    [self.contentView layoutIfNeeded];
}

- (void)showForwardView:(BOOL)show {
    if (show) {
        self.forwardFromLabelHeightConstraint.constant = 16.0f;
        self.forwardTitleLabelHeightConstraint.constant = 16.0f;
        self.forwardFromLabelLeadingConstraint.active = YES;
        self.forwardTitleLabelLeadingConstraint.active = YES;
        
    }
    else {
        self.forwardFromLabelHeightConstraint.constant = 0.0f;
        self.forwardTitleLabelHeightConstraint.constant = 0.0f;
        self.forwardFromLabelLeadingConstraint.active = NO;
        self.forwardTitleLabelLeadingConstraint.active = NO;
    }
    [self.contentView layoutIfNeeded];
}

- (void)setForwardData:(TAPForwardFromModel *)forwardData {
    
    NSString *initialAppendedFullnameString = NSLocalizedStringFromTableInBundle(@"From: ", nil, [TAPUtil currentBundle], @"");
    NSString *appendedFullnameString = [NSString stringWithFormat:@"%@%@",initialAppendedFullnameString, forwardData.fullname];
    
    //check id message sender is equal to active user id, if yes change the title to "You"
    if ([forwardData.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        appendedFullnameString = NSLocalizedStringFromTableInBundle(@"From: You", nil, [TAPUtil currentBundle], @"");
    }
    
    self.forwardFromLabel.text = appendedFullnameString;
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc]
     initWithAttributedString:[[NSAttributedString alloc] initWithString:self.forwardFromLabel.text]];
    
    UIFont *quoteTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleQuoteTitle];
    [attributedText addAttribute:NSFontAttributeName
                           value:quoteTitleFont
                           range:NSMakeRange(6, [self.forwardFromLabel.text length] - 6)];
    
    self.forwardFromLabel.attributedText = attributedText;
}

- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID {
    if ([quote.fileType isEqualToString:[NSString stringWithFormat:@"%ld", TAPChatMessageTypeFile]] || [quote.fileType isEqualToString:@"file"]) {
        //TYPE FILE
        self.fileImageView.alpha = 1.0f;
        self.quoteImageView.alpha = 0.0f;
    }
    else {
        if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.imageURL];
        }
        else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.fileID];
        }
        self.fileImageView.alpha = 0.0f;
        self.quoteImageView.alpha = 1.0f;
    }
    
    //check id message sender is equal to active user id, if yes change the title to "You"
    if ([userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        self.quoteTitleLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
    }
    else {
        self.quoteTitleLabel.text = [TAPUtil nullToEmptyString:quote.title];
    }
    self.quoteSubtitleLabel.text = [TAPUtil nullToEmptyString:quote.content];
}

- (IBAction)quoteViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageQuoteDidTappedWithMessage:)]) {
        [self.delegate yourImageQuoteDidTappedWithMessage:self.message];
    }
}

- (IBAction)replyViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageQuoteDidTappedWithMessage:)]) {
        [self.delegate yourImageQuoteDidTappedWithMessage:self.message];
    }
}

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(yourImageBubbleLongPressedWithMessage:)]) {
            [self.delegate yourImageBubbleLongPressedWithMessage:self.message];
        }
    }
}

- (void)showSenderInfo:(BOOL)show {
    _isShowSenderInfoView = show;
    if (show) {
        self.senderImageViewWidthConstraint.constant = 30.0f;
        self.senderImageViewTrailingConstraint.constant = 4.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 30.0f;
        self.senderProfileImageButton.userInteractionEnabled = YES;
        self.senderNameHeightConstraint.constant = 0.0f;
        self.forwardTitleLabelTopConstraint.constant = 0.0f;
        //DV Note - Uncomment this to show sender name label
//        self.senderNameHeightConstraint.constant = 18.0f;
//        self.forwardTitleLabelTopConstraint.constant = 4.0f;
    }
    else {
        self.senderImageViewWidthConstraint.constant = 0.0f;
        self.senderImageViewTrailingConstraint.constant = 0.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 0.0f;
        self.senderProfileImageButton.userInteractionEnabled = NO;
        self.senderNameHeightConstraint.constant = 0.0f;
        self.forwardTitleLabelTopConstraint.constant = 0.0f;
    }
    [self.contentView layoutIfNeeded];
}

- (void)updateSpacingConstraint {
    if (self.isShowForwardView || self.isShowSenderInfoView || self.isShowQuoteView || self.isShowReplyView) {
        if (self.isShowForwardView || self.isShowSenderInfoView) {
            self.replyViewTopConstraint.constant = 4.0f;
            self.quoteViewTopConstraint.constant = 4.0f;
            self.forwardFromLabelTopConstraint.constant = 2.0f;
        }
        else {
            self.senderNameTopConstraint.constant = 0.0f;
            self.replyViewTopConstraint.constant = 0.0f;
            self.quoteViewTopConstraint.constant = 0.0f;
        }
        self.senderNameTopConstraint.constant = 10.0f;
    }
    else {
        self.senderNameTopConstraint.constant = 0.0f;
        self.replyViewTopConstraint.constant = 0.0f;
        self.quoteViewTopConstraint.constant = 0.0f;
        self.forwardFromLabelTopConstraint.constant = 0.0f;
    }
    [self layoutIfNeeded];
}

@end

//
//  TAPMyImageBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMyImageBubbleTableViewCell.h"
#import "ZSWTappableLabel.h"

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

@interface TAPMyImageBubbleTableViewCell () <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIGestureRecognizerDelegate, TAPImageViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;
@property (strong, nonatomic) IBOutlet UIView *replyInnerView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UIView *replyDecorationView;
@property (strong, nonatomic) IBOutlet UIView *quoteDecorationView;
@property (strong, nonatomic) IBOutlet UIView *fileBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *imageTimestampStatusContainerView;
@property (strong, nonatomic) IBOutlet UIView *bubbleHighlightView;
@property (strong, nonatomic) IBOutlet TAPImageView *thumbnailBubbleImageView;
//@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *imageStatusIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retryImageView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *imageTimestampLabel;
@property (strong, nonatomic) IBOutlet ZSWTappableLabel *captionLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardFromLabel;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (strong, nonatomic) IBOutlet UIButton *openImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *starIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *starIconBottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIconImageView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBubbleRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelHeightConstraint;
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconImageViewHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewLeadingConstarint;
@property (weak, nonatomic) IBOutlet UIButton *forwardCheckmarkButton;



@property (strong, nonatomic) UITapGestureRecognizer *bubbleViewTapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;
@property (nonatomic) BOOL isShowForwardView;

@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;
@property (nonatomic) CGFloat newProgress;

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
@property (nonatomic) NSInteger updateInterval;

@property (strong, nonatomic) NSString *currentFileKey;

- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showImageCaption:(BOOL)show;
- (void)setImageCaptionWithString:(NSString *)captionString;
- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;

- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setBubbleCellStyle;

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
    _cellWidth = 0.0f;
    _cellHeight = 0.0f;
    
    _maxWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0f / 3.0f) - 16.0f; //two third of screen, and 16.0f is right padding.
    _maxHeight = self.maxWidth / 234.0f * 300.0f; //234.0f and 300.0f are width and height constraint on design
    _minWidth = (self.maxWidth / 2.0f); //one third of max Width
    _minHeight = self.minWidth / 78.0f * 100.0f; //78.0f and 100.0f are width and height constraint on design
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;

    self.bubbleHighlightView.layer.cornerRadius = 16.0f;
    self.bubbleHighlightView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleHighlightView.clipsToBounds = YES;

    self.imageTimestampStatusContainerView.layer.cornerRadius = 10.0f;
    self.imageTimestampStatusContainerView.clipsToBounds = YES;
    
    self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.thumbnailBubbleImageView.layer.cornerRadius = 12.0f;
    self.thumbnailBubbleImageView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.thumbnailBubbleImageView.clipsToBounds = YES;
    self.thumbnailBubbleImageView.layer.masksToBounds = YES;
    
    self.bubbleImageView.layer.cornerRadius = 12.0f;
    self.bubbleImageView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleImageView.clipsToBounds = YES;
    self.bubbleImageView.layer.masksToBounds = YES;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    _isDownloaded = NO;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));

    self.progressBackgroundView.alpha = 0.0f;
    self.retryButton.alpha = 0.0f;
    self.retryButton.userInteractionEnabled = NO;
    self.retryImageView.alpha = 0.0f;
    self.downloadImageView.alpha = 0.0f;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    
    self.replyView.layer.cornerRadius = 4.0f;
    self.replyView.clipsToBounds = YES;
    
    self.quoteView.layer.cornerRadius = 8.0f;
    self.quoteView.clipsToBounds = YES;
    
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.delegate = self;
    
    self.fileBackgroundView.layer.cornerRadius = 24.0f;
    
    self.starIconImageView.alpha = 0.0f;
    
    self.starIconBottomImageView.alpha = 0.0f;
    
    [self.contentView layoutIfNeeded];
    
    [self showReplyView:NO withMessage:nil];
    [self showQuoteView:NO];
    [self showForwardView:NO];
    
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
    
    _bubbleViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleBubbleViewTap:)];
    [self.contentView addGestureRecognizer:self.bubbleViewTapGestureRecognizer];
    
    _bubbleViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleBubbleViewLongPress:)];
    self.bubbleViewLongPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.bubbleView addGestureRecognizer:self.bubbleViewLongPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    self.panGestureRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
    
    self.captionLabel.tapDelegate = self;
    self.captionLabel.longPressDelegate = self;
    self.captionLabel.longPressDuration = 0.05f;
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    _mentionIndexesArray = [[NSArray alloc] init];
    
    [self setBubbleCellStyle];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.thumbnailBubbleImageView.image = nil;
    self.bubbleImageView.image = nil;
    self.progressBackgroundView.alpha = 0.0f;
    self.captionLabel.text = @"";
    self.openImageButton.alpha = 0.0f;
    
    self.starIconImageView.alpha = 0.0f;
    self.starIconBottomImageView.alpha = 0.0f;
    self.checkMarkIconImageView.alpha = 0.0f;
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    
    self.starImageViewWidthConstarint.constant = 0.0f;
    self.starImageViewLeadingConstarint.constant = 4.0f;
    
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    self.mentionIndexesArray = nil;
    
    [self showReplyView:NO withMessage:nil];
    [self showQuoteView:NO];
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
                if([self.delegate respondsToSelector:@selector(myImageDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate myImageDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(myImageDidTappedUrl:originalString:)]) {
                    [self.delegate myImageDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(myImageBubblePressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate myImageBubblePressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
                if([self.delegate respondsToSelector:@selector(myImageLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate myImageLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(myImageLongPressedUrl:originalString:)]) {
                    [self.delegate myImageLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(myImageBubbleLongPressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate myImageBubbleLongPressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
        }
    }
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

- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer {
    [super handleBubbleViewTap:recognizer];
    NSLog(@"tapped");
 //   if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
  //      [self.delegate myChatBubbleViewDidTapped:self.message];
   // }
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
            self.replyButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.statusLabel.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.swipeReplyView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
//            self.statusIconImageView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.sendingIconImageView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
                
            self.swipeReplyView.alpha = translation.x / 50.0f;
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x > 50.0f) {
                if ([self.delegate respondsToSelector:@selector(myImageBubbleDidTriggerSwipeToReplyWithMessage:)]) {
                    [self.delegate myImageBubbleDidTriggerSwipeToReplyWithMessage:self.message];
                }
            }
            
            _disableTriggerHapticFeedbackOnDrag = NO;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.replyButton.transform = CGAffineTransformIdentity;
                self.statusLabel.transform = CGAffineTransformIdentity;
                self.swipeReplyView.transform = CGAffineTransformIdentity;
//                self.statusIconImageView.transform = CGAffineTransformIdentity;
                self.sendingIconImageView.transform = CGAffineTransformIdentity;
                
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
                self.replyButton.transform = CGAffineTransformIdentity;
                self.statusLabel.transform = CGAffineTransformIdentity;
                self.swipeReplyView.transform = CGAffineTransformIdentity;
//                self.statusIconImageView.transform = CGAffineTransformIdentity;
                self.sendingIconImageView.transform = CGAffineTransformIdentity;
                
                self.swipeReplyView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.swipeReplyViewHeightConstraint.constant = 30.0f;
                self.swipeReplyViewWidthConstraint.constant = 30.0f;
                [self.contentView layoutIfNeeded];
                self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
            }];
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
    self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleBackground];
    self.quoteView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleQuoteBackground];
    self.replyInnerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleQuoteBackground];
    self.replyDecorationView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleQuoteDecorationBackground];
    self.quoteDecorationView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleQuoteDecorationBackground];
    self.fileBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconQuotedFileBackgroundRight];
    
    UIFont *quoteTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleQuoteTitle];
    UIColor *quoteTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleQuoteTitle];
    
    UIFont *quoteContentFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleQuoteContent];
    UIColor *quoteContentColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleQuoteContent];
    
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleMessageBody];
    UIColor *bubbleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBody];
    
    UIFont *statusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMessageStatus];
    UIColor *statusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMessageStatus];

    UIFont *timestampLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleMessageTimestamp];
    UIColor *timestampLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageTimestamp];

    UIFont *imageTimestampLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMediaInfo];
    UIColor *imageTimestampLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMediaInfo];
    
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
    
    UIImage *abortImage = [UIImage imageNamed:@"TAPIconAbort" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    abortImage = [abortImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconCancelUploadDownloadWhite]];
    self.cancelImageView.image = abortImage;
    
    UIImage *sendingImage = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.sendingIconImageView.image = sendingImage;
    
    UIImage *documentsImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentsImage = [documentsImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFilePrimary]];
    self.fileImageView.image = documentsImage;
    
    UIImage *retryImage = [UIImage imageNamed:@"TAPIconRetry" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    retryImage = [retryImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileRetryUploadDownloadWhite]];
    self.retryImageView.image = retryImage;
    
    UIImage *downloadImage = [UIImage imageNamed:@"TAPIconDownload" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    downloadImage = [downloadImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileUploadDownloadWhite]];
    self.downloadImageView.image = downloadImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    if (message == nil) {
        return;
    }
    
//    _message = message;
    [super setMessage:message];
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];

    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    CGFloat timestampWidthWithMargin = 0.0f;
    if ([captionString isEqual:@""]) {
        timestampWidthWithMargin = CGRectGetWidth(self.imageTimestampStatusContainerView.frame) + (6.0f * 2);
        CGFloat radians = atan2f(self.transform.b, self.transform.a);
        NSInteger degrees = radians * (180 / M_PI);
        if(degrees == 0){
            timestampWidthWithMargin += 20.0f;
        }
    }
    else {
        CGSize timestampTextSize = [self.timestampLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        timestampWidthWithMargin = timestampTextSize.width + 4.0f + CGRectGetWidth(self.imageStatusIconImageView.frame) + 50.0f;
    }
    if (self.minWidth < timestampWidthWithMargin) {
        _minWidth = timestampWidthWithMargin;
    }
    
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
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        if([message.quote.content isEqualToString:@"🎤 Voice"]){
            [self showReplyView:YES withMessage:message];
            [self showQuoteView:NO];
        }
        else if((message.quote.fileID && ![message.quote.fileID isEqualToString:@""]) || (message.quote.imageURL  && ![message.quote.fileID isEqualToString:@""])) {
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
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote userID:@""];
        [self showQuoteView:YES];
    }
    else {
        
        if (self.isShowForwardView) {
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 0.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }
    
    UIImage *selectedImage = nil;
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];

    NSString *urlKey = [dataDictionary objectForKey:@"url"];
    if (urlKey == nil || [urlKey isEqualToString:@""]) {
        urlKey = [dataDictionary objectForKey:@"fileURL"];
    }
    urlKey = [TAPUtil nullToEmptyString:urlKey];
    if (![urlKey isEqualToString:@""]) {
        urlKey = [[urlKey componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
    
//    CGFloat obtainedCellWidth = [[message.data objectForKey:@"width"] floatValue];
//    CGFloat obtainedCellHeight = [[message.data objectForKey:@"height"] floatValue];
//    [self getResizedImageSizeWithHeight:obtainedCellHeight width:obtainedCellWidth];
//    self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
//    self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
    
    [self setSmallThumbnailFromMessageData:message.data];
    if ((fileID == nil || [fileID isEqualToString:@""]) && (urlKey == nil || [urlKey isEqualToString:@""])) {
        [TAPImageView imageFromCacheWithMessage:message
        success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
            if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
                (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
            ) {
                [self getImageSizeFromImage:savedImage];
                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
            }
            [self.bubbleImageView setImage:savedImage];
            [self.contentView layoutIfNeeded];
        }
        failure:^(NSError *error, TAPMessageModel *receivedMessage) {
            if (urlKey != nil && ![urlKey isEqualToString:@""]) {
                [self.bubbleImageView setImageWithURLString:[dataDictionary objectForKey:@"url"]];
                if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
                    (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
                ) {
                    if (self.bubbleImageViewWidthConstraint.constant == 0.0f) {
                        self.bubbleImageViewWidthConstraint.constant = 240.0f;
                    }
                    if (self.bubbleImageViewHeightConstraint.constant == 0.0f) {
                        self.bubbleImageViewHeightConstraint.constant = 240.0f;
                    }
                }
                [self.contentView layoutIfNeeded];
            }
            else {
                NSString *assetIdentifier = [dataDictionary objectForKey:@"assetIdentifier"];
                assetIdentifier = [TAPUtil nullToEmptyString:assetIdentifier];
                
                if (![assetIdentifier isEqualToString:@""]) {
                    NSArray<NSString *> *assetIdentifierArray = [NSArray arrayWithObject:assetIdentifier];
                    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:assetIdentifierArray options:nil];
                    PHAsset *imageAsset = [fetchResult firstObject];
                    if (imageAsset != nil) {
                        if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
                            (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
                        ) {
                            [self getImageSizeWithWidth:(CGFloat)imageAsset.pixelWidth
                                                 height:(CGFloat)imageAsset.pixelHeight];
                            self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
                            self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
                        }
                        
                        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                        requestOptions.synchronous = NO;
                        requestOptions.networkAccessAllowed = YES;
                        requestOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                        
                        PHImageManager *manager = [PHImageManager defaultManager];
                        [manager requestImageForAsset:imageAsset targetSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds)/2) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @autoreleasepool {
                                    NSError *error = [info objectForKey:PHImageErrorKey];
                                    if (!error && result != nil) {
                                        [self.bubbleImageView setImage:result];
                                        [self.contentView layoutIfNeeded];
                                    }
                                }
                            });
                        }];
                    }
                    else {
                        // Image data not found
                        if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
                            (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
                        ) {
                            self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
                            self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
                            [self.contentView layoutIfNeeded];
                        }
                    }
                }
                else {
                    // Image data not found
                    if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
                        (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
                    ) {
                        self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
                        self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
                        [self.contentView layoutIfNeeded];
                    }
                }
            }
        }];
    }
    else {
        if (self.currentFileKey == nil || ![self.currentFileKey isEqualToString:fileID] || ![self.currentFileKey isEqualToString:urlKey]) {
            // Cell is reused for different image, set image to nil first to prevent last image shown when load new image
            //self.bubbleImageView.image = nil;
            [self setSmallThumbnailFromMessageData:message.data];
        }

        //already called fetchImageDataWithMessage function in view controller for fetch image
        //so no need to set the image here
        //just save the height and width constraint
        
        if ((self.cellWidth == 0.0f && self.cellHeight == 0.0f) ||
            (self.cellWidth == self.maxWidth && self.cellHeight == self.maxHeight)
        ) {
            CGFloat obtainedCellWidth = [[message.data objectForKey:@"width"] floatValue];
            CGFloat obtainedCellHeight = [[message.data objectForKey:@"height"] floatValue];
            [self getResizedImageSizeWithHeight:obtainedCellHeight width:obtainedCellWidth];
            self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
            self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
        }
        [self.contentView layoutIfNeeded];

        if (![urlKey isEqualToString:@""]) {
            _currentFileKey = urlKey;
        }
        else if (![fileID isEqualToString:@""]) {
            _currentFileKey = fileID;
        }
    }
    
    if (self.cellWidth == 0.0f || self.cellHeight == 0.0f) {
        [self showStatusLabel:NO];
    }
    
    //remove animation
    [self.bubbleView.layer removeAllAnimations];
    [self.timestampLabel.layer removeAllAnimations];
    [self.quoteView.layer removeAllAnimations];
    [self.quoteDecorationView.layer removeAllAnimations];
    [self.replyView.layer removeAllAnimations];
    [self.replyDecorationView.layer removeAllAnimations];
    [self.replyNameLabel.layer removeAllAnimations];
    [self.replyMessageLabel.layer removeAllAnimations];
    [self.replyInnerView.layer removeAllAnimations];
    [self.statusIconImageView.layer removeAllAnimations];
    [self.forwardFromLabel.layer removeAllAnimations];
    [self.forwardTitleLabel.layer removeAllAnimations];
    [self.quoteImageView.layer removeAllAnimations];
    [self.bubbleImageView.layer removeAllAnimations];
    [self.thumbnailBubbleImageView.layer removeAllAnimations];
    [self.captionLabel.layer removeAllAnimations];
    [self.imageTimestampStatusContainerView.layer removeAllAnimations];
    [self.imageTimestampLabel.layer removeAllAnimations];
    [self.checkMarkIconImageView.layer removeAllAnimations];
    [self.imageStatusIconImageView.layer removeAllAnimations];
}

- (void)setSmallThumbnailFromMessageData:(NSDictionary *)messageDataDictionary {
    NSString *thumbnailImageBase64String = [messageDataDictionary objectForKey:@"thumbnail"];
    thumbnailImageBase64String = [TAPUtil nullToEmptyString:thumbnailImageBase64String];
    if ([thumbnailImageBase64String isEqualToString:@""]) {
        return;
    }
    NSData *thumbnailImageData = [[NSData alloc] initWithBase64EncodedString:thumbnailImageBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:thumbnailImageData];
    if (image != nil) {
        self.bubbleImageView.image = image;
        [self getImageSizeFromImage:image];
        [self.contentView layoutIfNeeded];
    }
}

- (void)editMessage:(TAPMessageModel *)message {
    if (message == nil) {
        return;
    }
    
//    _message = message;
    [super setMessage:message];
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];

    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    CGFloat timestampWidthWithMargin = 0.0f;
    if ([captionString isEqual:@""]) {
        timestampWidthWithMargin = CGRectGetWidth(self.imageTimestampStatusContainerView.frame) + (6.0f * 2);
    }
    else {
        CGSize timestampTextSize = [self.timestampLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        timestampWidthWithMargin = timestampTextSize.width + 4.0f + CGRectGetWidth(self.imageStatusIconImageView.frame) + 50.0f;
    }
    if (self.minWidth < timestampWidthWithMargin) {
        _minWidth = timestampWidthWithMargin;
    }
    
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
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        if([message.quote.content isEqualToString:@"🎤 Voice"]){
            [self showReplyView:YES withMessage:message];
            [self showQuoteView:NO];
        }
        else if((message.quote.fileID && ![message.quote.fileID isEqualToString:@""]) || (message.quote.imageURL  && ![message.quote.fileID isEqualToString:@""])) {
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
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote userID:@""];
        [self showQuoteView:YES];
    }
    else {
        
        if (self.isShowForwardView) {
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 0.0f;
        }
        [self.contentView layoutIfNeeded];
        
        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }
    
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

- (void)showStatusLabel:(BOOL)show {
//    if (show) {
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
//                NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
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
//        if (self.message.isFailedSend) {
//            NSString *failedStatusString = NSLocalizedStringFromTableInBundle(@"Failed to send, tap to retry", nil, [TAPUtil currentBundle], @"");
//            self.statusLabel.text = failedStatusString;
//        }
//
//        self.statusLabel.alpha = 1.0f;
//        self.statusLabelTopConstraint.constant = 2.0f;
//        self.statusLabelHeightConstraint.constant = 13.0f;
//        self.replyButtonRightConstraint.constant = 2.0f;
//
//        if (self.message.isFailedSend) {
//            self.statusIconImageView.alpha = 0.0f;
//            self.replyButton.alpha = 0.0f;
//        }
//        else {
//            self.statusIconImageView.alpha = 1.0f;
//            self.replyButton.alpha = 1.0f;
//        }
//
//        [self.contentView layoutIfNeeded];
//    }
//    else {
//        self.statusLabel.alpha = 0.0f;
//        self.statusLabelTopConstraint.constant = 0.0f;
//        self.statusLabelHeightConstraint.constant = 0.0f;
//        self.replyButton.alpha = 0.0f;
//        self.replyButtonRightConstraint.constant = -28.0f;
//        self.statusIconImageView.alpha = 1.0f;
//        [self.contentView layoutIfNeeded];
//    }
}

//- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message {
//    [super showStatusLabel:isShowed animated:animated updateStatusIcon:updateStatusIcon message:message];
//    if (!self.message.isFailedSend) {
//        self.statusIconImageView.alpha = 1.0f;
//    }
//    else {
//        self.statusIconImageView.alpha = 0.0f;
//    }
//}

- (IBAction)replyButtonDidTapped:(id)sender {
    [super replyButtonDidTapped:sender];
    
    if ([self.delegate respondsToSelector:@selector(myImageReplyDidTappedWithMessage:)]) {
        [self.delegate myImageReplyDidTappedWithMessage:self.message];
    }
}

- (IBAction)cancelButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myImageCancelDidTappedWithMessage:)]) {
        [self.delegate myImageCancelDidTappedWithMessage:self.message];
    }
}

- (IBAction)retryButtonDidTapped:(id)sender  {
    if ([self.delegate respondsToSelector:@selector(myImageRetryDidTappedWithMessage:)]) {
        [self.delegate myImageRetryDidTappedWithMessage:self.message];
    }
}

- (IBAction)openImageButtonDidTapped:(id)sender  {
    if ([self.delegate respondsToSelector:@selector(myImageDidTapped:)]) {
        [self.delegate myImageDidTapped:self];
    }
}

- (void)getImageSizeFromImage:(UIImage *)image {
    if (image == nil) {
        _cellWidth = self.maxWidth;
        _cellHeight = self.maxHeight;
        return;
    }
    [self getImageSizeWithWidth:image.size.width height:image.size.height];
}

- (void)getImageSizeWithWidth:(CGFloat)width height:(CGFloat)height {
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
    
    CGFloat resizedWidth = width;
    CGFloat resizedHeight = height;
    
    _cellWidth = resizedWidth;
    _cellHeight = resizedHeight;
    
    if (resizedWidth > resizedHeight) {
        if (resizedWidth > self.maxWidth) {
            resizedWidth = self.maxWidth;
            _cellWidth = resizedWidth;
            
            resizedHeight = (resizedWidth / width) * height;
            _cellHeight = resizedHeight;
            if (resizedHeight > self.maxHeight) {
                resizedHeight = self.maxHeight;
                _cellHeight = resizedHeight;
            }
            else if (resizedHeight < self.minHeight) {
                resizedHeight = self.minHeight;
                _cellHeight = resizedHeight;
            }
        }
        else if (resizedWidth < self.minWidth) {
            resizedWidth = self.minWidth;
            _cellWidth = resizedWidth;
            
            resizedHeight = (resizedWidth / width) * height;
            _cellHeight = resizedHeight;
            if (resizedHeight > self.maxHeight) {
                resizedHeight = self.maxHeight;
                _cellHeight = resizedHeight;
            }
            else if (resizedHeight < self.minHeight) {
                resizedHeight = self.minHeight;
                _cellHeight = resizedHeight;
            }
        }
    }
    else {
        if (resizedHeight > self.maxHeight) {
            resizedHeight = self.maxHeight;
            _cellHeight = resizedHeight;
            
            resizedWidth = (resizedHeight / height) * width;
            _cellWidth = resizedWidth;
            if (resizedWidth > self.maxWidth) {
                resizedWidth = self.maxWidth;
                _cellWidth = resizedWidth;
            }
            else if (resizedWidth < self.minWidth) {
                resizedWidth = self.minWidth;
                _cellWidth = resizedWidth;
            }
        }
        else if (resizedHeight < self.minHeight) {
            resizedHeight = self.minHeight;
            _cellHeight = resizedHeight;
            
//            imageWidth = (imageHeight / image.size.height) * image.size.width;
            _cellWidth = resizedWidth;
            if (resizedWidth > self.maxWidth) {
                resizedWidth = self.maxWidth;
                _cellWidth = resizedWidth;
            }
            else if (resizedWidth < self.minWidth) {
                resizedWidth = self.minWidth;
                _cellWidth = resizedWidth;
            }
        }
    }
}

- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width {
    if (height == 0.0f && width == 0.0f) {
        _cellWidth = self.maxWidth;
        _cellHeight = self.maxWidth;
        return;
    }
    
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
        self.openImageButton.alpha = 1.0f;
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
    
    [self setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeFailed];
}

- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total {
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

- (void)showProgressUploadView:(BOOL)show {
    if (show) {
        self.progressBackgroundView.alpha = 1.0f;
    }
    else {
        self.progressBackgroundView.alpha = 0.0f;
    }
}

- (void)setInitialAnimateUploadingImageWithType:(TAPMyImageBubbleTableViewCellStateType)type {
    
    switch (type) {
        case TAPMyImageBubbleTableViewCellStateTypeUploading:
        {
            self.cancelImageView.alpha = 1.0f;
            self.cancelButton.alpha = 1.0f;
            self.cancelButton.userInteractionEnabled = YES;
            
            self.downloadImageView.alpha = 0.0f;
            
            self.retryImageView.alpha = 0.0f;
            self.retryButton.alpha = 0.0f;
            self.retryButton.userInteractionEnabled = NO;
            break;
        }
        case TAPMyImageBubbleTableViewCellStateTypeDownloading:
        {
            self.cancelImageView.alpha = 0.0f;
            self.cancelButton.alpha = 0.0f;
            self.cancelButton.userInteractionEnabled = NO;
            
            self.downloadImageView.alpha = 1.0f;
            
            self.retryImageView.alpha = 0.0f;
            self.retryButton.alpha = 0.0f;
            self.retryButton.userInteractionEnabled = NO;
            break;
        }
        case TAPMyImageBubbleTableViewCellStateTypeFailed:
        {
            self.cancelImageView.alpha = 0.0f;
            self.cancelButton.alpha = 0.0f;
            self.cancelButton.userInteractionEnabled = NO;
            
            self.downloadImageView.alpha = 0.0f;
            
            self.retryImageView.alpha = 1.0f;
            self.retryButton.alpha = 1.0f;
            self.retryButton.userInteractionEnabled = YES;
            break;
        }
        default:
        {
            break;
        }
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

- (void)showImageCaption:(BOOL)show {
    if (show) {
        self.captionLabelTopConstraint.constant = 4.0f;
        self.captionLabelBottomConstraint.constant = 2.0f;
        self.timestampLabelHeightConstraint.constant = 16.0f;
        self.statusIconImageViewHeightConstraint.constant = 16.0f;
        
        self.timestampLabel.alpha = 1.0f;
        self.imageStatusIconImageView.alpha = 1.0f;
        self.imageTimestampStatusContainerView.alpha = 0.0f;
        
        CGSize captionLabelSize = [self.captionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.captionLabel.bounds), CGFLOAT_MAX)];
        self.captionLabelHeightConstraint.constant = captionLabelSize.height;
    }
    else {
        self.captionLabelTopConstraint.constant = 0.0f;
        self.captionLabelBottomConstraint.constant = 0.0f;
        self.captionLabelHeightConstraint.constant = 0.0f;
        self.timestampLabelHeightConstraint.constant = 0.0f;
        self.statusIconImageViewHeightConstraint.constant = 0.0f;
        
        self.timestampLabel.alpha = 0.0f;
        self.imageStatusIconImageView.alpha = 0.0f;
        self.imageTimestampStatusContainerView.alpha = 1.0f;
        self.starIconBottomImageView.alpha = 0.0f;
        
        if(self.message.isMessageEdited){
            NSString *editedMessageString = [NSString stringWithFormat:@"Edited • %@", [TAPUtil getMessageTimestampText:self.message.created]];
            self.imageTimestampLabel.text = editedMessageString;
        }
        else{
            self.imageTimestampLabel.text = [TAPUtil getMessageTimestampText:self.message.created];
        }
        
        [self setInnerImageStatusIcon];
    }
    [self.contentView layoutIfNeeded];
}

- (void)setImageCaptionWithString:(NSString *)captionString {
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    self.captionLabel.text = captionString;
    
    if([captionString isEqualToString:@""]) {
        [self showImageCaption:NO];
        return;
    }
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    NSDataDetector *detectorPhoneNumber = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL];
    
    UIColor *highlightedTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBodyURLHighlighted];
    UIColor *defaultTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBodyURL];
    
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

- (void)setInnerImageStatusIcon {
    if (self.message.isFailedSend) {
        // Set to failed icon
        self.imageStatusIconImageView.image = [UIImage imageNamed:@"TAPIconFailed" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.imageStatusIconImageView.image = [self.imageStatusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageDeliveredImage]];
        self.imageStatusIconImageView.alpha = 1.0f;
    }
    else if (self.message.isRead) {
        // Check if show read status
        BOOL isHideReadStatus = [[TapUI sharedInstance] getReadStatusHiddenState];
        if (isHideReadStatus) {
            // Set to delivered icon
            self.imageStatusIconImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.imageStatusIconImageView.image = [self.imageStatusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageDeliveredImage]];
        }
        else {
            // Set to read icon
            self.imageStatusIconImageView.image = [UIImage imageNamed:@"TAPIconRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.imageStatusIconImageView.image = [self.imageStatusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageRead]];
        }
        self.imageStatusIconImageView.alpha = 1.0f;
    }
    else if (self.message.isDelivered) {
        self.imageStatusIconImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.imageStatusIconImageView.image = [self.imageStatusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageDeliveredImage]];
        self.imageStatusIconImageView.alpha = 1.0f;
    }
    else if (!self.message.isSending) {
        self.imageStatusIconImageView.image = [UIImage imageNamed:@"TAPIconSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.imageStatusIconImageView.image = [self.imageStatusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageSentImage]];
        self.imageStatusIconImageView.alpha = 1.0f;
    }
    else {
        self.imageStatusIconImageView.alpha = 0.0f;
    }
}

- (void)setFullImage:(UIImage *_Nullable)image {
    if (image == nil) {
        return;
    }
    
    [self getImageSizeFromImage:image];
    self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
    self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
    [self.bubbleImageView setImage:image];
    [self.contentView layoutIfNeeded];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    if (thumbnailImage == nil) {
        return;
    }

    self.thumbnailBubbleImageView.image = thumbnailImage;
}

- (void)setMyImageBubbleTableViewCellStateType:(TAPMyImageBubbleTableViewCellStateType)myImageBubbleTableViewCellStateType {
    _myImageBubbleTableViewCellStateType = myImageBubbleTableViewCellStateType;
}

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message {
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
        self.replyViewTopConstraint.constant = 0.0f;
        
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
    
    UIFont *quoteTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleQuoteTitle];
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

- (IBAction)forwardCheckmarkButtonDiTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myImageCheckmarkDidTappedWithMessage:)]) {
        [self.delegate myImageCheckmarkDidTappedWithMessage:self.message];
    }
}


- (IBAction)quoteViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myImageQuoteDidTappedWithMessage:)]) {
        [self.delegate myImageQuoteDidTappedWithMessage:self.message];
    }
}

- (IBAction)replyViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myImageQuoteDidTappedWithMessage:)]) {
        [self.delegate myImageQuoteDidTappedWithMessage:self.message];
    }
}

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(myImageBubbleLongPressedWithMessage:)]) {
            [self.delegate myImageBubbleLongPressedWithMessage:self.message];
        }
    }
}

- (void)showBubbleHighlight {
    self.bubbleHighlightView.alpha = 0.0f;
    [TAPUtil performBlock:^{
        [UIView animateWithDuration:0.2f animations:^{
            self.bubbleHighlightView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [TAPUtil performBlock:^{
                [UIView animateWithDuration:0.75f animations:^{
                    self.bubbleHighlightView.alpha = 0.0f;
                }];
            } afterDelay:1.0f];
        }];
    } afterDelay:0.2f];
}

- (void)showStarMessageView {
    if(self.starIconImageView.alpha == 0){
        
        self.starIconImageView.alpha = 1.0f;
        self.starImageViewWidthConstarint.constant = 12.0f;
        self.starImageViewLeadingConstarint.constant = 8.0f;
        
        if(self.imageTimestampStatusContainerView.alpha == 0){
            self.starIconBottomImageView.alpha = 1.0f;
        }
        
        
    }
    else{
        self.starIconImageView.alpha = 0.0f;
        self.starIconBottomImageView.alpha = 0.0f;
        self.starImageViewWidthConstarint.constant = 0.0f;
        self.starImageViewLeadingConstarint.constant = 4.0f;
    }
}

- (void)showCheckMarkIcon:(BOOL)isShow {
    if(isShow){
        self.checkMarkIconImageView.alpha = 1.0f;
        self.bubbleViewLongPressGestureRecognizer.enabled = NO;
        self.forwardCheckmarkButton.alpha = 1.0f;
    }
    else{
        self.checkMarkIconImageView.alpha = 0.0f;
        self.bubbleViewLongPressGestureRecognizer.enabled = YES;
        self.forwardCheckmarkButton.alpha = 0.0f;
    }
}

- (void)setCheckMarkState:(BOOL)isSelected {
    if(isSelected){
        self.checkMarkIconImageView.image = [UIImage imageNamed:@"TAPIconSelected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else{
        self.checkMarkIconImageView.image = [UIImage imageNamed:@"TAPIconUnselected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
    }
}

- (void)setSwipeGestureEnable:(BOOL)enable {
    self.panGestureRecognizer.enabled = enable;
}

- (void)showSeperatorView {
    self.seperatorViewTopConstraint.constant = 16.0f;
    self.seperatorViewBottomConstraint.constant = 13.0f;
    self.seperatorViewConstraintHeight.constant = 1.0f;
    
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
}

@end

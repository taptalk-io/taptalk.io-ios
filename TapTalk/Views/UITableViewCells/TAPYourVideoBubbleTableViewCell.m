//
//  TAPYourVideoBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPYourVideoBubbleTableViewCell.h"
#import "ZSWTappableLabel.h"

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

@interface TAPYourVideoBubbleTableViewCell () <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIGestureRecognizerDelegate, TAPImageViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyInnerView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UIView *replyDecorationView;
@property (strong, nonatomic) IBOutlet UIView *quoteDecorationView;
@property (strong, nonatomic) IBOutlet UIView *fileBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *imageTimestampContainerView;
@property (strong, nonatomic) IBOutlet UIView *bubbleHighlightView;
@property (strong, nonatomic) IBOutlet UIImageView *fileImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet ZSWTappableLabel *captionLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *imageTimestampLabel;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;

@property (strong, nonatomic) IBOutlet UIView *cancelView;
@property (strong, nonatomic) IBOutlet UIView *downloadView;
@property (strong, nonatomic) IBOutlet UIView *doneDownloadView;
@property (strong, nonatomic) IBOutlet UIView *retryDownloadView;
@property (strong, nonatomic) IBOutlet UIImageView *cancelImageView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *doneDownloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retryDownloadImageView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *downloadFileButton;
@property (strong, nonatomic) IBOutlet UIButton *doneDownloadButton;
@property (strong, nonatomic) IBOutlet UIButton *retryDownloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *starIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *starIconBottomImageView;

@property (strong, nonatomic) IBOutlet UIView *videoDurationAndSizeView;
@property (strong, nonatomic) IBOutlet UILabel *videoDurationAndSizeLabel;

@property (strong, nonatomic) IBOutlet UIView *senderInitialView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialLabel;
@property (strong, nonatomic) IBOutlet UIButton *senderProfileImageButton;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *forwardCheckmarkButton;
@property (weak, nonatomic) IBOutlet UIImageView *senderDeletedUserImageView;
@property (weak, nonatomic) IBOutlet UIButton *redirectArrowButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pinIconBottomImageView;

@property (weak, nonatomic) IBOutlet UILabel *messageReadCounterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageReadCounterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageReadCounterBoxImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageReadCounterBoxLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewLeadingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinIconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinIconBottomWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageReadCounterImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageReadCounterBoxImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starIconWidthConstraint;

@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *bubbleViewTapGestureRecognizer;

@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;
@property (nonatomic) BOOL isShowForwardView;
@property (nonatomic) BOOL isShowSenderInfoView;
@property (nonatomic) BOOL isShowQuoteView;
@property (nonatomic) BOOL isShowReplyView;

@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;

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

@property (strong, nonatomic) NSString *currentProfileImageURLString;

- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showVideoCaption:(BOOL)show;
- (void)setVideoCaptionWithString:(NSString *)captionString;
- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)showStatusLabel:(BOOL)show;
- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;

- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setBubbleCellStyle;
- (void)showSenderInfo:(BOOL)show;
- (void)updateSpacingConstraint;

- (IBAction)downloadButtonDidTapped:(id)sender;
- (IBAction)playVideoButtonDidTapped:(id)sender;
- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)cancelButtonDidTapped:(id)sender;
- (IBAction)retryDownloadButtonDidTapped:(id)sender;
- (IBAction)quoteViewButtonDidTapped:(id)sender;
- (IBAction)replyViewButtonDidTapped:(id)sender;
- (IBAction)senderProfileImageButtonDidTapped:(id)sender;
//- (IBAction)retryButtonDidTapped:(id)sender;

@end

@implementation TAPYourVideoBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
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
    _minWidth = (self.maxWidth / 3.0f); //one third of max Width
    _minHeight = self.minWidth / 78.0f * 100.0f; //78.0f and 100.0f are width and height constraint on design
    
    self.pinIconBottomImageView.image = [self.pinIconBottomImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPinBackground]];
    self.pinIconImageView.image = [self.pinIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPinBackground]];
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleHighlightView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatBubbleHighlightBackgroundColor];
    
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.videoDurationAndSizeView.layer.cornerRadius = 8.0f;
    self.videoDurationAndSizeView.clipsToBounds = YES;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    self.imageTimestampContainerView.layer.cornerRadius = 10.0f;
    self.imageTimestampContainerView.clipsToBounds = YES;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    
    self.bubbleImageView.layer.cornerRadius = 12.0f;
    self.bubbleImageView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleImageView.clipsToBounds = YES;
    self.bubbleImageView.layer.masksToBounds = YES;
    
    self.replyView.layer.cornerRadius = 4.0f;
    self.replyView.clipsToBounds = YES;
    
    self.quoteView.layer.cornerRadius = 8.0f;
    self.quoteView.clipsToBounds = YES;
    
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.delegate = self;
    
    self.fileBackgroundView.layer.cornerRadius = 24.0f;
    
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    
    self.starIconImageView.alpha = 0.0f;
    self.starIconBottomImageView.alpha = 0.0f;
    
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
    
    _bubbleViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleBubbleViewLongPress:)];
    self.bubbleViewLongPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.bubbleView addGestureRecognizer:self.bubbleViewLongPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    self.panGestureRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
    
    _bubbleViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleBubbleViewTap:)];
    [self.contentView addGestureRecognizer:self.bubbleViewTapGestureRecognizer];
    
    self.captionLabel.tapDelegate = self;
    self.captionLabel.longPressDelegate = self;
    self.captionLabel.longPressDuration = 0.05f;
    
    self.senderImageView.clipsToBounds = YES;
    self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame)/2.0f;
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    _mentionIndexesArray = [[NSArray alloc] init];
    
    [self setBubbleCellStyle];
    [self showSenderInfo:NO];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.bubbleImageView.image = nil;
    
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    
    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    self.starImageViewLeadingConstraint.constant = 4.0f;
    self.starImageViewWidthConstraint.constant = 0.0f;
    
    [self showSenderInfo:NO];
    [self showForwardView:NO];
    [self showReplyView:NO withMessage:nil];
    [self showQuoteView:NO];
    [self setVideoCaptionWithString:@""];
    
    self.mentionIndexesArray = nil;
    
    self.statusLabel.text = @"";
    
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    self.starIconImageView.alpha = 0.0f;
    self.starIconBottomImageView.alpha = 0.0f;
    self.checkMarkIconImageView.alpha = 0.0f;
    self.forwardCheckmarkButton.alpha = 0.0f;
    self.senderDeletedUserImageView.alpha = 0.0f;
    self.senderImageViewLeadingConstraint.constant = 16.0f;
    self.redirectArrowButton.alpha = 0.0f;
    self.bubbleHighlightView.alpha = 0.0f;
    
    self.pinIconImageView.alpha = 0.0f;
    self.pinIconBottomImageView.alpha = 0.0f;
    self.pinIconWidthConstraint.constant = 0.0f;
    self.pinIconBottomWidthConstraint.constant = 0.0f;
    [self showMessageReadCounterWithNumber:NO readCount:0];
    
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
                if([self.delegate respondsToSelector:@selector(yourVideoDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate yourVideoDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourVideoDidTappedUrl:originalString:)]) {
                    [self.delegate yourVideoDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourVideoBubblePressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourVideoBubblePressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
                if([self.delegate respondsToSelector:@selector(yourVideoLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate yourVideoLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourVideoLongPressedUrl:originalString:)]) {
                    [self.delegate yourVideoLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourVideoBubbleLongPressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourVideoBubbleLongPressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
            self.redirectArrowButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.replyButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.statusLabel.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.swipeReplyView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            
            self.swipeReplyView.alpha = translation.x / 50.0f;
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x > 50.0f) {
                if ([self.delegate respondsToSelector:@selector(yourVideoBubbleDidTriggerSwipeToReplyWithMessage:)]) {
                    [self.delegate yourVideoBubbleDidTriggerSwipeToReplyWithMessage:self.message];
                }
            }
            
            _disableTriggerHapticFeedbackOnDrag = NO;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.senderImageView.transform = CGAffineTransformIdentity;
                self.senderInitialView.transform = CGAffineTransformIdentity;
                self.senderProfileImageButton.transform = CGAffineTransformIdentity;
                self.redirectArrowButton.transform = CGAffineTransformIdentity;
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
                self.redirectArrowButton.transform = CGAffineTransformIdentity;
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

#pragma mark - TAPImageViewDelegate

- (void)imageViewDidFinishLoadImage:(TAPImageView *)imageView {
    if (imageView == self.quoteImageView) {
        if (imageView.image == nil) {
            if (![TAPUtil isEmptyString:self.message.quote.fileType] && [self.message.quote.fileType isEqualToString:@"video"]) {
                    [TAPImageView imageFromCacheWithMessage:self.message
                    start:^(TAPMessageModel *resultMessage) {
                        
                    }
                    progress:^(CGFloat progress, CGFloat total, TAPMessageModel *resultMessage) {
                        
                    }
                    success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                        if (savedImage != nil) {
                            [self.quoteImageView setImage:savedImage];
                            [self showReplyView:NO withMessage:nil];
                            [self showQuoteView:YES];
                        }
                    }
                    failure:^(NSError *error, TAPMessageModel *resultMessage) {
                        [self showQuoteView:NO];
                        [self showReplyView:YES withMessage:self.message];
                    }];
            }
            else {
                [self showQuoteView:NO];
                [self showReplyView:YES withMessage:self.message];
            }
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
    self.forwardTitleLabel.font = quoteTitleFont;
    
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
    
    UIImage *abortImage = [UIImage imageNamed:@"TAPIconAbort" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    abortImage = [abortImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconCancelUploadDownloadWhite]];
    self.cancelImageView.image = abortImage;
    
    UIImage *retryImage = [UIImage imageNamed:@"TAPIconRetry" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    retryImage = [retryImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileRetryUploadDownloadWhite]];
    self.retryDownloadImageView.image = retryImage;
    
    UIImage *downloadImage = [UIImage imageNamed:@"TAPIconDownload" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    downloadImage = [downloadImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileUploadDownloadWhite]];
    self.downloadImageView.image = downloadImage;
    
    UIImage *doneDownloadImage = [UIImage imageNamed:@"TAPIconPlayWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    doneDownloadImage = [doneDownloadImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFilePlayMedia]];
    self.doneDownloadImageView.image = doneDownloadImage;
    
    UIImage *documentsImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentsImage = [documentsImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileWhite]];
    self.fileImageView.image = documentsImage;
    
    self.messageReadCounterLabel.textColor = timestampLabelColor;
    self.messageReadCounterLabel.font = timestampLabelFont;

    self.messageReadCounterBoxLabel.textColor = imageTimestampLabelColor;
    self.messageReadCounterBoxLabel.font = imageTimestampLabelFont;
    
    self.messageReadCounterImageView.image = [ self.messageReadCounterImageView.image setImageTintColor:[TAPUtil getColor:@"DADADA"]];
    
}

- (void)setMessage:(TAPMessageModel *)message {
    if (message == nil) {
        return;
    }
    
    _message = message;
    
    BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:message.room.roomID];
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];

    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];

    [self setVideoCaptionWithString:captionString];
    
    CGFloat timestampWidthWithMargin = 0.0f;
    if ([captionString isEqual:@""]) {
        [self.imageTimestampContainerView layoutIfNeeded];
        timestampWidthWithMargin = CGRectGetWidth(self.imageTimestampContainerView.frame) + (6.0f * 2);
    }
    else {
        [self.bubbleView layoutIfNeeded];
        CGSize timestampTextSize = [self.timestampLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        timestampWidthWithMargin = timestampTextSize.width  + 50.0f;
    }
    if (self.minWidth < timestampWidthWithMargin) {
        _minWidth = timestampWidthWithMargin;
    }

    if (![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil && !isSavedMessageRoom) {
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
        
        if ((![TAPUtil isEmptyString:message.quote.fileType] &&
             ([message.quote.fileType isEqualToString:@"image"] ||
             [message.quote.fileType isEqualToString:@"video"] ||
             [message.quote.fileType isEqualToString:@"file"])) ||
            ![TAPUtil isEmptyString:message.quote.imageURL]
        ) {
            if ([message.quote.fileType isEqualToString:@"video"]) {
                [self showReplyView:YES withMessage:message];
                [self showQuoteView:NO];
            }
            else {
                [self showReplyView:NO withMessage:nil];
                [self showQuoteView:YES];
            }
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

        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote userID:@""];
        [self showQuoteView:YES];
    }
    else {
        if (self.isShowForwardView) {
            self.senderNameTopConstraint.constant = 10.0f;
        }
        else {
            self.senderNameTopConstraint.constant = 0.0f;
        }

        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }


    CGFloat imageTempHeight = [[dataDictionary objectForKey:@"height"] floatValue];
    CGFloat imageTempWidth = [[dataDictionary objectForKey:@"width"] floatValue];

//    if (imageTempWidth == 0.0f && imageTempHeight == 0.0f) {
//        self.bubbleImageViewWidthConstraint.constant = 0.0f;
//        self.bubbleImageViewHeightConstraint.constant = 0.0f;
//    }
//    else {
        [self getResizedImageSizeWithHeight:imageTempHeight width:imageTempWidth];

        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
        
        [self layoutIfNeeded];
//    }

    [self setThumbnailImageForVideoWithMessage:message];
    
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
        
        if(message.user.deleted.longValue > 0){
            //set deleted account profil pict
            self.senderInitialView.alpha = 1.0f;
            self.senderImageView.alpha = 0.0f;
            self.senderDeletedUserImageView.alpha = 1.0f;
            self.senderInitialView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
            self.senderInitialLabel.text =@"";
        }
        else if ([thumbnailImageString isEqualToString:@""]) {
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
    else if(isSavedMessageRoom && (![message.forwardFrom.localID isEqualToString:@""] || message.forwardFrom != nil)){
        [self showSenderInfo:YES];
        
        if(self.seperatorViewHeight.constant == 0){
            self.redirectArrowButton.alpha = 1.0f;
        }
        
        NSString *thumbnailImageString = @"";
        
        NSString *fullNameString = message.forwardFrom.fullname;
        
        self.senderNameLabel.text = fullNameString;
        
        NSString *userID = message.forwardFrom.userID;
        
        TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:userID];
        
        if(obtainedUser == nil) {
            [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
                NSString *thumbnailImageString = @"";
                thumbnailImageString = user.imageURL.thumbnail;
                thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
                
                if(message.user.deleted.longValue > 0 || user.deleted.longValue > 0){
                    //set deleted account profil pict
                    self.senderInitialView.alpha = 1.0f;
                    self.senderImageView.alpha = 0.0f;
                    self.senderDeletedUserImageView.alpha = 1.0f;
                    self.senderInitialView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
                    self.senderInitialLabel.text =@"";
                    self.senderNameLabel.text = @"Deleted User";
                }
                else if ([thumbnailImageString isEqualToString:@""]) {
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
                
            } failure:^(NSError *error) {
                
            }];
        }
        else {
            thumbnailImageString = obtainedUser.imageURL.thumbnail;
            thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
            
            if(message.user.deleted.longValue > 0 || obtainedUser.deleted.longValue > 0){
                //set deleted account profil pict
                self.senderInitialView.alpha = 1.0f;
                self.senderImageView.alpha = 0.0f;
                self.senderDeletedUserImageView.alpha = 1.0f;
                self.senderInitialView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
                self.senderInitialLabel.text =@"";
                self.senderNameLabel.text = @"Deleted User";
            }
            else if ([thumbnailImageString isEqualToString:@""]) {
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
        }
        
    }
    else {
        [self showSenderInfo:NO];
        self.senderImageView.image = nil;
        self.senderNameLabel.text = @"";
    }
    
    if(message.isMessageEdited){
        NSString *editedMessageString = [NSString stringWithFormat:@"Edited • %@", [TAPUtil getMessageTimestampText:self.message.created]];
        self.timestampLabel.text = editedMessageString;
    }
    else{
        self.timestampLabel.text = [TAPUtil getMessageTimestampText:self.message.created];
    }
    
    //CS NOTE - Update Spacing should be placed at the bottom
    [self updateSpacingConstraint];
    
    //remove animation
    [self.redirectArrowButton.layer removeAllAnimations];
    [self.senderDeletedUserImageView.layer removeAllAnimations];
    [self.senderInitialView.layer removeAllAnimations];
    [self.bubbleView.layer removeAllAnimations];
    [self.pinIconImageView.layer removeAllAnimations];
    [self.pinIconBottomImageView.layer removeAllAnimations];
    [self.timestampLabel.layer removeAllAnimations];
    [self.quoteView.layer removeAllAnimations];
    [self.quoteDecorationView.layer removeAllAnimations];
    [self.replyView.layer removeAllAnimations];
    [self.replyDecorationView.layer removeAllAnimations];
    [self.replyNameLabel.layer removeAllAnimations];
    [self.replyMessageLabel.layer removeAllAnimations];
    [self.replyInnerView.layer removeAllAnimations];
    [self.forwardFromLabel.layer removeAllAnimations];
    [self.forwardTitleLabel.layer removeAllAnimations];
    [self.senderNameLabel.layer removeAllAnimations];
    [self.senderImageView.layer removeAllAnimations];
    [self.quoteImageView.layer removeAllAnimations];
    [self.imageTimestampContainerView.layer removeAllAnimations];
    [self.imageTimestampLabel.layer removeAllAnimations];
    [self.checkMarkIconImageView.layer removeAllAnimations];
    
    [self.contentView layoutIfNeeded];
}

- (IBAction)forwardCheckmarkButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoCheckmarkDidTappedWithMessage:)]) {
        [self.delegate yourVideoCheckmarkDidTappedWithMessage:self.message];
    }
}

- (IBAction)senderProfileImageButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoBubbleDidTappedProfilePictureWithMessage:)]) {
        [self.delegate yourVideoBubbleDidTappedProfilePictureWithMessage:self.message];
    }
}

- (IBAction)redirectArrowButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoBubbleDidTappedRedirectArrowWithMessage:)]) {
        [self.delegate yourVideoBubbleDidTappedRedirectArrowWithMessage:self.message];
    }
}

- (IBAction)downloadButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoDownloadButtonDidTapped:)]) {
        [self.delegate yourVideoDownloadButtonDidTapped:self.message];
    }
}

- (IBAction)playVideoButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoPlayDidTappedWithMessage:)]) {
        [self.delegate yourVideoPlayDidTappedWithMessage:self.message];
    }
}

- (IBAction)replyButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoReplyDidTappedWithMessage:)]) {
        [self.delegate yourVideoReplyDidTappedWithMessage:self.message];
    }
}

- (IBAction)cancelButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoCancelDidTappedWithMessage:)]) {
        [self.delegate yourVideoCancelDidTappedWithMessage:self.message];
    }
}

- (IBAction)retryDownloadButtonDidTapped:(id)sender  {
    if ([self.delegate respondsToSelector:@selector(yourVideoRetryDownloadButtonDidTapped:)]) {
        [self.delegate yourVideoRetryDownloadButtonDidTapped:self.message];
    }
}

- (IBAction)quoteViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoQuoteDidTappedWithMessage:)]) {
        [self.delegate yourVideoQuoteDidTappedWithMessage:self.message];
    }
}

- (IBAction)replyViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourVideoReplyDidTappedWithMessage:)]) {
        [self.delegate yourVideoQuoteDidTappedWithMessage:self.message];
    }
}

//- (IBAction)retryButtonDidTapped:(id)sender {
//    [super retryButtonDidTapped:sender];
//    if ([self.delegate respondsToSelector:@selector(myVideoRetryUploadDownloadButtonDidTapped:)]) {
//        [self.delegate myVideoRetryUploadDownloadButtonDidTapped:self.message];
//    }
//}

- (void)getImageSizeFromImage:(UIImage *)image {
    if (image == nil) {
        _cellWidth = self.maxWidth;
        _cellHeight = self.maxWidth;
        return;
    }
    
    [self getResizedImageSizeWithHeight:image.size.height width:image.size.width];
    
//    if ((![self.message.replyTo.messageID isEqualToString:@"0"] && ![self.message.replyTo.messageID isEqualToString:@""] && self.message.replyTo != nil) || (![self.message.quote.title isEqualToString:@""] && self.message.quote != nil)) {
//        //if replyTo or quote exists set image width and height to default width = maxWidth height = 244.0f
//        _cellWidth = self.maxWidth;
//        _cellHeight = self.cellWidth / image.size.width * image.size.height;
//        if (self.cellHeight > self.maxHeight) {
//            _cellHeight = self.maxHeight;
//        }
//        else if (self.cellHeight < self.minHeight) {
//            _cellHeight = self.minHeight;
//        }
//        return;
//    }
//
//    CGFloat imageWidth = image.size.width;
//    CGFloat imageHeight = image.size.height;
//
//    _cellWidth = imageWidth;
//    _cellHeight = imageHeight;
//
//    if (imageWidth > imageHeight) {
//        if (imageWidth > self.maxWidth) {
//            imageWidth = self.maxWidth;
//            _cellWidth = imageWidth;
//
//            imageHeight = (imageWidth / image.size.width) * image.size.height;
//            _cellHeight = imageHeight;
//            if (imageHeight > self.maxHeight) {
//                imageHeight = self.maxHeight;
//                _cellHeight = imageHeight;
//            }
//            else if (imageHeight < self.minHeight) {
//                imageHeight = self.minHeight;
//                _cellHeight = imageHeight;
//            }
//        }
//        else if (imageWidth < self.minWidth) {
//            imageWidth = self.minWidth;
//            _cellWidth = imageWidth;
//
//            imageHeight = (imageWidth / image.size.width) * image.size.height;
//            _cellHeight = imageHeight;
//            if (imageHeight > self.maxHeight) {
//                imageHeight = self.maxHeight;
//                _cellHeight = imageHeight;
//            }
//            else if (imageHeight < self.minHeight) {
//                imageHeight = self.minHeight;
//                _cellHeight = imageHeight;
//            }
//        }
//    }
//    else {
//        if (imageHeight > self.maxHeight) {
//            imageHeight = self.maxHeight;
//            _cellHeight = imageHeight;
//
//            imageWidth = (imageHeight / image.size.height) * image.size.width;
//            _cellWidth = imageWidth;
//            if (imageWidth > self.maxWidth) {
//                imageWidth = self.maxWidth;
//                _cellWidth = imageWidth;
//            }
//            else if (imageWidth < self.minWidth) {
//                imageWidth = self.minWidth;
//                _cellWidth = imageWidth;
//            }
//        }
//        else if (imageHeight < self.minHeight) {
//            imageHeight = self.minHeight;
//            _cellHeight = imageHeight;
//
//            imageWidth = (imageHeight / image.size.height) * image.size.width;
//            _cellWidth = imageWidth;
//            if (imageWidth > self.maxWidth) {
//                imageWidth = self.maxWidth;
//                _cellWidth = imageWidth;
//            }
//            else if (imageWidth < self.minWidth) {
//                imageWidth = self.minWidth;
//                _cellWidth = imageWidth;
//            }
//        }
//    }
}

- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width {
    if (height == 0.0f && width == 0.0f) {
        _cellWidth = self.maxWidth;
        _cellHeight = self.maxHeight;
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

- (void)showVideoCaption:(BOOL)show {
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
        self.starIconBottomImageView.alpha = 0.0f;
        
        if(self.message.isMessageEdited){
            NSString *editedMessageString = [NSString stringWithFormat:@"Edited • %@", [TAPUtil getMessageTimestampText:self.message.created]];
            self.imageTimestampLabel.text = editedMessageString;
        }
        else{
            self.imageTimestampLabel.text = [TAPUtil getMessageTimestampText:self.message.created];
        }
    }
    [self refreshImageSize];
}

- (void)setVideoCaptionWithString:(NSString *)captionString {
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    self.captionLabel.text = captionString;
    
    if ([captionString isEqualToString:@""]) {
        [self showVideoCaption:NO];
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
    
    [self showVideoCaption:YES];
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
    [self refreshImageSize];
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
    [self refreshImageSize];
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
    [self refreshImageSize];
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
//        if (self.message.isFailedSend) {
//            NSString *failedStatusString = NSLocalizedStringFromTableInBundle(@"Failed to send, tap to retry", nil, [TAPUtil currentBundle], @"");
//            self.statusLabel.text = failedStatusString;
//        }
//
//        self.statusLabel.alpha = 1.0f;
//        self.statusLabelTopConstraint.constant = 2.0f;
//        self.statusLabelHeightConstraint.constant = 13.0f;
//
//        if (self.message.isFailedSend) {
//            self.replyButton.alpha = 0.0f;
//        }
//        else {
//            self.replyButton.alpha = 1.0f;
//        }
//
//        [self.contentView layoutIfNeeded];
//        [self layoutIfNeeded];
//    }
//    else {
//        self.statusLabel.alpha = 0.0f;
//        self.statusLabelTopConstraint.constant = 0.0f;
//        self.statusLabelHeightConstraint.constant = 0.0f;
//        self.replyButton.alpha = 0.0f;
//        [self.contentView layoutIfNeeded];
//        [self layoutIfNeeded];
//    }
}

- (void)setForwardData:(TAPForwardFromModel *)forwardData {
    
    NSString *initialAppendedFullnameString = NSLocalizedStringFromTableInBundle(@"From: ", nil, [TAPUtil currentBundle], @"");
    NSString *appendedFullnameString = [NSString stringWithFormat:@"%@%@", initialAppendedFullnameString, forwardData.fullname];
    
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

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(yourVideoBubbleLongPressedWithMessage:)]) {
            [self.delegate yourVideoBubbleLongPressedWithMessage:self.message];
        }
    }
}

- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(yourVideoBubbleTappedWithMessage:)]) {
            [self.delegate yourVideoBubbleTappedWithMessage:self.message];
        }
    }
}

- (void)showProgressDownloadView:(BOOL)show {
    if (show) {
        self.progressBackgroundView.alpha = 1.0f;
    }
    else {
        self.progressBackgroundView.alpha = 0.0f;
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
        [self showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded];
    }
    else {
        [self showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded];
    }
}

- (void)animateFinishedDownloadVideo {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;

    [self showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded];
}

- (void)animateFailedDownloadVideo {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;

    [self showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeRetryDownload];
}

- (void)animateCancelDownloadVideo {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;

    [self showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded];
}

- (void)animateProgressDownloadingVideoWithProgress:(CGFloat)progress total:(CGFloat)total {
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

- (void)showVideoBubbleStatusWithType:(TAPYourVideoBubbleTableViewCellStateType)type {

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

    if (type == TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded) {
        self.cancelView.alpha = 0.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 1.0f;
        self.retryDownloadView.alpha = 0.0f;
        [self showStatusLabel:YES];
    }
    else if (type == TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded) {
        self.cancelView.alpha = 0.0f;
        self.downloadView.alpha = 1.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;
        [self showStatusLabel:YES];
    }
    else if (type == TAPYourVideoBubbleTableViewCellStateTypeDownloading) {
        self.cancelView.alpha = 1.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 0.0f;
        [self showStatusLabel:YES];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.replyButton.alpha = 0.0f;
            [self.contentView layoutIfNeeded];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];

    }
    else if (type == TAPYourVideoBubbleTableViewCellStateTypeRetryDownload) {
        self.cancelView.alpha = 0.0f;
        self.downloadView.alpha = 0.0f;
        self.doneDownloadView.alpha = 0.0f;
        self.retryDownloadView.alpha = 1.0f;
        [self showStatusLabel:NO];
    }
}

- (void)setVideoDurationAndSizeProgressViewWithMessage:(TAPMessageModel *)message progress:(NSNumber *)progress stateType:(TAPYourVideoBubbleTableViewCellStateType)type {

    _yourVideoBubbleTableViewCellStateType = type;
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];

    NSNumber *duration = [dataDictionary objectForKey:@"duration"];
    NSNumber *size = [dataDictionary objectForKey:@"size"];
    
    if ([duration longValue] == 0L && [size longValue] == 0L) {
        self.videoDurationAndSizeView.alpha = 0.0f;
    }
    else {
        NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
        NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
        NSString *fileSizeString = [NSByteCountFormatter stringFromByteCount:[size integerValue] countStyle:NSByteCountFormatterCountStyleBinary];

        NSString *appendedString = @"";

        if (self.yourVideoBubbleTableViewCellStateType == TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded || self.yourVideoBubbleTableViewCellStateType == TAPYourVideoBubbleTableViewCellStateTypeRetryDownload) {
            //Not Downloaded, show duration label and video size
            appendedString = [NSString stringWithFormat:@"%@ - %@",fileSizeString, videoDurationString];
        }
        else if (self.yourVideoBubbleTableViewCellStateType == TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded) {
            //Done Download, show duration label
            appendedString = videoDurationString;
        }
        else if (self.yourVideoBubbleTableViewCellStateType == TAPYourVideoBubbleTableViewCellStateTypeDownloading) {
            //Show downloading file size progress
            double currentProgress = [progress doubleValue];
            NSInteger currentProgressInByte = currentProgress * [size integerValue];
            NSString *currentProgressSizeString = [NSByteCountFormatter stringFromByteCount:currentProgressInByte countStyle:NSByteCountFormatterCountStyleBinary];

            appendedString = [NSString stringWithFormat:@"%@ / %@",currentProgressSizeString, fileSizeString];
        }

        self.videoDurationAndSizeLabel.text = appendedString;

        CGSize contentSize = [self.videoDurationAndSizeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.videoDurationAndSizeLabel.frame))];

        self.videoDurationAndSizeLabel.frame = CGRectMake(CGRectGetMinX(self.videoDurationAndSizeLabel.frame), CGRectGetMinY(self.videoDurationAndSizeLabel.frame), contentSize.width, CGRectGetHeight(self.videoDurationAndSizeLabel.frame));
        self.videoDurationAndSizeView.frame = CGRectMake(CGRectGetMinX(self.videoDurationAndSizeView.frame), CGRectGetMinY(self.videoDurationAndSizeView.frame), contentSize.width + 8.0f + 8.0f, CGRectGetHeight(self.videoDurationAndSizeView.frame));

        if (self.yourVideoBubbleTableViewCellStateType == TAPYourVideoBubbleTableViewCellStateTypeRetryDownload) {
            self.videoDurationAndSizeView.alpha = 0.0f;
        }
        else {
            self.videoDurationAndSizeView.alpha = 1.0f;
        }
    }
}

- (void)setThumbnailImageForVideoWithMessage:(TAPMessageModel *)message {
    [TAPImageView imageFromCacheWithMessage:message
    success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
        [self.bubbleImageView setImage:savedImage];
        [self getImageSizeFromImage:savedImage];
        [self refreshCellHeight];
//        [self.contentView layoutIfNeeded];
    }
    failure:^(NSError *error, TAPMessageModel *receivedMessage) {
        NSDictionary *dataDictionary = message.data;
        [self setSmallThumbnailFromMessageData:dataDictionary];
    }];
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
//        [self getImageSizeFromImage:image];
//        [self.contentView layoutIfNeeded];
    }
    [self refreshImageSize];
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
    [self refreshImageSize];
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
    [self refreshImageSize];
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
    if (self.starIconImageView.alpha == 0) {
        self.starIconImageView.alpha = 1.0f;
        self.starImageViewLeadingConstraint.constant = 8.0f;
        self.starImageViewWidthConstraint.constant = 10.0f;
        if (self.imageTimestampContainerView.alpha == 0) {
            self.starIconBottomImageView.alpha = 1.0f;
        }
    }
    else {
        self.starIconImageView.alpha = 0.0f;
        self.starIconBottomImageView.alpha = 0.0f;
        self.starImageViewLeadingConstraint.constant = 4.0f;
        self.starImageViewWidthConstraint.constant = 0.0f;
    }
    [self refreshImageSize];
}

- (void)showCheckMarkIcon:(BOOL)isShow {
    if (isShow) {
        self.checkMarkIconImageView.alpha = 1.0f;
        self.senderImageViewLeadingConstraint.constant = 40.0f;
        self.bubbleViewLongPressGestureRecognizer.enabled = NO;
        self.forwardCheckmarkButton.alpha = 1.0f;
    }
    else {
        self.checkMarkIconImageView.alpha = 0.0f;
        self.senderImageViewLeadingConstraint.constant = 16.0f;
        self.bubbleViewLongPressGestureRecognizer.enabled = YES;
        self.forwardCheckmarkButton.alpha = 0.0f;
    }
    [self refreshImageSize];
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

- (void)showPinIcon:(BOOL)isShow {
    if (isShow) {
        self.pinIconImageView.alpha = 1.0f;
        self.pinIconWidthConstraint.constant = 10.0f;
        if(self.imageTimestampContainerView.alpha == 0){
            self.pinIconBottomImageView.alpha = 1.0f;
            self.pinIconBottomWidthConstraint.constant = 10.0f;
        }
        
    }
    else {
        self.pinIconImageView.alpha = 0.0f;
        self.pinIconWidthConstraint.constant = 0.0f;
        self.pinIconBottomImageView.alpha = 0.0f;
        self.pinIconBottomWidthConstraint.constant = 0.0f;
    }
    [self refreshImageSize];
}

- (void)showSeperator {
    self.seperatorViewHeight.constant = 1.0f;
    self.seperatorViewTopConstraint.constant = 15.0f;
    self.seperatorViewBottomConstraint.constant = 5.0f;
    self.redirectArrowButton.alpha = 0.0f;
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
    [self refreshImageSize];
}

- (void)showMessageReadCounterWithNumber:(BOOL)isShow readCount:(NSInteger)readCount {
    if (isShow) {
        self.messageReadCounterLabel.text = [NSString stringWithFormat:@"%ld •", readCount];
        self.messageReadCounterImageViewWidthConstraint.constant = 10.0f;
        if (self.pinIconImageView.alpha == 1.0f) {
          //  self.pinIconTrailingConstraint.constant = 7.0f;
        }
        else {
           // self.pinIconTrailingConstraint.constant = 0.0f;
        }
        self.messageReadCounterLabel.alpha = 1.0f;
        self.messageReadCounterImageView.alpha = 1.0f;
        
        self.messageReadCounterBoxLabel.text = [NSString stringWithFormat:@"%ld •", readCount];
        self.messageReadCounterBoxImageViewWidthConstraint.constant = 10.0f;
        self.messageReadCounterBoxLabel.alpha = 1.0f;
        self.messageReadCounterBoxImageView.alpha = 1.0f;
        
        
        
        if (self.imageTimestampContainerView.alpha >= 1.0f) {
            self.messageReadCounterLabel.text = @"";
            self.messageReadCounterImageViewWidthConstraint.constant = 0.0f;
           // self.pinIconTrailingConstraint.constant = 0.0f;
            self.messageReadCounterLabel.alpha = 0.0f;
            self.messageReadCounterImageView.alpha = 0.0f;
        }
    }
    else {
        self.messageReadCounterLabel.text = @"";
        self.messageReadCounterImageViewWidthConstraint.constant = 0.0f;
       // self.pinIconTrailingConstraint.constant = 0.0f;
        self.messageReadCounterLabel.alpha = 0.0f;
        self.messageReadCounterImageView.alpha = 0.0f;
        
        self.messageReadCounterBoxLabel.text = @"";
        self.messageReadCounterBoxImageViewWidthConstraint.constant = 0.0f;
       // self.pinIconTrailingConstraint.constant = 0.0f;
        self.messageReadCounterBoxLabel.alpha = 0.0f;
        self.messageReadCounterBoxImageView.alpha = 0.0f;
    }
    [self.messageReadCounterLabel sizeToFit];
    [self.messageReadCounterBoxLabel sizeToFit];
    [self refreshImageSize];
}

- (void)refreshImageSize {
    [self.bubbleView layoutIfNeeded];
    
    NSDictionary *dataDictionary = self.message.data;
    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    
    NSNumber *width = [dataDictionary objectForKey:@"width"];
    CGFloat imageTempWidth;
    if (width != nil && [width floatValue] > 0.0f) {
        imageTempWidth = [width floatValue];
    }
    else {
        imageTempWidth = self.cellWidth;
    }
    NSNumber *height = [dataDictionary objectForKey:@"height"];
    CGFloat imageTempHeight;
    if (height != nil && [height floatValue] > 0.0f) {
        imageTempHeight = [height floatValue];
    }
    else {
        imageTempHeight = self.cellHeight;
    }
    
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    CGFloat timestampWidthWithMargin = 0.0f;
    if ([captionString isEqual:@""]) {
        [self.imageTimestampContainerView layoutIfNeeded];
        timestampWidthWithMargin = CGRectGetWidth(self.imageTimestampContainerView.frame) + (6.0f * 2) + 20.0f;
        CGFloat radians = atan2f(self.transform.b, self.transform.a);
        NSInteger degrees = radians * (180 / M_PI);
        if(degrees == 0){
            timestampWidthWithMargin += 20.0f;
        }
    }
    else {
        [self.bubbleView layoutIfNeeded];
        CGSize timestampTextSize = [self.timestampLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        timestampWidthWithMargin = timestampTextSize.width + 50.0f;
    }
    if (self.minWidth < timestampWidthWithMargin) {
        _minWidth = timestampWidthWithMargin;
    }
    
    
    [self getResizedImageSizeWithHeight:imageTempHeight width:imageTempWidth];
    self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
    self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
    [self.contentView layoutIfNeeded];
}

- (UITableView * _Nullable)getTableView {
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    if (view != nil && [view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)view;
        return tableView;
    }
    return nil;
}

- (void)refreshCellHeight {
    [UIView performWithoutAnimation:^{
        UITableView *tableView = [self getTableView];
        if (tableView != nil) {
            [tableView beginUpdates];
            [tableView endUpdates];
        }
    }];
}

@end

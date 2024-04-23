//
//  TAPMyChatBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 25/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMyChatBubbleTableViewCell.h"
#import "ZSWTappableLabel.h"

@interface TAPMyChatBubbleTableViewCell() <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIGestureRecognizerDelegate, TAPImageViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *replyInnerView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UIView *replyDecorationView;
@property (strong, nonatomic) IBOutlet UIView *quoteDecorationView;
@property (strong, nonatomic) IBOutlet UIView *fileBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *bubbleHighlightView;
@property (strong, nonatomic) IBOutlet ZSWTappableLabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardFromLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retryIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fileImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIImageView *starIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pinIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *forwardCheckmarkButton;

@property (weak, nonatomic) IBOutlet UIView *linkPreviewContainerView;
@property (weak, nonatomic) IBOutlet UILabel *linkPreviewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkPreviewBodyLabel;
@property (weak, nonatomic) IBOutlet TAPImageView *linkPreviewImageView;


@property (weak, nonatomic) IBOutlet UILabel *messageReadCounterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageReadcounterImageView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBubbleRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconRightConstraint;
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

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelLeadingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewHeightConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starIconLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starIconWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinIconTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinIconWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timestampLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusIconTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewTitleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewBodyTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewImageRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkPreviewViewZeroHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageCounterImageWidthConstraint;

@property (strong, nonatomic) UITapGestureRecognizer *bubbleViewTapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;
@property (nonatomic) BOOL isOnSendingAnimation;
@property (nonatomic) BOOL isShouldChangeStatusAsDelivered;
@property (nonatomic) BOOL isShouldChangeStatusAsRead;

@property (strong, nonatomic) NSURL *messageURL;

- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)retryButtonDidTapped:(id)sender;
- (IBAction)quoteButtonDidTapped:(id)sender;
- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer;
- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;
- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)setBubbleCellStyle;

@end

@implementation TAPMyChatBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    [self.contentView layoutIfNeeded];

    self.statusLabel.alpha = 0.0f;
//    self.statusIconImageView.alpha = 0.0f;
    self.sendingIconImageView.alpha = 0.0f;
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleHighlightView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatBubbleHighlightBackgroundColor];
    
    self.retryIconImageView.alpha = 0.0f;
    self.retryButton.alpha = 1.0f;
    
    self.replyView.layer.cornerRadius = 4.0f;
    self.replyView.clipsToBounds = YES;
    
    self.quoteView.layer.cornerRadius = 8.0f;
    self.quoteView.clipsToBounds = YES;
    
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.delegate = self;
    
    self.fileBackgroundView.layer.cornerRadius = 24.0f;
    
    
    self.swipeReplyView.layer.cornerRadius = CGRectGetHeight(self.swipeReplyView.frame) / 2.0f;
    self.swipeReplyView.backgroundColor = [[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.3f];
    
    self.starIconImageView.alpha = 0;
    
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
    
    [self showQuoteView:NO];
    [self showForwardView:NO];
    
    self.bubbleLabel.tapDelegate = self;
    self.bubbleLabel.longPressDelegate = self;
    self.bubbleLabel.longPressDuration = 0.05f;
    
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    self.linkPreviewImageView.backgroundColor = [UIColor clearColor];
    self.linkPreviewImageView.opaque = NO;
    self.linkPreviewImageView.clipsToBounds = YES;
    self.linkPreviewImageView.layer.masksToBounds = YES;
    self.linkPreviewImageView.layer.cornerRadius = 8.0f;
    
    [self setBubbleCellStyle];
    
    self.mentionIndexesArray = [[NSArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.chatBubbleRightConstraint.constant = 16.0f;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    self.sendingIconImageView.alpha = 0.0f;
    self.sendingIconLeftConstraint.constant = 4.0f;
    self.sendingIconBottomConstraint.constant = -5.0f;
    self.retryIconImageView.alpha = 0.0f;
    self.retryButton.alpha = 0.0f;
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    self.mentionIndexesArray = nil;
    self.starIconImageView.alpha = 0;
    self.checkMarkIconImageView.alpha = 0.0f;
    self.forwardCheckmarkButton.alpha = 0.0f;
    self.starIconLeadingConstraint.constant = 0.0f;
    self.starIconWidthConstraint.constant = 0.0f;
    self.bubbleHighlightView.alpha = 0.0f;
    self.statusLabelBottomConstraint.constant = 8.0f;
    self.pinIconTrailingConstraint.constant = 0.0f;
    self.pinIconImageView.alpha = 0.0f;
    self.linkPreviewContainerView.alpha = 0.0f;
    self.timestampLabelTopConstraint.constant = -35.0f;
    self.statusIconTopConstraint.constant = -35.0f;
    self.linkPreviewImageWidthConstraint.constant = 0.0f;
    self.linkPreviewImageHeightConstraint.constant = 0.0f;
    self.linkPreviewViewHeightConstraint.active = NO;
    self.linkPreviewViewZeroHeightConstraint.active = YES;
    self.linkPreviewBodyTopConstraint.constant = 0.0f;
    self.linkPreviewImageTopConstraint.constant = 0.0f;
    self.messageReadCounterLabel.text = @"";
    self.messageCounterImageWidthConstraint.constant = 0.0f;
    self.pinIconTrailingConstraint.constant = 0.0f;
    [self showQuoteView:NO];
    [self showMessageReadCounterWithNumber:NO readCount:0];
    [self.contentView layoutIfNeeded];
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
                if([self.delegate respondsToSelector:@selector(myChatBubbleDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate myChatBubbleDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(myChatBubbleDidTappedUrl:originalString:)]) {
                    [self.delegate myChatBubbleDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(myChatBubblePressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate myChatBubblePressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
                if([self.delegate respondsToSelector:@selector(myChatBubbleLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate myChatBubbleLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(myChatBubbleLongPressedUrl:originalString:)]) {
                    [self.delegate myChatBubbleLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(myChatBubbleLongPressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate myChatBubbleLongPressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
            
            if (translation.x < 0 && (self.message == nil || self.message.room.type == RoomTypePersonal)) {
                // Cannot swipe left on personal room (message info)
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
            else if (translation.x < -50.0f && !self.disableTriggerHapticFeedbackOnDrag) {
                [TAPUtil tapticImpactFeedbackGenerator];
                _disableTriggerHapticFeedbackOnDrag = YES;
            }
            
            if (translation.x > 70.0f) {
                translation.x = 70.0f;
            }
            else if (translation.x < -70.0f) {
                translation.x = -70.0f;
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
                if ([self.delegate respondsToSelector:@selector(myChatBubbleDidTriggerSwipeToReplyWithMessage:)]) {
                    [self.delegate myChatBubbleDidTriggerSwipeToReplyWithMessage:self.message];
                }
            }
            else if (translation.x < -50.0f && (self.message != nil && self.message.room.type != RoomTypePersonal)) {
                if ([self.delegate respondsToSelector:@selector(myChatBubbleDidTriggerSwipeInfoWithMessage:)]) {
                    [self.delegate myChatBubbleDidTriggerSwipeInfoWithMessage:self.message];
                }
            }
            
            _disableTriggerHapticFeedbackOnDrag = NO;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                recognizer.view.transform = CGAffineTransformIdentity;
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
//                recognizer.view.transform = CGAffineTransformIdentity;
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
    
    self.bubbleLabel.textColor = bubbleLabelColor;
    self.bubbleLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;

    self.timestampLabel.textColor = timestampLabelColor;
    self.timestampLabel.font = timestampLabelFont;
    
    self.linkPreviewTitleLabel.textColor = quoteTitleColor;
    self.linkPreviewTitleLabel.font = quoteTitleFont;
    
    self.linkPreviewBodyLabel.textColor = quoteContentColor;
    self.linkPreviewBodyLabel.font = quoteContentFont;
    
    self.messageReadCounterLabel.textColor = timestampLabelColor;
    self.messageReadCounterLabel.font = timestampLabelFont;
    
    UIImage *sendingImage = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.sendingIconImageView.image = sendingImage;
    
    UIImage *documentsImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentsImage = [documentsImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFilePrimary]];
    self.fileImageView.image = documentsImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    if(message == nil) {
        return;
    }
//    _message = message;
    [super setMessage:message];
    
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""] && message.quote != nil && message.replyTo != nil) {
        //reply to exists
        //if reply exists check if image in quote exists
        //if image exists  change view to Quote View
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
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote userID:@""];
        [self showQuoteView:YES];
    }
    else {
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
    
//    self.bubbleLabel.text = [NSString stringWithFormat:@"%@", message.body];
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    NSDataDetector *detectorPhoneNumber = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL];

    UIColor *highlightedTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBodyURLHighlighted];
    UIColor *defaultTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBodyURL];
    
    NSString *messageText = [TAPUtil nullToEmptyString:message.body];
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
    
    if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeChannel) {
        for (NSInteger counter = 0; counter < [self.mentionIndexesArray count]; counter++) {
            NSArray *mentionRangeArray = self.mentionIndexesArray;
            NSRange userRange = [[mentionRangeArray objectAtIndex:counter] rangeValue];
            
            NSString *mentionString = [self.message.body substringWithRange:userRange];
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
    [style setLineSpacing:self.bubbleLabel.font.pointSize * 0.25f];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, [attributedString length])];

    self.bubbleLabel.attributedText = attributedString;
    
    // Link preview
    NSDictionary *data = message.data;
    NSString *url= [data objectForKey:@"url"];
    
    NSString *linkPreviewTitle = [data objectForKey:@"title"];
    NSString *linkPreviewBody = [data objectForKey:@"description"];
    NSString *linkPreviewImageUrl= [data objectForKey:@"image"];
    
    linkPreviewTitle = [TAPUtil nullToEmptyString:linkPreviewTitle];
    linkPreviewBody = [TAPUtil nullToEmptyString:linkPreviewBody];
    linkPreviewImageUrl = [TAPUtil nullToEmptyString:linkPreviewImageUrl];
    BOOL linkpreviewUI = [[TapUI sharedInstance] getLinkPreviewInMessageEnabled];
    
    if (url != nil && linkpreviewUI && (![linkPreviewTitle isEqualToString:@""] || ![linkPreviewBody isEqualToString:@""] || ![linkPreviewImageUrl isEqualToString:@""])) {
        // Show link preview
        self.linkPreviewContainerView.alpha = 1.0f;
        self.linkPreviewTitleTopConstraint.constant = 4.0f;
        self.timestampLabelTopConstraint.constant = 4.0f;
        self.statusIconTopConstraint.constant = 4.0f;
        self.linkPreviewViewHeightConstraint.active = YES;
        self.linkPreviewViewZeroHeightConstraint.active = NO;
        self.linkPreviewImageWidthConstraint.active = YES;
        self.linkPreviewImageRightConstraint.priority = UILayoutPriorityDefaultHigh;
        
        self.messageURL = [NSURL URLWithString:url];
        
        self.linkPreviewTitleLabel.text = linkPreviewTitle;
        self.linkPreviewBodyLabel.text = linkPreviewBody;
        
        if ([linkPreviewBody isEqualToString:@""]) {
            self.linkPreviewBodyLabel.alpha = 0.0f;
            self.linkPreviewBodyTopConstraint.constant = 4.0f;
        }
        else {
            self.linkPreviewBodyLabel.alpha = 1.0f;
            self.linkPreviewBodyTopConstraint.constant = 9.0f;
        }
        
        if ([self.delegate respondsToSelector:@selector(myChatBubbleDidRequestLinkPreviewImageWithUrl:message:)] &&
            [self.delegate myChatBubbleDidRequestLinkPreviewImageWithUrl:linkPreviewImageUrl message:message] != nil
        ) {
            UIImage *image = [self.delegate myChatBubbleDidRequestLinkPreviewImageWithUrl:linkPreviewImageUrl message:message];
            if (image.size.height > 1.0f) {
                [self setLinkPreviewImage:image];
            }
            else {
                [self hideLinkPreviewImage];
            }
        }
        else if (![linkPreviewImageUrl isEqualToString:@""]) {
            NSURL *urlImage = [NSURL URLWithString:linkPreviewImageUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlImage];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            [self.linkPreviewImageView setImageWithURLRequest:request
                                             placeholderImage:nil
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image) {
                if (image != nil) {
                    [self setLinkPreviewImage:image];
                }
                else {
                    [self hideLinkPreviewImage];
                }
                
                if ([self.delegate respondsToSelector:@selector(myChatBubbleDidFinishLoadingLinkPreviewImage:url:message:)]) {
                    [self.delegate myChatBubbleDidFinishLoadingLinkPreviewImage:image url:linkPreviewImageUrl message:message];
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error) {
                [self hideLinkPreviewImage];
                
                if ([self.delegate respondsToSelector:@selector(myChatBubbleDidFinishLoadingLinkPreviewImage:url:message:)]) {
                    [self.delegate myChatBubbleDidFinishLoadingLinkPreviewImage:nil url:linkPreviewImageUrl message:message];
                }
            }];
        }
        else {
            [self hideLinkPreviewImage];
        }
    }
    else {
        // Hide link preview
        self.linkPreviewContainerView.alpha = 0.0f;
        self.linkPreviewImageWidthConstraint.constant = 0.0f;
        self.linkPreviewImageHeightConstraint.constant = 0.0f;
        self.linkPreviewTitleTopConstraint.constant = 0.0f;
        self.linkPreviewBodyTopConstraint.constant = 0.0f;
        self.linkPreviewImageTopConstraint.constant = 0.0f;
        self.timestampLabelTopConstraint.constant = 0.0f;
        self.statusIconTopConstraint.constant = 0.0f;
        self.linkPreviewTitleLabel.text = @"";
        self.linkPreviewBodyLabel.text = @"";
        self.linkPreviewImageView.image = nil;
        self.linkPreviewViewHeightConstraint.active = NO;
        self.linkPreviewViewZeroHeightConstraint.active = YES;
        self.linkPreviewImageWidthConstraint.active = NO;
        self.linkPreviewImageRightConstraint.priority = UILayoutPriorityRequired;
    }
    
    //remove animation
    [self.bubbleView.layer removeAllAnimations];
    [self.pinIconImageView.layer removeAllAnimations];
    [self.timestampLabel.layer removeAllAnimations];
    [self.quoteView.layer removeAllAnimations];
    [self.quoteDecorationView.layer removeAllAnimations];
    [self.replyView.layer removeAllAnimations];
    [self.replyDecorationView.layer removeAllAnimations];
    [self.bubbleLabel.layer removeAllAnimations];
    [self.replyNameLabel.layer removeAllAnimations];
    [self.replyMessageLabel.layer removeAllAnimations];
    [self.replyInnerView.layer removeAllAnimations];
    [self.statusIconImageView.layer removeAllAnimations];
    [self.forwardFromLabel.layer removeAllAnimations];
    [self.forwardTitleLabel.layer removeAllAnimations];
    [self.quoteImageView.layer removeAllAnimations];
    
    [self.contentView layoutIfNeeded];
}

- (void)setLinkPreviewImage:(UIImage *)image {
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat maxWidth = CGRectGetWidth(self.frame) - 124.0f;
    CGFloat maxHeight = 195.0f;
    if (width > maxWidth || height > maxHeight) {
        if (width / height > maxWidth / maxHeight) {
            // Set to max width
            width = maxWidth;
            height = (image.size.height / image.size.width) * maxWidth;
        }
        else {
            // Set to max height
            width = (image.size.width / image.size.height) * maxHeight;
            height = maxHeight;
        }
    }
    self.linkPreviewImageWidthConstraint.constant = width;
    self.linkPreviewImageHeightConstraint.constant = height;
    if (self.linkPreviewBodyLabel.alpha != 1.0f) {
        self.linkPreviewImageTopConstraint.constant = 12.0f;
    }
    else {
        self.linkPreviewImageTopConstraint.constant = 8.0f;
    }
    [self.linkPreviewImageView setImage:image];
}

- (void)hideLinkPreviewImage {
    self.linkPreviewImageWidthConstraint.constant = 0.0f;
    self.linkPreviewImageHeightConstraint.constant = 0.0f;
    if (self.linkPreviewBodyLabel.alpha != 1.0f) {
        self.linkPreviewImageTopConstraint.constant = 4.0f;
    }
    else {
        self.linkPreviewImageTopConstraint.constant = 0.0f;
    }
    self.linkPreviewImageView.image = nil;
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

//- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message {
//    [super showStatusLabel:isShowed animated:animated updateStatusIcon:updateStatusIcon message:message];
//
//    self.chatBubbleButton.userInteractionEnabled = NO;
//
//    if (isShowed) {
//        CGFloat animationDuration = 0.2f;
//
//        if (!animated) {
//            animationDuration = 0.0f;
//        }
//
//        self.chatBubbleButton.alpha = 1.0f;
//
//        [UIView animateWithDuration:animationDuration animations:^{
//            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
//        } completion:^(BOOL finished) {
//            self.chatBubbleButton.userInteractionEnabled = YES;
//        }];
//    }
//    else {
//        CGFloat animationDuration = 0.2f;
//
//        if (!animated) {
//            animationDuration = 0.0f;
//        }
//
//        [UIView animateWithDuration:animationDuration animations:^{
//            self.chatBubbleButton.backgroundColor = [UIColor clearColor];
//        } completion:^(BOOL finished) {
//            self.chatBubbleButton.alpha = 0.0f;
//            self.chatBubbleButton.userInteractionEnabled = YES;
//        }];
//    }
//}


- (IBAction)forwardCheckmarkButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatCheckmarkDidTapped:)]) {
        [self.delegate myChatCheckmarkDidTapped:self.message];
    }
}

- (IBAction)replyButtonDidTapped:(id)sender {
    [super replyButtonDidTapped:sender];
    
    if ([self.delegate respondsToSelector:@selector(myChatReplyDidTapped)]) {
        [self.delegate myChatReplyDidTapped];
    }
}

- (IBAction)retryButtonDidTapped:(id)sender {
    [super retryButtonDidTapped:sender];
    
    if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
        [self.delegate myChatBubbleViewDidTapped:self.message];
    }
}

- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer {
    [super handleBubbleViewTap:recognizer];
    
    if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
        [self.delegate myChatBubbleViewDidTapped:self.message];
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
//    if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
//        [self.delegate myChatBubbleViewDidTapped:self.message];
//    }
}

- (IBAction)quoteButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatQuoteViewDidTapped:)]) {
        [self.delegate myChatQuoteViewDidTapped:self.message];
    }
}
- (IBAction)linkPreviewButtonDidTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(myChatBubbleDidTappedUrl:originalString:)]) {
        [self.delegate myChatBubbleDidTappedUrl:self.messageURL originalString:@""];
    }
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
        self.replyViewBottomConstraint.active = YES;
        self.replyViewBottomConstraint.constant = 3.0f;
        self.replyViewInnerViewLeadingContraint.constant = 4.0f;
        self.replyNameLabelLeadingConstraint.constant = 8.0f;
        self.replyNameLabelTrailingConstraint.constant = 8.0f;
        self.replyMessageLabelLeadingConstraint.constant = 8.0f;
        self.replyMessageLabelTrailingConstraint.constant = 8.0f;
        self.replyButtonLeadingConstraint.active = YES;
        self.replyButtonTrailingConstraint.active = YES;
    }
    else {
        self.replyNameLabel.text = @"";
        self.replyMessageLabel.text = @"";
        self.replyViewHeightContraint.constant = 0.0f;
        self.replyViewBottomConstraint.active = YES;
        self.replyViewBottomConstraint.constant = 0.0f;
        self.replyViewInnerViewLeadingContraint.constant = 0.0f;
        self.replyNameLabelLeadingConstraint.constant = 0.0f;
        self.replyNameLabelTrailingConstraint.constant = 0.0f;
        self.replyMessageLabelLeadingConstraint.constant = 0.0f;
        self.replyMessageLabelTrailingConstraint.constant = 0.0f;
        self.replyButtonLeadingConstraint.active = NO;
        self.replyButtonTrailingConstraint.active = NO;
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

- (void)showStarMessageIconView{
    if(self.starIconImageView.alpha == 0){
        self.starIconImageView.alpha = 1.0f;
        self.starIconLeadingConstraint.constant = 6.0f;
        self.starIconWidthConstraint.constant = 10.0f;
    }
    else{
        self.starIconImageView.alpha = 0.0f;
        self.starIconLeadingConstraint.constant = 0.0f;
        self.starIconWidthConstraint.constant = 0.0f;
        self.pinIconTrailingConstraint.constant = 0.0f;
    }
    [self.contentView layoutIfNeeded];
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

- (void)showSeperator {
    self.seperatorViewHeightConstarint.constant = 1.0f;
    //self.seperatorViewTopConstraint.constant = 16.0f;
    //self.seperatorViewBottomConstraint.constant = 6.0f;
    self.statusLabelBottomConstraint.constant = 30.0;
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
    [self.contentView layoutIfNeeded];
}

- (void)setForwardData:(TAPForwardFromModel *)forwardData {
    
    NSString *initialNameString = NSLocalizedStringFromTableInBundle(@"From: ", nil, [TAPUtil currentBundle], @"");
    NSString *appendedFullnameString = [NSString stringWithFormat:@"%@%@", initialNameString, forwardData.fullname];
    
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

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(myChatBubbleLongPressedWithMessage:)]) {
            [self.delegate myChatBubbleLongPressedWithMessage:self.message];
        }
    }
}

- (void)setSwipeGestureEnable:(BOOL)enable {
    self.panGestureRecognizer.enabled = enable;
}

- (void)showPinIcon:(BOOL)isShow {
    if(isShow){
        self.pinIconImageView.alpha = 1.0f;
        self.pinIconWidthConstraint.constant = 10.0f;
        if(![self.messageReadCounterLabel.text isEqualToString:@""]) {
            self.pinIconTrailingConstraint.constant = 7.0f;
        }
        else {
            self.pinIconTrailingConstraint.constant = 0.0f;
        }
    }
    else{
        self.pinIconImageView.alpha = 0.0f;
        self.pinIconTrailingConstraint.constant = 0.0f;
        self.pinIconWidthConstraint.constant = 0.0f;
    }
    [self.contentView layoutIfNeeded];
}

- (void)showMessageReadCounterWithNumber:(BOOL)isShow readCount:(NSInteger)readCount {
    [UIView animateWithDuration:0.2f animations:^{
        if (isShow) {
            self.messageReadCounterLabel.text = [NSString stringWithFormat:@"%ld •", readCount];
            self.messageCounterImageWidthConstraint.constant = 10.0f;
            if (self.pinIconImageView.alpha == 1.0f) {
                self.pinIconTrailingConstraint.constant = 7.0f;
            }
            else {
                self.pinIconTrailingConstraint.constant = 0.0f;
            }
            self.messageReadCounterLabel.alpha = 1.0f;
            self.messageReadcounterImageView.alpha = 1.0f;
        }
        else {
            self.messageReadCounterLabel.text = @"";
            self.messageCounterImageWidthConstraint.constant = 0.0f;
            self.pinIconTrailingConstraint.constant = 0.0f;
            self.messageReadCounterLabel.alpha = 0.0f;
            self.messageReadcounterImageView.alpha = 0.0f;
        }
        [self.contentView layoutIfNeeded];
    }];
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

@end

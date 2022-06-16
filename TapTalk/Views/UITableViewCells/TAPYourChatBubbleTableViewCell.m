//
//  TAPYourChatBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 1/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPYourChatBubbleTableViewCell.h"
#import "TAPQuoteModel.h"
#import "ZSWTappableLabel.h"
#import "TAPProfileViewController.h"

@interface TAPYourChatBubbleTableViewCell() <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIGestureRecognizerDelegate, TAPImageViewDelegate>

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
@property (strong, nonatomic) IBOutlet UIImageView *fileImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet UIButton *senderProfileImageButton;
@property (strong, nonatomic) IBOutlet UIView *senderInitialView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialLabel;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIImageView *starIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *forwardCheckmarkButton;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottomConstraint;
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderProfileImageButtonWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeReplyViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewLeadingConstraint;


@property (strong, nonatomic) NSString *currentProfileImageURLString;

@property (strong, nonatomic) UITapGestureRecognizer *bubbleViewTapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;

- (IBAction)quoteButtonDidTapped:(id)sender;
- (IBAction)senderProfileImageButtonDidTapped:(id)sender;

- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)setBubbleCellStyle;
- (void)showSenderInfo:(BOOL)show;
@end

@implementation TAPYourChatBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    [self.contentView layoutIfNeeded];
    self.statusLabel.alpha = 0.0f;
    
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleHighlightView.layer.cornerRadius = 16.0f;
    self.bubbleHighlightView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.bubbleHighlightView.clipsToBounds = YES;
    
    self.replyView.layer.cornerRadius = 4.0f;
    self.replyView.clipsToBounds = YES;
    
    self.quoteView.layer.cornerRadius = 8.0f;
    self.quoteView.clipsToBounds = YES;
    
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.delegate = self;
    
    self.fileBackgroundView.layer.cornerRadius = 24.0f;
    
    self.starIconImageView.alpha = 0.0f;
    
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
    
    [self showQuoteView:NO];
    [self showForwardView:NO];
    
    self.bubbleLabel.tapDelegate = self;
    self.bubbleLabel.longPressDelegate = self;
    self.bubbleLabel.longPressDuration = 0.05f;
    
    self.senderImageView.clipsToBounds = YES;
    self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame)/2.0f;
    
    [self setBubbleCellStyle];
    [self showSenderInfo:NO];

    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    
    self.mentionIndexesArray = [[NSArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.swipeReplyViewHeightConstraint.constant = 30.0f;
    self.swipeReplyViewWidthConstraint.constant = 30.0f;
    self.swipeReplyView.layer.cornerRadius = self.swipeReplyViewHeightConstraint.constant / 2.0f;
    [self.contentView layoutIfNeeded];

    self.mentionIndexesArray = nil;
    self.statusLabel.alpha = 0.0f;
    self.bubbleHighlightView.alpha = 0.0f;
    self.starIconImageView.alpha = 0.0f;
    self.checkMarkIconImageView.alpha = 0.0f;
    self.forwardCheckmarkButton.alpha = 0.0f;
    self.senderImageViewLeadingConstraint.constant = 16.0f;
    [self showSenderInfo:NO];
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
                if([self.delegate respondsToSelector:@selector(yourChatBubbleDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate yourChatBubbleDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourChatBubbleDidTappedUrl:originalString:)]) {
                    [self.delegate yourChatBubbleDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourChatBubblePressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourChatBubblePressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
                if([self.delegate respondsToSelector:@selector(yourChatBubbleLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate yourChatBubbleLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
//                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
//                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourChatBubbleLongPressedUrl:originalString:)]) {
                    [self.delegate yourChatBubbleLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
    else {
        //Handle for mention
        if ([self.delegate respondsToSelector:@selector(yourChatBubbleLongPressedMentionWithWord:tappedAtIndex:message:mentionIndexesArray:)]) {
            [self.delegate yourChatBubbleLongPressedMentionWithWord:tappableLabel.text tappedAtIndex:idx message:self.message mentionIndexesArray:self.mentionIndexesArray];
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
            self.replyButton.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.statusLabel.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            self.swipeReplyView.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            
            self.swipeReplyView.alpha = translation.x / 50.0f;
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x > 50.0f) {
                if ([self.delegate respondsToSelector:@selector(yourChatBubbleDidTriggerSwipeToReplyWithMessage:)]) {
                    [self.delegate yourChatBubbleDidTriggerSwipeToReplyWithMessage:self.message];
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
    
    self.bubbleLabel.textColor = bubbleLabelColor;
    self.bubbleLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;

    self.timestampLabel.textColor = timestampLabelColor;
    self.timestampLabel.font = timestampLabelFont;
    
    self.senderNameLabel.font = senderNameLabelFont;
    self.senderNameLabel.textColor = senderNameLabelColor;
    
    UIImage *documentsImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentsImage = [documentsImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileWhite]];
    self.fileImageView.image = documentsImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    if(message == nil) {
        return;
    }
    
    _message = message;
    
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""]  && message.replyTo != nil && message.quote != nil) {
        //reply to exists
        //if reply exists check if image in quote exists
        //if image exists  change view to Quote View
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
    else if (![message.quote.title isEqualToString:@""] && message != nil) {
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
    
    self.bubbleLabel.text = [NSString stringWithFormat:@"%@", message.body];
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    NSDataDetector *detectorPhoneNumber = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL];
    
    UIColor *highlightedTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageBodyURLHighlighted];
    UIColor *defaultTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleMessageBodyURL];
    
    NSString *messageText = [TAPUtil nullToEmptyString:self.bubbleLabel.text];
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
    
    //CS NOTE - check chat room type, show sender info if group type
    if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
        [self showSenderInfo:YES];
        
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
        
        self.senderNameLabel.text = fullNameString;
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
    
    //remove animation
    [self.bubbleView.layer removeAllAnimations];
    [self.timestampLabel.layer removeAllAnimations];
    [self.quoteView.layer removeAllAnimations];
    [self.quoteDecorationView.layer removeAllAnimations];
    [self.replyView.layer removeAllAnimations];
    [self.replyDecorationView.layer removeAllAnimations];
    [self.bubbleLabel.layer removeAllAnimations];
    [self.replyNameLabel.layer removeAllAnimations];
    [self.replyMessageLabel.layer removeAllAnimations];
    [self.replyInnerView.layer removeAllAnimations];
    [self.forwardFromLabel.layer removeAllAnimations];
    [self.forwardTitleLabel.layer removeAllAnimations];
    [self.senderNameLabel.layer removeAllAnimations];
    [self.senderImageView.layer removeAllAnimations];
    [self.quoteImageView.layer removeAllAnimations];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated {
//    self.chatBubbleButton.userInteractionEnabled = NO;
//
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
//            NSString *appendedMessageDateString = NSLocalizedStringFromTableInBundle(@"at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedMessageDateString, dateString];
//        }
//        else if (timeGap <= 86400.0f + midnightTimeGap) {
//            //Yesterday
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"HH:mm";
//            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
//            NSString *appendedMessageDateString = NSLocalizedStringFromTableInBundle(@"yesterday at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedMessageDateString, dateString];
//        }
//        else {
//            //Set date
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
//
//            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
//            NSString *appendedMessageDateString = NSLocalizedStringFromTableInBundle(@"at ", nil, [TAPUtil currentBundle], @"");
//            lastMessageDateString = [NSString stringWithFormat:@"%@%@", appendedMessageDateString, dateString];
//        }
//
//        NSString *appendedStatusString = NSLocalizedStringFromTableInBundle(@"Sent ", nil, [TAPUtil currentBundle], @"");
//        NSString *statusString = [NSString stringWithFormat:@"%@%@", appendedStatusString, lastMessageDateString];
//        self.statusLabel.text = statusString;
//
//        CGFloat animationDuration = 0.2f;
//
//        if (!animated) {
//            animationDuration = 0.0f;
//        }
//
//        self.chatBubbleButton.alpha = 1.0f;
//
//        [UIView animateWithDuration:animationDuration animations:^{
//            self.statusLabel.alpha = 1.0f;
//            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
//            self.statusLabelTopConstraint.constant = 2.0f;
//            self.statusLabelHeightConstraint.constant = 13.0f;
//            self.replyButton.alpha = 1.0f;
//            self.replyButtonLeftConstraint.constant = 2.0f;
//            [self.contentView layoutIfNeeded];
//            [self layoutIfNeeded];
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
//            self.statusLabelTopConstraint.constant = 0.0f;
//            self.statusLabelHeightConstraint.constant = 0.0f;
//            self.replyButton.alpha = 0.0f;
//            self.replyButtonLeftConstraint.constant = -28.0f;
//            [self.contentView layoutIfNeeded];
//            [self layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            self.chatBubbleButton.alpha = 0.0f;
//            self.chatBubbleButton.userInteractionEnabled = YES;
//            self.statusLabel.alpha = 0.0f;
//        }];
//    }
}

- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(yourChatBubbleViewDidTapped:)]) {
        [self.delegate yourChatBubbleViewDidTapped:self.message];
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
//    if ([self.delegate respondsToSelector:@selector(yourChatBubbleViewDidTapped:)]) {
//        [self.delegate yourChatBubbleViewDidTapped:self.message];
//    }
}


- (IBAction)forwardCheckmarkButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatCheckmarkDidTapped:)]) {
        [self.delegate yourChatCheckmarkDidTapped:self.message];
    }
}

- (IBAction)replyButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatReplyDidTapped)]) {
        [self.delegate yourChatReplyDidTapped];
    }
}

- (IBAction)quoteButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatQuoteViewDidTapped:)]) {
        [self.delegate yourChatQuoteViewDidTapped:self.message];
    }
}

- (IBAction)senderProfileImageButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatBubbleDidTappedProfilePictureWithMessage:)]) {
        [self.delegate yourChatBubbleDidTappedProfilePictureWithMessage:self.message];
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

- (void)setForwardData:(TAPForwardFromModel *)forwardData {
    
    NSString *appendedFullnameString = [NSString stringWithFormat:@"From: %@", forwardData.fullname];
    
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
    if ([userID isEqualToString:[TAPDataManager getActiveUser].userID] && !([quote.fileType isEqualToString:[NSString stringWithFormat:@"%ld", TAPChatMessageTypeFile]] || [quote.fileType isEqualToString:@"file"])) {
        self.quoteTitleLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
    }
    else {
        self.quoteTitleLabel.text = [TAPUtil nullToEmptyString:quote.title];
    }
    self.quoteSubtitleLabel.text = [TAPUtil nullToEmptyString:quote.content];
}

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(yourChatBubbleLongPressedWithMessage:)]) {
            [self.delegate yourChatBubbleLongPressedWithMessage:self.message];
        }
    }
}

- (void)showSenderInfo:(BOOL)show {
    if (show) {
        self.senderImageViewWidthConstraint.constant = 30.0f;
        self.senderImageViewTrailingConstraint.constant = 4.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 30.0f;
        self.senderProfileImageButton.userInteractionEnabled = YES;
        self.senderNameHeightConstraint.constant = 18.0f;
        self.forwardTitleTopConstraint.constant = 0.0f;
    }
    else {
        self.senderImageViewWidthConstraint.constant = 0.0f;
        self.senderImageViewTrailingConstraint.constant = 0.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 0.0f;
        self.senderProfileImageButton.userInteractionEnabled = NO;
        self.senderNameHeightConstraint.constant = 0.0f;
        self.forwardTitleTopConstraint.constant = 0.0f;
    }
    [self.contentView layoutIfNeeded];
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
    }
    else{
        self.starIconImageView.alpha = 0.0f;
    }
}

- (void)showCheckMarkIcon:(BOOL)isShow {
    if(isShow){
        self.checkMarkIconImageView.alpha = 1.0f;
        self.senderImageViewLeadingConstraint.constant = 40.0f;
        self.panGestureRecognizer.enabled = NO;
        self.bubbleViewLongPressGestureRecognizer.enabled = NO;
        self.forwardCheckmarkButton.alpha = 1.0f;
    }
    else{
        self.checkMarkIconImageView.alpha = 0.0f;
        self.senderImageViewLeadingConstraint.constant = 16.0f;
        self.panGestureRecognizer.enabled = YES;
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
    self.seperatorViewHeightConstraint.constant = 1.0f;
    self.statusLabelBottomConstraint.constant = 33.0f;
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
}

@end

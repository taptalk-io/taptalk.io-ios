//
//  TAPYourChatBubbleTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 1/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPYourChatBubbleTableViewCell.h"
#import "TAPQuoteModel.h"

@interface TAPYourChatBubbleTableViewCell()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;

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

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;

- (IBAction)quoteButtonDidTapped:(id)sender;

@end

@implementation TAPYourChatBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    
    self.replyView.layer. cornerRadius = 4.0f;
    
    self.quoteImageView.layer.cornerRadius = 8.0f;
    self.quoteView.layer.cornerRadius = 8.0f;
    
    [self.quoteImageView setImageWithURLString:TAP_DUMMY_IMAGE_URL]; //CS TEMP
    [self showQuoteView:NO]; //CS TEMP
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
}

#pragma mark - Custom Method
- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""]  && message.replyTo != nil && message.quote != nil) {
        //reply to exists
        //if reply exists check if image in quote exists
        //if image exists  change view to Quote View
        if(message.quote.fileID || message.quote.imageURL) {
            [self showReplyView:NO withMessage:nil];
            [self showQuoteView:YES];
            [self setQuote:message.quote];
        }
        else {
            [self showReplyView:YES withMessage:message];
            [self showQuoteView:NO];
        }
    }
    else if (![message.quote.title isEqualToString:@""] && message != nil) {
        //quote exists
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote];
        [self showQuoteView:YES];
    }
    else {
        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }
    
    self.bubbleLabel.text = [NSString stringWithFormat:@"%@", message.body];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated {
    self.chatBubbleButton.userInteractionEnabled = NO;
    
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
            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
            self.statusLabelTopConstraint.constant = 2.0f;
            self.statusLabelHeightConstraint.constant = 13.0f;
            self.replyButton.alpha = 1.0f;
            self.replyButtonLeftConstraint.constant = 2.0f;
            [self.contentView layoutIfNeeded];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.chatBubbleButton.userInteractionEnabled = YES;
        }];
    }
    else {
        CGFloat animationDuration = 0.2f;
        
        if (!animated) {
            animationDuration = 0.0f;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.chatBubbleButton.backgroundColor = [UIColor clearColor];
            self.statusLabelTopConstraint.constant = 0.0f;
            self.statusLabelHeightConstraint.constant = 0.0f;
            self.replyButton.alpha = 0.0f;
            self.replyButtonLeftConstraint.constant = -28.0f;
            [self.contentView layoutIfNeeded];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.chatBubbleButton.userInteractionEnabled = YES;
            self.statusLabel.alpha = 0.0f;
        }];
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatBubbleViewDidTapped:)]) {
        [self.delegate yourChatBubbleViewDidTapped:self.message];
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

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message {
    if (show) {
        self.replyNameLabel.text = message.quote.title;
        self.replyMessageLabel.text = message.quote.content;
        self.replyViewHeightContraint.constant = 60.0f;
        self.replyViewBottomConstraint.active = YES;
        self.replyViewBottomConstraint.constant = 3.0f;
        self.replyViewInnerViewLeadingContraint.constant = 4.0f;
        self.replyNameLabelLeadingConstraint.constant = 4.0f;
        self.replyNameLabelTrailingConstraint.constant = 8.0f;
        self.replyMessageLabelLeadingConstraint.constant = 4.0f;
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
}

- (void)setQuote:(TAPQuoteModel *)quote {
    if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
        [self.quoteImageView setImageWithURLString:quote.imageURL];
    }
    else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
        [self.quoteImageView setImageWithURLString:quote.fileID];
    }
    self.quoteTitleLabel.text = [TAPUtil nullToEmptyString:quote.title];
    self.quoteSubtitleLabel.text = [TAPUtil nullToEmptyString:quote.content];
}
@end

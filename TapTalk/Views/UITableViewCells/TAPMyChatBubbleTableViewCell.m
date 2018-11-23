//
//  TAPMyChatBubbleTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 25/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMyChatBubbleTableViewCell.h"
#import "TAPGradientView.h"

typedef NS_ENUM(NSInteger, TAPMyChatBubbleStatus) {
    TAPMyChatBubbleStatusSending,
    TAPMyChatBubbleStatusSent,
    TAPMyChatBubbleStatusDelivered,
    TAPMyChatBubbleStatusRead
};

@interface TAPMyChatBubbleTableViewCell()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retryIconImageView;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;

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

@property (strong, nonatomic) TAPGradientView *gradientView;

@property (nonatomic) BOOL isOnSendingAnimation;
@property (nonatomic) BOOL isShouldChangeStatusAsDelivered;
@property (nonatomic) BOOL isShouldChangeStatusAsRead;

- (IBAction)chatBubbleButtonDidTapped:(id)sender;
- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)retryButtonDidTapped:(id)sender;

- (void)showReplyView:(BOOL)show withMessasge:(TAPMessageModel *)message;
- (void)hideStatusLabelConstraintUpdateStatusIcon:(BOOL)updateStatusIcon;
- (void)hideStatusLabelAlpha;
- (void)setStatusIconUIWithStatus:(TAPMyChatBubbleStatus)status;

@end

@implementation TAPMyChatBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    self.statusIconImageView.alpha = 0.0f;
    self.sendingIconImageView.alpha = 0.0f;
    
    self.gradientView = [[TAPGradientView alloc] initWithFrame:self.bubbleView.bounds];
    
    self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gradientView.layer.colors = @[ (__bridge id)[TAPUtil getColor:@"9954C2"].CGColor, (__bridge id)[TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE].CGColor];
    
    [self.bubbleView insertSubview:self.gradientView atIndex:0];
    
    self.gradientView.clipsToBounds = YES;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    self.retryIconImageView.alpha = 0.0f;
    self.retryButton.alpha = 1.0f;
    
    self.replyView.layer. cornerRadius = 4.0f;
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
}

#pragma mark - Custom Method
- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    
    //WK Temp
    BOOL isReply = NO;
//    if ([message.messageID integerValue] % 2 == 1) {
//        isReply = YES;
//    }
//    else {
//        isReply = NO;
//    }
    [self showReplyView:isReply withMessasge:message];
    //End Temp
    
    if (!message.isFailedSend) {
        self.retryIconImageView.alpha = 0.0f;
        self.retryButton.alpha = 0.0f;
        
        if (message.isRead) {
            //MESSAGE IS READ BY RECIPIENT
            [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusRead];
        }
        else if (message.isDelivered) {
            //MESSAGE IS DELIVERED TO RECIPIENT
            [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusDelivered];
        }
        else if (message.isSending) {
            //MESSAGE IS BEING SENT
            [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusSending];
        }
        else {
            //MESSAGE IS SENT
            [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusSent];
        }
    }
    else {
        self.retryIconImageView.alpha = 1.0f;
        self.retryButton.alpha = 1.0f;
        self.chatBubbleRightConstraint.constant = 16.0f;
        
        NSString *statusString = NSLocalizedString(@"Failed to send tap to retry", @"");
        self.statusLabel.text = statusString;
        self.statusLabel.alpha = 1.0f;
        self.statusLabelTopConstraint.constant = 2.0f;
        self.statusLabelHeightConstraint.constant = 13.0f;
        self.replyButton.alpha = 0.0f;
        self.statusIconImageView.alpha = 0.0f;
    }
    
    self.bubbleLabel.text = [NSString stringWithFormat:@"%@", message.body];
}

- (void)animateSendingIcon {
    _isOnSendingAnimation = YES;
    
    self.chatBubbleRightConstraint.constant = 32.0f;
    self.sendingIconLeftConstraint.constant = 4.0f;
    self.sendingIconImageView.alpha = 1.0f;
    self.sendingIconBottomConstraint.constant = -5.0f;
    self.statusIconImageView.alpha = 1.0f;
    
    [UIView animateWithDuration:0.16f delay:0.2f options:UIViewAnimationOptionCurveLinear animations:^{
        self.chatBubbleRightConstraint.constant = 16.0f;
        self.statusIconRightConstraint.constant = 2.0f;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:^{
            //            self.statusIconImageView.alpha = 1.0f;
            self.sendingIconLeftConstraint.constant = 20.0f;
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.sendingIconLeftConstraint.constant = 4.0f;
            self.sendingIconImageView.alpha = 0.0f;
            [self setMessage:self.message];
        }];
    }];
    
    [UIView animateWithDuration:0.36f delay:0.2f options:UIViewAnimationOptionCurveLinear animations:^{
        self.sendingIconBottomConstraint.constant = -28.0f;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.sendingIconBottomConstraint.constant = -5.0f;
        
        _isOnSendingAnimation = NO;
        
        if(self.isShouldChangeStatusAsDelivered) {
            //Change status to delivered after sending animation is done
            _isShouldChangeStatusAsDelivered = NO;
            [self setAsDelivered];
        }
        
        if(self.isShouldChangeStatusAsRead) {
            //Change status to read after sending animation is done
            _isShouldChangeStatusAsRead = NO;
            [self setAsRead];
        }
    }];
}

- (void)setAsDelivered {
    if(self.isOnSendingAnimation) {
        //Don't change status if cell is animate sending, change when animation done
        _isShouldChangeStatusAsDelivered = YES;
        return;
    }
    
    [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusDelivered];
}

- (void)setAsRead {
    if(self.isOnSendingAnimation) {
        //Don't change status if cell is animate sending, change when animation done
        _isShouldChangeStatusAsDelivered = YES;
        return;
    }
    
    [self setStatusIconUIWithStatus:TAPMyChatBubbleStatusRead];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon {
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
            self.replyButtonRightConstraint.constant = 2.0f;
            self.statusIconBottomConstraint.constant = -17.0f;
            self.statusIconImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.chatBubbleButton.userInteractionEnabled = YES;
        }];
    }
    else {
        if (self.message.isFailedSend) {
            self.chatBubbleButton.userInteractionEnabled = YES;
            self.retryIconImageView.alpha = 1.0f;
            self.retryButton.alpha = 1.0f;
            self.chatBubbleRightConstraint.constant = 16.0f;
            
            NSString *statusString = NSLocalizedString(@"Failed to send tap to retry", @"");
            self.statusLabel.text = statusString;
            self.statusLabel.alpha = 1.0f;
            self.statusLabelTopConstraint.constant = 2.0f;
            self.statusLabelHeightConstraint.constant = 13.0f;
            self.replyButton.alpha = 0.0f;
            self.statusIconImageView.alpha = 0.0f;
        }
        else {
            if (!animated) {
                [self hideStatusLabelConstraintUpdateStatusIcon:updateStatusIcon];
                [self hideStatusLabelAlpha];
            }
            else {
                [UIView animateWithDuration:0.2f animations:^{
                    [self hideStatusLabelConstraintUpdateStatusIcon:updateStatusIcon];
                } completion:^(BOOL finished) {
                    [self hideStatusLabelAlpha];
                }];
            }
        }
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
        [self.delegate myChatBubbleViewDidTapped:self.message];
    }
}

- (IBAction)replyButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatReplyDidTapped)]) {
        [self.delegate myChatReplyDidTapped];
    }
}

- (IBAction)retryButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatBubbleViewDidTapped:)]) {
        [self.delegate myChatBubbleViewDidTapped:self.message];
    }
}

- (void)showReplyView:(BOOL)show withMessasge:(TAPMessageModel *)message {
    if (show) {
        self.replyNameLabel.text = message.user.fullname;
        self.replyMessageLabel.text = message.body;
        self.replyViewHeightContraint.constant = 60.0f;
        self.replyViewBottomConstraint.constant = 3.0f;
        self.replyViewInnerViewLeadingContraint.constant = 4.0f;
        self.replyNameLabelLeadingConstraint.constant = 4.0f;
        self.replyNameLabelTrailingConstraint.constant = 8.0f;
        self.replyMessageLabelLeadingConstraint.constant = 4.0f;
        self.replyMessageLabelTrailingConstraint.constant = 8.0f;
    }
    else {
        self.replyNameLabel.text = @"";
        self.replyMessageLabel.text = @"";
        self.replyViewHeightContraint.constant = 0.0f;
        self.replyViewBottomConstraint.constant = 0.0f;
        self.replyViewInnerViewLeadingContraint.constant = 0.0f;
        self.replyNameLabelLeadingConstraint.constant = 0.0f;
        self.replyNameLabelTrailingConstraint.constant = 0.0f;
        self.replyMessageLabelLeadingConstraint.constant = 0.0f;
        self.replyMessageLabelTrailingConstraint.constant = 0.0f;
    }
}

- (void)hideStatusLabelConstraintUpdateStatusIcon:(BOOL)updateStatusIcon {
    self.chatBubbleButton.backgroundColor = [UIColor clearColor];
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.replyButton.alpha = 0.0f;
    self.replyButtonRightConstraint.constant = -28.0f;
    self.statusIconBottomConstraint.constant = 2.0f;
    
    if (updateStatusIcon) {
        self.statusIconImageView.alpha = 1.0f;
    }
}

- (void)hideStatusLabelAlpha {
    self.chatBubbleButton.userInteractionEnabled = YES;
    self.statusLabel.alpha = 0.0f;
}

- (void)setStatusIconUIWithStatus:(TAPMyChatBubbleStatus)status {
    if (status == TAPMyChatBubbleStatusRead) {
        //MESSAGE IS READ BY RECIPIENT
        self.statusIconRightConstraint.constant = 2.0f;
        self.chatBubbleRightConstraint.constant = 16.0f;
        self.statusIconImageView.image = [UIImage imageNamed:@"TAPIconReadChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.statusIconImageView.alpha = 1.0f;
    }
    else if (status == TAPMyChatBubbleStatusDelivered) {
        //MESSAGE IS DELIVERED TO RECIPIENT
        self.statusIconRightConstraint.constant = 2.0f;
        self.chatBubbleRightConstraint.constant = 16.0f;
        self.statusIconImageView.image = [UIImage imageNamed:@"TAPIconDeliveredChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.statusIconImageView.alpha = 1.0f;
    }
    else if (status == TAPMyChatBubbleStatusSent) {
        //MESSAGE IS SENT
        self.statusIconRightConstraint.constant = 2.0f;
        self.chatBubbleRightConstraint.constant = 16.0f;
        self.statusIconImageView.image = [UIImage imageNamed:@"TAPIconSentChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.statusIconImageView.alpha = 1.0f;
    }
    else if (status == TAPMyChatBubbleStatusSending) {
        //MESSAGE IS BEING SENT
        self.statusIconRightConstraint.constant = -17.0f;
        self.chatBubbleRightConstraint.constant = 32.0f;
        self.statusIconImageView.image = [UIImage imageNamed:@"TAPIconSentChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.sendingIconImageView.alpha = 1.0f;
    }
}

@end

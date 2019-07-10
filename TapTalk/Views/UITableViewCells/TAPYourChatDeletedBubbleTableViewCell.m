//
//  TAPYourChatDeletedBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPYourChatDeletedBubbleTableViewCell.h"

@interface TAPYourChatDeletedBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (strong, nonatomic) IBOutlet UIImageView *deletedIconImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;

- (IBAction)chatBubbleButtonDidTapped:(id)sender;
- (void)setBubbleCellStyle;

@end

@implementation TAPYourChatDeletedBubbleTableViewCell
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
    
    [self setBubbleCellStyle];
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
- (void)setBubbleCellStyle {
    self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleBackground];
    
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleDeletedMessageBody];
    UIColor *bubbleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleDeletedMessageBody];
    
    UIFont *statusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMessageStatus];
    UIColor *statusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMessageStatus];
    
    self.bubbleLabel.textColor = bubbleLabelColor;
    self.bubbleLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;
    
    UIImage *deletedImage = [UIImage imageNamed:@"TAPIconBlock" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.deletedIconImageView.image = deletedImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    self.bubbleLabel.text = NSLocalizedString(@"You deleted this message.", @"");
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
        
        self.chatBubbleButton.alpha = 1.0f;
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.statusLabel.alpha = 1.0f;
            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
            self.statusLabelTopConstraint.constant = 2.0f;
            self.statusLabelHeightConstraint.constant = 13.0f;
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
            [self.contentView layoutIfNeeded];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.chatBubbleButton.alpha = 0.0f;
            self.chatBubbleButton.userInteractionEnabled = YES;
            self.statusLabel.alpha = 0.0f;
        }];
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatDeletedBubbleViewDidTapped:)]) {
        [self.delegate yourChatDeletedBubbleViewDidTapped:self.message];
    }
}

@end

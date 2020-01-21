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

@property (strong, nonatomic) IBOutlet UIView *senderInitialView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialLabel;
@property (strong, nonatomic) IBOutlet UIButton *senderProfileImageButton;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderImageViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderProfileImageButtonWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameHeightConstraint;

- (IBAction)chatBubbleButtonDidTapped:(id)sender;
- (IBAction)senderProfileImageButtonDidTapped:(id)sender;
- (void)setBubbleCellStyle;

- (void)showSenderInfo:(BOOL)show;

@end

@implementation TAPYourChatDeletedBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    [self.contentView layoutIfNeeded];

    self.statusLabel.alpha = 0.0f;
    
    self.bubbleView.clipsToBounds = YES;
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    
    self.senderImageView.clipsToBounds = YES;
    self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame)/2.0f;

    [self setBubbleCellStyle];
    [self showSenderInfo:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    [self.contentView layoutIfNeeded];

    self.statusLabel.alpha = 0.0f;
    
    [self showSenderInfo:NO];
}

#pragma mark - Custom Method
- (void)setBubbleCellStyle {
    self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorLeftBubbleBackground];
    
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLeftBubbleDeletedMessageBody];
    UIColor *bubbleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLeftBubbleDeletedMessageBody];
    
    UIFont *statusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMessageStatus];
    UIColor *statusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMessageStatus];
    
    UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarSmallLabel];
    UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarSmallLabel];
    
    self.senderInitialLabel.textColor = initialNameLabelColor;
    self.senderInitialLabel.font = initialNameLabelFont;
    self.senderInitialView.layer.cornerRadius = CGRectGetWidth(self.senderInitialView.frame) / 2.0f;
    self.senderInitialView.clipsToBounds = YES;
    
    self.bubbleLabel.textColor = bubbleLabelColor;
    self.bubbleLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;
    
    UIImage *deletedImage = [UIImage imageNamed:@"TAPIconBlock" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    deletedImage = [deletedImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconDeletedLeftMessageBubble]];
    self.deletedIconImageView.image = deletedImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    self.bubbleLabel.text = NSLocalizedString(@"This message was deleted.", @"");
    
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
            self.senderProfileImageButton.alpha = 0.0f;
            self.senderInitialView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:fullNameString];
            self.senderInitialLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:fullNameString isGroup:NO];
        }
        else {
            self.senderInitialView.alpha = 0.0f;
            self.senderImageView.alpha = 1.0f;
            [self.senderImageView setImageWithURLString:thumbnailImageString];
        }
        
        self.senderNameLabel.text = fullNameString;
    }
    else {
        [self showSenderInfo:NO];
        self.senderImageView.image = nil;
        self.senderNameLabel.text = @"";
    }
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
        
        self.chatBubbleButton.alpha = 1.0f;
        
        self.statusLabel.alpha = 1.0f;
        self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
        self.statusLabelTopConstraint.constant = 2.0f;
        self.statusLabelHeightConstraint.constant = 13.0f;
        [self.contentView layoutIfNeeded];
        [self layoutIfNeeded];
        self.chatBubbleButton.userInteractionEnabled = YES;
    }
    else {
        self.chatBubbleButton.backgroundColor = [UIColor clearColor];
        self.statusLabelTopConstraint.constant = 0.0f;
        self.statusLabelHeightConstraint.constant = 0.0f;
        [self.contentView layoutIfNeeded];
        [self layoutIfNeeded];
        self.chatBubbleButton.alpha = 0.0f;
        self.chatBubbleButton.userInteractionEnabled = YES;
        self.statusLabel.alpha = 0.0f;
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatDeletedBubbleViewDidTapped:)]) {
        [self.delegate yourChatDeletedBubbleViewDidTapped:self.message];
    }
}

- (IBAction)senderProfileImageButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourChatDeletedBubbleDidTappedProfilePictureWithMessage:)]) {
        [self.delegate yourChatDeletedBubbleDidTappedProfilePictureWithMessage:self.message];
    }
}

- (void)showSenderInfo:(BOOL)show {
    if (show) {
        self.senderImageViewWidthConstraint.constant = 30.0f;
        self.senderImageViewTrailingConstraint.constant = 4.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 30.0f;
        self.senderProfileImageButton.userInteractionEnabled = YES;
        self.senderNameHeightConstraint.constant = 18.0f;
    }
    else {
        self.senderImageViewWidthConstraint.constant = 0.0f;
        self.senderImageViewTrailingConstraint.constant = 0.0f;
        self.senderProfileImageButtonWidthConstraint.constant = 0.0f;
        self.senderProfileImageButton.userInteractionEnabled = NO;
        self.senderNameHeightConstraint.constant = 0.0f;
    }
    [self.contentView layoutIfNeeded];
}
@end

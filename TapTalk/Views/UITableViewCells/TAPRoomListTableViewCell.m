//
//  TAPRoomListTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRoomListTableViewCell.h"
#import "TAPImageView.h"

@interface TAPRoomListTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIImageView *expertIconImageView;
@property (strong, nonatomic) UILabel *roomNameLabel;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UILabel *lastSenderLabel;
@property (strong, nonatomic) UILabel *lastMessageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *messageStatusImageView;
@property (strong, nonatomic) UIView *bubbleUnreadView;
@property (strong, nonatomic) UILabel *numberOfUnreadMessageLabel;
@property (strong, nonatomic) UILabel *typingLabel;
@property (strong, nonatomic) UIView *separatorView;
@property (nonatomic) TAPMessageStatusType messageStatusType;
@property (nonatomic) BOOL *isShouldForceUpdateUnreadBubble;

@property (strong, nonatomic) NSTimer *typingTimer;
@property (strong, nonatomic) NSString *fullTypingString;
@property (strong, nonatomic) NSString *initialTypingString;
@property (strong, nonatomic) NSString *currentTypingString;

- (void)animateTyping;

@end

@implementation TAPRoomListTableViewCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _isShouldForceUpdateUnreadBubble = YES;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 70.0f)];
        [self.contentView addSubview:self.bgView];
        
        CGFloat leftPadding = 16.0f;
        CGFloat rightPadding = 16.0f;
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(leftPadding, 9.0f, 52.0f, 52.0f)];
        self.profileImageView.backgroundColor = [UIColor clearColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2.0f;
        self.profileImageView.clipsToBounds = YES;
        [self.bgView addSubview:self.profileImageView];
        
        _expertIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 22.0f, CGRectGetMaxY(self.profileImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 0.0f;
        [self.bgView addSubview:self.expertIconImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - rightPadding, CGRectGetMinY(self.profileImageView.frame), 0.0f, 16.0f)];
        self.timeLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        self.timeLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:11.0f];
        [self.bgView addSubview:self.timeLabel];
        
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.timeLabel.frame) - 4.0f, 0.0f, 0.0f, 13.0f)];
        self.muteImageView.alpha = 0.0f;
        self.muteImageView.image = [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bgView addSubview:self.muteImageView];
        
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, 8.0f, CGRectGetMinX(self.muteImageView.frame) - CGRectGetMaxX(self.profileImageView.frame) - 4.0f - 8.0f, 20.0f)];
        self.roomNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.roomNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        [self.bgView addSubview:self.roomNameLabel];
        self.muteImageView.center = CGPointMake(self.muteImageView.center.x, self.roomNameLabel.center.y);
        
        _messageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgView.frame) - 12.0f - 24.0f, CGRectGetMaxY(self.bgView.frame) - 16.0f - 24.0f, 24.0f, 24.0f)];
        self.messageStatusImageView.alpha = 0.0f;
        [self.bgView addSubview:self.messageStatusImageView];
        
        _bubbleUnreadView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, CGRectGetHeight(self.bgView.frame) - 18.0f - 20.0f, 0.0f, 20.0f)];
        self.bubbleUnreadView.clipsToBounds = YES;
        self.bubbleUnreadView.layer.cornerRadius = CGRectGetHeight(self.bubbleUnreadView.frame) / 2.0f;
        [self.bgView addSubview:self.bubbleUnreadView];
        
        _numberOfUnreadMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 3.0f, 0.0f, 13.0f)];
        self.numberOfUnreadMessageLabel.textColor = [UIColor whiteColor];
        self.numberOfUnreadMessageLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        [self.bubbleUnreadView addSubview:self.numberOfUnreadMessageLabel];
        
        _lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame) - 50.0f - 4.0f, 44.0f)];
        self.lastMessageLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        self.lastMessageLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.lastMessageLabel.numberOfLines = 2;
        [self.bgView addSubview:self.lastMessageLabel];
        
        self.lastSenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 17.0f)];
        self.lastSenderLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_2C];
        self.lastSenderLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        [self.bgView addSubview:self.lastSenderLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_EA];
        [self.bgView addSubview:self.separatorView];
        
        //Typing Animation
        _typingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(animateTyping) userInfo:nil repeats:YES];
        self.fullTypingString = NSLocalizedString(@"typing...", @"");
        self.initialTypingString = NSLocalizedString(@"typing.", @"");
        self.currentTypingString = self.initialTypingString;
        
        _typingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 16.0f)];
        self.typingLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        self.typingLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.typingLabel.text = self.currentTypingString;
        self.typingLabel.numberOfLines = 1;
        [self.bgView addSubview:self.typingLabel];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _isShouldForceUpdateUnreadBubble = YES;
}

#pragma mark - Custom Method
- (void)setRoomListTableViewCellWithData:(TAPRoomListModel *)roomList updateUnreadBubble:(BOOL)updateUnreadBubble {
    TAPMessageModel *message = roomList.lastMessage;
    
    //DV Temp
    BOOL isExpert = NO;
    BOOL isGroup = NO;
    NSString *lastSender = message.room.name; //DV Note - For Group Only
    BOOL isMuted = NO;
    NSString *profileImageURL = message.room.imageURL.thumbnail;
//    NSString *profileImageURL = roomList.lastMessage.user.imageURL.thumbnail;
    //END DV Temp
    
    NSInteger numberOfUnreadMessage = roomList.numberOfUnreadMessages;
    
    TAPRoomModel *currentRoom = message.room;
    
    NSString *roomName = currentRoom.name;
    roomName = [TAPUtil nullToEmptyString:roomName];
    
    NSTimeInterval lastMessageTimeInterval = [message.created doubleValue] / 1000.0f; //change to second from milisecond
    NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
    
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
    
    NSString *timeString = @"";
    if (timeGap <= midnightTimeGap) {
        //Today
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        timeString = dateString;
    }
    else if (timeGap <= 86400.0f + midnightTimeGap) {
        //Yesterday
        timeString = NSLocalizedString(@"Yesterday", @"");
    }
    else {
        //Set date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        
        timeString = dateString;
    }
    
    NSString *lastMessage = message.body;
    
    TAPMessageStatusType statusType = TAPMessageStatusTypeNone;
    NSString *currentUserID = [TAPChatManager sharedManager].activeUser.userID;
    if ([message.user.userID isEqualToString:currentUserID]) {
        //last message is from ourself
        if (message.isRead) {
            statusType = TAPMessageStatusTypeRead;
        }
        else if (message.isDelivered) {
            statusType = TAPMessageStatusTypeDelivered;
        }
        else if (message.isSending) {
            statusType = TAPMessageStatusTypeSending;
        }
        else if (message.isFailedSend) {
            statusType = TAPMessageStatusTypeFailed;
        }
        else {
            statusType = TAPMessageStatusTypeSent;
        }
    }
    else {
        //last message is from other user
    }
    
    self.messageStatusType = statusType;
    
    [self.profileImageView setImageWithURLString:profileImageURL];

    //TIME LABEL
    self.timeLabel.text = timeString;
    //resize timelabel
    CGSize newTimeLabelSize = [self.timeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.timeLabel.frame))];
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - newTimeLabelSize.width, CGRectGetMinY(self.timeLabel.frame), newTimeLabelSize.width, CGRectGetHeight(self.timeLabel.frame));
    
    //MUTE IMAGE VIEW
    if (isMuted) {
        self.muteImageView.frame = CGRectMake(CGRectGetMinX(self.timeLabel.frame) - 4.0f - 10.0f, CGRectGetMinY(self.muteImageView.frame), 10.0f, CGRectGetHeight(self.muteImageView.frame));
        self.muteImageView.alpha = 1.0f;
    }
    else {
        self.muteImageView.frame = CGRectMake(CGRectGetMinX(self.timeLabel.frame) - 4.0f, CGRectGetMinY(self.muteImageView.frame), 0.0f, CGRectGetHeight(self.muteImageView.frame));
        self.muteImageView.alpha = 0.0f;
    }
    
    //ROOM NAME LABEL
    self.roomNameLabel.text = roomName;
    
    NSMutableDictionary *roomNameAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat roomNameLetterSpacing = -0.2f;
    [roomNameAttributesDictionary setObject:@(roomNameLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *roomNameStyle = [[NSMutableParagraphStyle alloc] init];
    roomNameStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [roomNameAttributesDictionary setObject:roomNameStyle forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *roomNameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.roomNameLabel.text];
    [roomNameAttributedString addAttributes:roomNameAttributesDictionary
                                      range:NSMakeRange(0, [self.roomNameLabel.text length])];
    self.roomNameLabel.attributedText = roomNameAttributedString;
    self.roomNameLabel.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMinY(self.roomNameLabel.frame), CGRectGetMinX(self.muteImageView.frame) - CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.roomNameLabel.frame));
    
    if (self.messageStatusType == TAPMessageStatusTypeNone) {
        //resize
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 12.0f, CGRectGetMinY(self.messageStatusImageView.frame), 0.0f, 0.0f);
    }
    else {
        //resize
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 12.0f - 24.0f, CGRectGetMinY(self.messageStatusImageView.frame), 24.0f, 24.0f);
    }
    
    switch (self.messageStatusType) {
        case TAPMessageStatusTypeNone:
        {
            self.messageStatusImageView.alpha = 0.0f;
            break;
        }
        case TAPMessageStatusTypeSending:
        {
            if (numberOfUnreadMessage > 0) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        case TAPMessageStatusTypeSent:
        {
            if (numberOfUnreadMessage > 0) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        case TAPMessageStatusTypeDelivered:
        {
            if (numberOfUnreadMessage > 0) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        case TAPMessageStatusTypeRead:
        {
            if (numberOfUnreadMessage > 0) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        case TAPMessageStatusTypeFailed:
        {
            if (numberOfUnreadMessage > 0) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconFailed" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        default:
            self.messageStatusImageView.alpha = 0.0f;
            break;
    }
    
    //Check if cell is reused, forece update unread bubble
    if (self.isShouldForceUpdateUnreadBubble) {
        updateUnreadBubble = YES;
        _isShouldForceUpdateUnreadBubble = NO;
    }
    
    //Only update unread bubble when count unread from database
    if (updateUnreadBubble) {
        //Unread bubble
        if(numberOfUnreadMessage < 0) {
            numberOfUnreadMessage = 0;
        }
        
        if (numberOfUnreadMessage == 0) {
            self.bubbleUnreadView.alpha = 0.0f;
            self.bubbleUnreadView.frame = CGRectMake(CGRectGetMinX(self.messageStatusImageView.frame), CGRectGetMinY(self.messageStatusImageView.frame), CGRectGetWidth(self.messageStatusImageView.frame), CGRectGetHeight(self.bubbleUnreadView.frame));
        }
        else {
            if (numberOfUnreadMessage > 99) {
                self.numberOfUnreadMessageLabel.text = @"99+";
            }
            else {
                self.numberOfUnreadMessageLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessage];
            }
            
            //Bubble Number
            CGSize newNumberOfUnreadMessageLabelSize = [self.numberOfUnreadMessageLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.numberOfUnreadMessageLabel.frame))];
            self.numberOfUnreadMessageLabel.frame = CGRectMake(CGRectGetMinX(self.numberOfUnreadMessageLabel.frame), CGRectGetMinY(self.numberOfUnreadMessageLabel.frame), newNumberOfUnreadMessageLabelSize.width, CGRectGetHeight(self.numberOfUnreadMessageLabel.frame));
            
            //Bubble View
            self.bubbleUnreadView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetWidth(self.numberOfUnreadMessageLabel.frame) + 7.0f + 7.0f), CGRectGetMinY(self.bubbleUnreadView.frame), CGRectGetWidth(self.numberOfUnreadMessageLabel.frame) + 7.0f + 7.0f, CGRectGetHeight(self.bubbleUnreadView.frame));
            self.bubbleUnreadView.alpha = 1.0f;
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bubbleUnreadView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"9954C2"].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE].CGColor, nil];
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            gradient.cornerRadius = CGRectGetHeight(self.bubbleUnreadView.frame) / 2.0f;
            [self.bubbleUnreadView.layer insertSublayer:gradient atIndex:0];
        }
    }
    
    if (isGroup) {
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconGroup" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 1.0f;
        
        //Last Sender
        self.lastSenderLabel.alpha = 1.0f;
        self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.lastSenderLabel.frame), 17.0f);
        self.lastSenderLabel.text = lastSender;
        
        NSMutableDictionary *lastSenderAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat lastSenderLetterSpacing = -0.2f;
        [lastSenderAttributesDictionary setObject:@(lastSenderLetterSpacing) forKey:NSKernAttributeName];
        NSMutableParagraphStyle *lastSenderStyle = [[NSMutableParagraphStyle alloc] init];
        lastSenderStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [lastSenderStyle setLineSpacing:2];
        [lastSenderAttributesDictionary setObject:lastSenderStyle forKey:NSParagraphStyleAttributeName];
        NSMutableAttributedString *lastSenderAttributedString = [[NSMutableAttributedString alloc] initWithString:self.lastSenderLabel.text];
        [lastSenderAttributedString addAttributes:lastSenderAttributesDictionary
                                            range:NSMakeRange(0, [self.lastSenderLabel.text length])];
        self.lastSenderLabel.attributedText = lastSenderAttributedString;
        if (numberOfUnreadMessage > 0) {
            self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f, 17.0f);
        }
        else {
            self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f, 17.0f);
        }
        
        //Last Message
        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMaxY(self.lastSenderLabel.frame) + 1.0f, CGRectGetWidth(self.lastMessageLabel.frame), 17.0f);
        self.lastMessageLabel.numberOfLines = 1;
        self.lastMessageLabel.text = lastMessage;
    }
    else {
        if (isExpert) {
            self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.expertIconImageView.alpha = 1.0f;
        }
        else {
            self.expertIconImageView.alpha = 0.0f;
        }
        
        self.lastSenderLabel.alpha = 0.0f;
        
        //Last Message
        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 44.0f);
        self.lastMessageLabel.numberOfLines = 2;
        self.lastMessageLabel.text = lastMessage;
    }
    
    //Attribute Text for Last Message
    NSMutableDictionary *lastMessageAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat lastMessageLetterSpacing = -0.2f;
    [lastMessageAttributesDictionary setObject:@(lastMessageLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *lastMessageStyle = [[NSMutableParagraphStyle alloc] init];
    lastMessageStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [lastMessageStyle setLineSpacing:2];
    [lastMessageAttributesDictionary setObject:lastMessageStyle forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *lastMessageAttributedString = [[NSMutableAttributedString alloc] initWithString:[TAPUtil nullToEmptyString:self.lastMessageLabel.text]];
    [lastMessageAttributedString addAttributes:lastMessageAttributesDictionary
                                         range:NSMakeRange(0, [self.lastMessageLabel.text length])];
    self.lastMessageLabel.attributedText = lastMessageAttributedString;
    
    //Resize lastMessageLabel
    CGSize newLastMessageLabelSize = [self.lastMessageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) -16.0f, CGRectGetHeight(self.lastMessageLabel.frame))];
    if (numberOfUnreadMessage > 0) {
        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f, newLastMessageLabelSize.height);
    }
    else {
        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f, newLastMessageLabelSize.height);
    }
}

- (void)setAsTyping:(BOOL)typing {
    if (typing) {
        self.typingLabel.alpha = 1.0f;
        self.lastMessageLabel.alpha = 0.0f;
        [self performSelector:@selector(setAsTypingNoAfterDelay) withObject:nil afterDelay:15.0f];
    }
    else {
        self.typingLabel.alpha = 0.0f;
        self.lastMessageLabel.alpha = 1.0f;
    }
}

- (void)animateTyping {
    if([self.currentTypingString length] < [self.fullTypingString length]) {
        self.currentTypingString = [self.fullTypingString substringWithRange:NSMakeRange(0, [self.currentTypingString length] + 1)];
        self.typingLabel.text = self.currentTypingString;
    }
    else if([self.currentTypingString isEqualToString:self.fullTypingString]) {
        self.currentTypingString = self.initialTypingString;
        self.typingLabel.text = self.currentTypingString;
    }
}

- (void)setAsTypingNoAfterDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAsTypingNoAfterDelay) object:nil];
    self.typingLabel.alpha = 0.0f;
    self.lastMessageLabel.alpha = 1.0f;
}

@end

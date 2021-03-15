
//
//  TAPSearchResultMessageTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 16/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchResultMessageTableViewCell.h"

@interface TAPSearchResultMessageTableViewCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *roomNameLabel;
@property (strong, nonatomic) UILabel *lastSenderLabel;
@property (strong, nonatomic) UILabel *lastMessageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UIImageView *messageStatusImageView;

@property (strong, nonatomic) UIView *separatorView;
@property (nonatomic) TAPSearchResultMessageStatusType searchResultMessageStatusType;

@end

@implementation TAPSearchResultMessageTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 70.0f)];
        [self.contentView addSubview:self.bgView];
        
        CGFloat leftPadding = 16.0f;
        CGFloat rightPadding = 16.0f;
        
        UIFont *roomListTimeLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListTime];
        UIColor *roomListTimeLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListTime];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - rightPadding, 16.0f, 0.0f, 16.0f)];
        self.timeLabel.textColor = roomListTimeLabelColor;
        self.timeLabel.font = roomListTimeLabelFont;
        [self.bgView addSubview:self.timeLabel];
        
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.timeLabel.frame) - 4.0f, 0.0f, 0.0f, 13.0f)];
        self.muteImageView.alpha = 0.0f;
        self.muteImageView.image = [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.muteImageView.image = [self.muteImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMuted]];
        [self.bgView addSubview:self.muteImageView];
        
        UIFont *roomListNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListName];
        UIColor *roomListNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListName];
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 19.0f, CGRectGetMinX(self.muteImageView.frame) - leftPadding - 8.0f, 18.0f)];
        self.roomNameLabel.textColor = roomListNameLabelColor;
        self.roomNameLabel.font = roomListNameLabelFont;
        [self.bgView addSubview:self.roomNameLabel];
        self.muteImageView.center = CGPointMake(self.muteImageView.center.x, self.roomNameLabel.center.y);
        
        _messageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgView.frame) - 10.0f - 20.0f, CGRectGetMaxY(self.bgView.frame) - 8.0f - 20.0f, 20.0f, 20.0f)];
        self.messageStatusImageView.alpha = 0.0f;
        [self.bgView addSubview:self.messageStatusImageView];
        
        UIFont *lastSenderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontGroupRoomListSenderName];
        UIColor *lastSenderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorGroupRoomListSenderName];
        _lastSenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame) + 3.0f, 0.0f, 18.0f)];
        self.lastSenderLabel.textColor = lastSenderLabelColor;
        self.lastSenderLabel.font = lastSenderLabelFont;
        [self.bgView addSubview:self.lastSenderLabel];
        
        UIFont *roomListMessageLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListMessage];
        UIColor *roomListMessageLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListMessage];
        _lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame) + 3.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame) - 4.0f - CGRectGetWidth(self.messageStatusImageView.frame) - rightPadding, 18.0f)];
        self.lastMessageLabel.textColor = roomListMessageLabelColor;
        self.lastMessageLabel.font = roomListMessageLabelFont;
        [self.bgView addSubview:self.lastMessageLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - leftPadding - rightPadding, 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.bgView addSubview:self.separatorView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setSearchResultMessageTableViewCell:(TAPMessageModel *)message
                             searchedString:(NSString *)searchedString {
    searchedString = [searchedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    TAPUserModel *user = message.user;
    
    BOOL isMuted = NO;
    
    TAPRoomModel *currentRoom = message.room;
    
    BOOL isGroup = NO;
    NSString *lastSender = @"";
    
    if (currentRoom.type == RoomTypeGroup || currentRoom.type == RoomTypeChannel || currentRoom.type == RoomTypeTransaction) {
        //Group / Channel
        isGroup = YES;
    }
    if (isGroup) {
        lastSender = message.room.name; //DV Note - For Group Only
    }

    
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
        timeString = NSLocalizedStringFromTableInBundle(@"Yesterday", nil, [TAPUtil currentBundle], @"");
    }
    else {
        //Set date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yy";
        
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        
        timeString = dateString;
    }
    
    NSString *lastMessage = message.body;
    
    TAPSearchResultMessageStatusType statusType = TAPSearchResultMessageStatusTypeNone;
    NSString *currentUserID = [TAPChatManager sharedManager].activeUser.userID;
    if ([message.user.userID isEqualToString:currentUserID]) {
        //last message is from ourself
        if (message.isRead) {
            statusType = TAPSearchResultMessageStatusTypeRead;
        }
        else if (message.isDelivered) {
            statusType = TAPSearchResultMessageStatusTypeDelivered;
        }
        else if (message.isSending) {
            statusType = TAPSearchResultMessageStatusTypeSending;
        }
        else {
            statusType = TAPSearchResultMessageStatusTypeSent;
        }
    }
    else {
        //last message is from other user
        if (message.isFailedSend) {
            statusType = TAPSearchResultMessageStatusTypeFailed;
        }
    }
    
    self.searchResultMessageStatusType = statusType;
    
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
    
    if (self.searchResultMessageStatusType == TAPSearchResultMessageStatusTypeNone) {
        //resize
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, CGRectGetMinY(self.messageStatusImageView.frame), 0.0f, 0.0f);
    }
    else {
        //resize
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 20.0f, CGRectGetMinY(self.messageStatusImageView.frame), 20.0f, 20.0f);
    }
    
    switch (self.searchResultMessageStatusType) {
        case TAPSearchResultMessageStatusTypeNone:
        {
            self.messageStatusImageView.alpha = 0.0f;
            break;
        }
        case TAPSearchResultMessageStatusTypeSending:
        {
            if (message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            break;
        }
        case TAPSearchResultMessageStatusTypeSent:
        {
            if (message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageSent]];
            break;
        }
        case TAPSearchResultMessageStatusTypeDelivered:
        {
            if (message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageDelivered]];
            break;
        }
        case TAPSearchResultMessageStatusTypeRead:
        {
            if (message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            
            //Check if show read status
            BOOL isHideReadStatus = [[TapUI sharedInstance] getReadStatusHiddenState];
            if (isHideReadStatus) {
                //Set to delivered icon
                self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
                self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageDelivered]];
            }
            else {
                //Set to read icon
                self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
                self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageRead]];
            }
            
            break;
        }
        case TAPSearchResultMessageStatusTypeFailed:
        {
            if (message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconFailed" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomMessageFailed]];
            break;
        }
        default:
            self.messageStatusImageView.alpha = 0.0f;
            break;
    }
    
    //Last Message
    TAPUserModel *activeUser = [TAPDataManager getActiveUser];
    if (user.userID == activeUser.userID) {
        self.lastSenderLabel.text = NSLocalizedStringFromTableInBundle(@"You: ", nil, [TAPUtil currentBundle], @"");
    }
    else if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
        NSString *fullName = user.fullname;
        NSArray *eachWordArray = [fullName componentsSeparatedByString:@" "];
        NSString *firstName = [eachWordArray objectAtIndex:0];
        self.lastSenderLabel.text = [NSString stringWithFormat:@"%@: ", firstName];
    }
    else {
//        NSString *fullName = user.fullname;
//        NSArray *eachWordArray = [fullName componentsSeparatedByString:@" "];
//        NSString *firstName = [eachWordArray objectAtIndex:0];
//        self.lastSenderLabel.text = [NSString stringWithFormat:@"%@: ", firstName];
        self.lastSenderLabel.text = @"";
    }
    
    //Attribute Text for Last Sender
    NSMutableDictionary *lastSenderAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat lastSenderLetterSpacing = -0.2f;
    [lastSenderAttributesDictionary setObject:@(lastSenderLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *lastSenderStyle = [[NSMutableParagraphStyle alloc] init];
    lastSenderStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [lastSenderStyle setLineSpacing:2];
    [lastSenderAttributesDictionary setObject:lastSenderStyle forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *lastSenderAttributedString = [[NSMutableAttributedString alloc] initWithString:[TAPUtil nullToEmptyString:self.lastSenderLabel.text]];
    [lastSenderAttributedString addAttributes:lastSenderAttributesDictionary
                                        range:NSMakeRange(0, [self.lastSenderLabel.text length])];
    self.lastSenderLabel.attributedText = lastSenderAttributedString;
    
    //Resize Frame for Last Sender
    CGSize lastSenderSize = [self.lastSenderLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.lastSenderLabel.frame))];
    self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMinY(self.lastSenderLabel.frame), lastSenderSize.width, CGRectGetHeight(self.lastSenderLabel.frame));
    
    //Attribute Text for Last Message
    self.lastMessageLabel.text = lastMessage;
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
    //Highlight Searched Text
    NSString *lowercaseLastMessage = [self.lastMessageLabel.text lowercaseString];
    NSString *lowercaseSeachedString = [searchedString lowercaseString];
    
    //CS NOTE - uncomment to use trimmed string
//    //WK Note - Create nonAlphaNumericCharacters
//    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
//    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
//    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
//
//    NSString *alphaNumericSearchedString = [[lowercaseSeachedString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
//    //End Note
    
    UIColor *messageHighlightedColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListMessageHighlighted];
    NSRange searchedRange = [lowercaseLastMessage rangeOfString:lowercaseSeachedString];
    [lastMessageAttributedString addAttribute:NSForegroundColorAttributeName
                                        value:messageHighlightedColor
                                        range:searchedRange];
    self.lastMessageLabel.attributedText = lastMessageAttributedString;
    
    CGFloat lastMessageMaxWidth = CGRectGetMinX(self.messageStatusImageView.frame) - CGRectGetMaxX(self.lastSenderLabel.frame);
    CGSize lastMessageSize = [self.lastMessageLabel sizeThatFits:CGSizeMake(lastMessageMaxWidth, CGRectGetHeight(self.lastMessageLabel.frame))];
    self.lastMessageLabel.frame = CGRectMake(CGRectGetMaxX(self.lastSenderLabel.frame), CGRectGetMinY(self.lastMessageLabel.frame), lastMessageMaxWidth, CGRectGetHeight(self.lastMessageLabel.frame));
}

@end

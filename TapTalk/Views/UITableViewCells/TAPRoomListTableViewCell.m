//
//  TAPRoomListTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRoomListTableViewCell.h"
#import "TAPImageView.h"

@interface TAPRoomListTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *typingView;
@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIImageView *typingAnimationImageView;
@property (strong, nonatomic) UIImageView *expertIconImageView;
@property (strong, nonatomic) UILabel *roomNameLabel;
@property (strong, nonatomic) UIImageView *muteImageView;
//@property (strong, nonatomic) UILabel *lastSenderLabel;
@property (strong, nonatomic) UILabel *lastMessageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *messageStatusImageView;
@property (strong, nonatomic) UIImageView *deletedUserProfilImageView;
@property (strong, nonatomic) UIView *bubbleUnreadView;
@property (strong, nonatomic) UILabel *numberOfUnreadMessageLabel;
@property (strong, nonatomic) UIView *unreadMentionView;
@property (strong, nonatomic) UIImageView *unreadMentionImageView;
@property (strong, nonatomic) UILabel *typingLabel;
@property (strong, nonatomic) UIView *separatorView;
@property (nonatomic) TAPMessageStatusType messageStatusType;
@property (nonatomic) RoomType roomType;
@property (strong, nonatomic) NSString *roomID;
@property (nonatomic) BOOL isShouldForceUpdateUnreadBubble;

- (void)refreshTypingLabelState;

@end

@implementation TAPRoomListTableViewCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _isShouldForceUpdateUnreadBubble = YES;
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _isShouldForceUpdateUnreadBubble = YES;
    [self.typingAnimationImageView stopAnimating];
    self.deletedUserProfilImageView.alpha = 0.0f;
//    if (self.roomType != RoomTypePersonal) {
//        self.lastSenderLabel.alpha = 1.0f;
//    }
//    else {
//        self.lastSenderLabel.alpha = 0.0f;
//    }
}

#pragma mark - Custom Method
- (void)setRoomListTableViewCellWithData:(TAPRoomListModel *)roomList updateUnreadBubble:(BOOL)updateUnreadBubble {
    TAPMessageModel *message = roomList.lastMessage;
    _roomType = message.room.type;
    _roomID = [TAPUtil nullToEmptyString:message.room.roomID];
    //DV Temp
    BOOL isExpert = NO;
    BOOL isMuted = NO;
    //END DV Temp

    BOOL isGroup = NO;
    NSString *lastSender = @"";
    
    NSInteger numberOfUnreadMessage = roomList.numberOfUnreadMessages;
    NSInteger numberOfUnreadMention = roomList.numberOfUnreadMentions;
    BOOL isMarkedAsUnread = roomList.isMarkedAsUnread;
    
    TAPRoomModel *currentRoom = message.room;
    
    if (currentRoom.type == RoomTypeGroup || currentRoom.type == RoomTypeChannel ||  currentRoom.type == RoomTypeTransaction) {
        //Group / Channel
        isGroup = YES;
    }
    
    if (self.bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), 74.0f)];
        [self.contentView addSubview:self.bgView];
    }
    
    CGFloat leftPadding = 16.0f;
    CGFloat rightPadding = 16.0f;
    
    if (self.initialNameView == nil) {
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, 8.0f, 52.0f, 52.0f)];
        self.initialNameView.alpha = 0.0f;
        self.initialNameView.layer.cornerRadius = CGRectGetHeight(self.initialNameView.frame) / 2.0f;
        self.initialNameView.clipsToBounds = YES;
        [self.bgView addSubview:self.initialNameView];
    }
    
    if (self.initialNameLabel == nil) {
        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarMediumLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarMediumLabel];
        _initialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.initialNameView.frame), CGRectGetHeight(self.initialNameView.frame))];
        self.initialNameLabel.font = initialNameLabelFont;
        self.initialNameLabel.textColor = initialNameLabelColor;
        self.initialNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.initialNameView addSubview:self.initialNameLabel];
    }
    
    if (self.profileImageView == nil) {
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(leftPadding, 8.0f, 52.0f, 52.0f)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.backgroundColor = [UIColor clearColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2.0f;
        self.profileImageView.clipsToBounds = YES;
        [self.bgView addSubview:self.profileImageView];
    }
    
    if (self.deletedUserProfilImageView == nil) {
        _deletedUserProfilImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.profileImageView.frame) + 11.0f, CGRectGetMinY(self.profileImageView.frame) + 11.0f, 30.0f, 30.0f)];
        self.deletedUserProfilImageView.backgroundColor = [UIColor clearColor];
        self.deletedUserProfilImageView.image = [UIImage imageNamed:@"TAPIconDeletedUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.deletedUserProfilImageView.alpha = 0.0f;
        [self.bgView addSubview:self.deletedUserProfilImageView];
    }
    
    if (self.expertIconImageView == nil) {
        _expertIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 22.0f, CGRectGetMaxY(self.profileImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 0.0f;
        [self.bgView addSubview:self.expertIconImageView];
    }
    
    if (self.timeLabel == nil) {
        UIFont *roomListTimeLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListTime];
        UIColor *roomListTimeLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListTime];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - rightPadding, CGRectGetMinY(self.profileImageView.frame) + 4.0f, 0.0f, 16.0f)];
        self.timeLabel.textColor = roomListTimeLabelColor;
        self.timeLabel.font = roomListTimeLabelFont;
        [self.bgView addSubview:self.timeLabel];
    }
    
    if (self.muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.timeLabel.frame) - 4.0f, 0.0f, 0.0f, 13.0f)];
        self.muteImageView.alpha = 0.0f;
        self.muteImageView.image = [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.muteImageView.image = [self.muteImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMuted]];
        [self.bgView addSubview:self.muteImageView];
    }

    if (self.roomNameLabel == nil) {
        UIFont *roomListNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListName];
        UIColor *roomListNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListName];
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, 8.0f, CGRectGetMinX(self.muteImageView.frame) - CGRectGetMaxX(self.profileImageView.frame) - 4.0f - 8.0f, 20.0f)];
        self.roomNameLabel.textColor = roomListNameLabelColor;
        self.roomNameLabel.font = roomListNameLabelFont;
        [self.bgView addSubview:self.roomNameLabel];
        self.muteImageView.center = CGPointMake(self.muteImageView.center.x, self.roomNameLabel.center.y);
    }
    
    if (self.messageStatusImageView == nil) {
        _messageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgView.frame) - 16.0f - 20.0f, CGRectGetMaxY(self.bgView.frame) - 16.0f - 20.0f, 20.0f, 20.0f)];
        self.messageStatusImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.messageStatusImageView.alpha = 0.0f;
        [self.bgView addSubview:self.messageStatusImageView];
    }
    
    if (self.bubbleUnreadView == nil) {
        _bubbleUnreadView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, CGRectGetHeight(self.bgView.frame) - 18.0f - 20.0f, 0.0f, 20.0f)];
        self.bubbleUnreadView.clipsToBounds = YES;
        self.bubbleUnreadView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
        self.bubbleUnreadView.layer.cornerRadius = CGRectGetHeight(self.bubbleUnreadView.frame) / 2.0f;
        [self.bgView addSubview:self.bubbleUnreadView];
    }
    
    if (self.numberOfUnreadMessageLabel == nil) {
        UIFont *roomListUnreadBadgeLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListUnreadBadgeLabel];
        UIColor *roomListUnreadBadgeLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListUnreadBadgeLabel];
        _numberOfUnreadMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 3.0f, 0.0f, 13.0f)];
        self.numberOfUnreadMessageLabel.textColor = roomListUnreadBadgeLabelColor;
        self.numberOfUnreadMessageLabel.textAlignment = NSTextAlignmentCenter;
        self.numberOfUnreadMessageLabel.font = roomListUnreadBadgeLabelFont;
        [self.bubbleUnreadView addSubview:self.numberOfUnreadMessageLabel];
    }
    
    if (self.unreadMentionView == nil) {
        _unreadMentionView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bubbleUnreadView.frame) - 20.0f - 4.0f, CGRectGetHeight(self.bgView.frame) - 18.0f - 20.0f, 20.0f, 20.0f)];
        self.unreadMentionView.clipsToBounds = YES;
        self.unreadMentionView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
        self.unreadMentionView.layer.cornerRadius = CGRectGetHeight(self.unreadMentionView.frame) / 2.0f;
        self.unreadMentionView.alpha = 0.0f;
        [self.bgView addSubview:self.unreadMentionView];
    }

    if (self.unreadMentionImageView == nil) {
        _unreadMentionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0f, 3.0f, 14.0f, 14.0f)];
        self.unreadMentionImageView.image = [UIImage imageNamed:@"TAPIconMentionAnchor" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.unreadMentionImageView.image = [self.unreadMentionImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
        [self.unreadMentionView addSubview:self.unreadMentionImageView];
    }
    
    UIFont *roomListMessageLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListMessage];
    UIColor *roomListMessageLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListMessage];
    
    if (self.lastMessageLabel == nil) {
        _lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame) - 50.0f - 4.0f, 42.0f)];
        self.lastMessageLabel.textColor = roomListMessageLabelColor;
        self.lastMessageLabel.font = roomListMessageLabelFont;
        self.lastMessageLabel.numberOfLines = 2;
        [self.bgView addSubview:self.lastMessageLabel];
    }
    
    if (self.separatorView == nil) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.bgView addSubview:self.separatorView];
    }
    
    if (self.typingView == nil) {
        _typingView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame) + 2.0f, CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 16.0f)];
        self.typingView.backgroundColor = [UIColor clearColor];
        self.typingView.alpha = 0.0f;
        [self.bgView addSubview:self.typingView];
    }
    
    if (self.typingAnimationImageView == nil) {
        _typingAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        self.typingAnimationImageView.animationImages = @[[UIImage imageNamed:@"TAPTypingSequence-1" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-2" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-3" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-4" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-5" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-6" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-7" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-8" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-9" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-10" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-11" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-12" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-13" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-14" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-15" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-16" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        self.typingAnimationImageView.animationDuration = 0.6f;
        self.typingAnimationImageView.animationRepeatCount = 0.0f;
        [self.typingView addSubview:self.typingAnimationImageView];
    }
    
    if (self.typingLabel == nil) {
        _typingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.typingAnimationImageView.frame) + 4.0f, 0.0f, CGRectGetWidth(self.tableView.frame) - 76.0f - 45.0f, 16.0f)];
        self.typingLabel.text = NSLocalizedStringFromTableInBundle(@"typing", nil, [TAPUtil currentBundle], @"");
        self.typingLabel.font = roomListMessageLabelFont;
        self.typingLabel.textColor = roomListMessageLabelColor;
        [self.typingLabel sizeToFit];
        self.typingLabel.frame = CGRectMake(CGRectGetMaxX(self.typingAnimationImageView.frame) + 4.0f, 0.0f, CGRectGetWidth(self.typingLabel.frame), 16.0f);
        [self.typingView addSubview:self.typingLabel];
    }
    
    NSString *profileImageURL = @"";
     NSString *roomName = @"";
     if (message.room.type == RoomTypePersonal) {
         NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:currentRoom.roomID];
         TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
         if([message.room.deleted longValue] != 0) {
             profileImageURL = @"";
         }
         else if (obtainedUser != nil && ![obtainedUser.imageURL.thumbnail isEqualToString:@""]) {
             profileImageURL = obtainedUser.imageURL.thumbnail;
             profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
         }
         else {
             profileImageURL = message.room.imageURL.thumbnail;
             profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
         }
         
         if (obtainedUser != nil && obtainedUser.fullname != nil && [message.room.deleted longValue] == 0) {
             roomName = obtainedUser.fullname;
             roomName = [TAPUtil nullToEmptyString:roomName];
         }
         else {
             roomName = message.room.name;
             roomName = [TAPUtil nullToEmptyString:roomName];
         }
     }
     else if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
         TAPRoomModel *obtainedRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:message.room.roomID];
         NSString *groupProfileImageURL = obtainedRoom.imageURL.thumbnail;
         groupProfileImageURL = [TAPUtil nullToEmptyString:groupProfileImageURL];
         
         NSString *groupRoomName = obtainedRoom.name;
         groupRoomName = [TAPUtil nullToEmptyString:groupRoomName];
         
         if ([groupProfileImageURL isEqualToString:@""]) {
             profileImageURL = message.room.imageURL.thumbnail;
             profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
         }
         else {
             profileImageURL = groupProfileImageURL;
             profileImageURL = [TAPUtil nullToEmptyString:profileImageURL];
         }
         
         if ([groupRoomName isEqualToString:@""]) {
             roomName = message.room.name;
             roomName = [TAPUtil nullToEmptyString:roomName];
         }
         else {
             roomName = groupRoomName;
             roomName = [TAPUtil nullToEmptyString:roomName];
         }
     }
    
    if (isGroup) {
        TAPUserModel *currentActiveUser = [TAPDataManager getActiveUser];
        if ([currentActiveUser.userID isEqualToString:message.user.userID]) {
            lastSender = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
        }
        else {
            lastSender = message.user.fullname;
        }
    }
    
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
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        
        NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
        
        timeString = dateString;
    }
    
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
        else if (message.isDeleted) {
            statusType = TAPMessageStatusTypeDeleted;
        }
        else {
            statusType = TAPMessageStatusTypeSent;
        }
    }
    else {
        //last message is from other user
    }
    
    self.messageStatusType = statusType;
    
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:currentRoom.roomID];
    TAPUserModel *obtainedUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    
    if(message.room.deleted.longValue > 0 || obtainedUser.deleted.longValue > 0){
        //set deleted account profil pict
        self.initialNameView.alpha = 1.0f;
        self.profileImageView.alpha = 0.0f;
        self.deletedUserProfilImageView.alpha = 1.0f;
        self.initialNameView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
        self.initialNameLabel.text = @"";
    }
    else if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        //No photo found, get the initial
        self.initialNameView.alpha = 1.0f;
        self.profileImageView.alpha = 0.0f;
        self.deletedUserProfilImageView.alpha = 0.0f;
            self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:roomName];
            self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:roomName isGroup:isGroup];
    }
    else {
        self.initialNameView.alpha = 0.0f;
        self.profileImageView.alpha = 1.0f;
        self.deletedUserProfilImageView.alpha = 0.0f; 
        [self.profileImageView setImageWithURLString:profileImageURL];
    }
    
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
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, CGRectGetMinY(self.messageStatusImageView.frame), 0.0f, 0.0f);
    }
    else {
        //resize
        self.messageStatusImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 20.0f, CGRectGetMinY(self.messageStatusImageView.frame), 20.0f, 20.0f);
    }
    
    switch (self.messageStatusType) {
        case TAPMessageStatusTypeNone:
        {
            self.messageStatusImageView.alpha = 0.0f;
            break;
        }
        case TAPMessageStatusTypeSending:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageSending]];
            break;
        }
        case TAPMessageStatusTypeSent:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageSent]];
            break;
        }
        case TAPMessageStatusTypeDelivered:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageDelivered]];
            break;
        }
        case TAPMessageStatusTypeRead:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
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
                self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageDelivered]];
            }
            else {
                //Set to read icon
                self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconRead" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
                self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageRead]];
            }
            
            break;
        }
        case TAPMessageStatusTypeFailed:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconFailed" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageFailed]];
            break;
        }
        case TAPMessageStatusTypeDeleted:
        {
            if (numberOfUnreadMessage > 0 || message.type == TAPChatMessageTypeSystemMessage) {
                self.messageStatusImageView.alpha = 0.0f;
            }
            else {
                self.messageStatusImageView.alpha = 1.0f;
            }
            self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconBlock" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageDeleted]];
            break;
        }
        default:
            self.messageStatusImageView.alpha = 0.0f;
            break;
    }
    
    //Set body label
    NSString *lastMessage = @"";
    if (message.isDeleted) {
        NSString *lastMessageUserID = message.user.userID;
        if ([lastMessageUserID isEqualToString:currentUserID]) {
            //last message is from ourselves
            lastMessage = NSLocalizedStringFromTableInBundle(@"You deleted this message.", nil, [TAPUtil currentBundle], @"");
        }
        else {
            lastMessage = NSLocalizedStringFromTableInBundle(@"This message was deleted.", nil, [TAPUtil currentBundle], @"");
        }
        
        self.messageStatusImageView.image = [UIImage imageNamed:@"TAPIconBlock" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.messageStatusImageView.image = [self.messageStatusImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMessageDeleted]];
        
        if (numberOfUnreadMessage > 0 || isMarkedAsUnread) {
            self.messageStatusImageView.alpha = 0.0f;
            self.bubbleUnreadView.alpha = 1.0f;
        }
        else {
            self.bubbleUnreadView.alpha = 0.0f;
            self.messageStatusImageView.alpha = 1.0f;
        }
        
        if (numberOfUnreadMention > 0) {
            [self showUnreadMentionBadge:YES];
        }
        else {
            [self showUnreadMentionBadge:NO];
        }
    }
    else {
        
        lastMessage = message.body;
        
        //handle system message
        NSString *targetAction = message.action;
        TAPGroupTargetModel *groupTarget = message.target;
        NSString *targetName = groupTarget.targetName;
        targetName = [TAPUtil nullToEmptyString:targetName];
        
        if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            lastMessage = [lastMessage stringByReplacingOccurrencesOfString:@"{{sender}}" withString:@"You"];
            
        }
        else {
            lastMessage = [lastMessage stringByReplacingOccurrencesOfString:@"{{sender}}" withString:message.user.fullname];
        }
        
        if (groupTarget != nil) {
            if ([groupTarget.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                lastMessage = [lastMessage stringByReplacingOccurrencesOfString:@"{{target}}" withString:@"you"];
            }
            else {
                lastMessage = [lastMessage stringByReplacingOccurrencesOfString:@"{{target}}" withString:targetName];
            }
        }
    }
    
    //Check if cell is reused, force update unread bubble
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
        
        if(numberOfUnreadMention < 0) {
            numberOfUnreadMention = 0;
        }
        
        if (numberOfUnreadMessage == 0 && !isMarkedAsUnread) {
            self.bubbleUnreadView.alpha = 0.0f;
            self.bubbleUnreadView.frame = CGRectMake(CGRectGetMinX(self.messageStatusImageView.frame), CGRectGetMinY(self.messageStatusImageView.frame), CGRectGetWidth(self.messageStatusImageView.frame), CGRectGetHeight(self.bubbleUnreadView.frame));
            self.unreadMentionView.frame = CGRectMake(CGRectGetMinX(self.bubbleUnreadView.frame) - 20.0f - 4.0f, CGRectGetMinY(self.messageStatusImageView.frame), CGRectGetWidth(self.unreadMentionView.frame), CGRectGetHeight(self.unreadMentionView.frame));
        }
        else {
            if (numberOfUnreadMessage > 99) {
                self.numberOfUnreadMessageLabel.text = @"99+";
            }
            else {
                self.numberOfUnreadMessageLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessage];
            }
            
            if(isMarkedAsUnread && numberOfUnreadMessage == 0){
                self.numberOfUnreadMessageLabel.alpha = 0.0f;
            }
            else{
                self.numberOfUnreadMessageLabel.alpha = 1.0f;
            }
            
            //Bubble Number
            CGSize newNumberOfUnreadMessageLabelSize = [self.numberOfUnreadMessageLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.numberOfUnreadMessageLabel.frame))];
            
            //Bubble View
            CGFloat bubbleUnreadViewWidth = newNumberOfUnreadMessageLabelSize.width + 7.0f + 7.0f;
            CGFloat numberOfUnreadMessageLabelXPosition = 7.0f;
            
            if(bubbleUnreadViewWidth < CGRectGetHeight(self.bubbleUnreadView.frame)) {
                bubbleUnreadViewWidth = CGRectGetHeight(self.bubbleUnreadView.frame);
                newNumberOfUnreadMessageLabelSize = CGSizeMake(bubbleUnreadViewWidth - 7.0f - 7.0f, newNumberOfUnreadMessageLabelSize.height);
            }
            
            self.numberOfUnreadMessageLabel.frame = CGRectMake(numberOfUnreadMessageLabelXPosition, CGRectGetMinY(self.numberOfUnreadMessageLabel.frame), newNumberOfUnreadMessageLabelSize.width, CGRectGetHeight(self.numberOfUnreadMessageLabel.frame));
            
            self.bubbleUnreadView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - bubbleUnreadViewWidth, CGRectGetMinY(self.bubbleUnreadView.frame), bubbleUnreadViewWidth, CGRectGetHeight(self.bubbleUnreadView.frame));
            self.bubbleUnreadView.alpha = 1.0f;
            
            self.unreadMentionView.frame = CGRectMake(CGRectGetMinX(self.bubbleUnreadView.frame) - 20.0f - 4.0f, CGRectGetMinY(self.unreadMentionView.frame), CGRectGetWidth(self.unreadMentionView.frame), CGRectGetHeight(self.unreadMentionView.frame));
        }
        
        if (numberOfUnreadMention > 0) {
            [self showUnreadMentionBadge:YES];
        }
        else {
            [self showUnreadMentionBadge:NO];
        }
    }
    
    if (isGroup) {
        if (message.room.type != RoomTypeTransaction) {
            self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconGroup" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.expertIconImageView.alpha = 1.0f;
        }
            
        // Last Sender
//        self.lastSenderLabel.alpha = 1.0f;
//        self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.lastSenderLabel.frame), 16.0f);
//        self.lastSenderLabel.text = lastSender;
        
//        NSMutableDictionary *lastSenderAttributesDictionary = [NSMutableDictionary dictionary];
//        CGFloat lastSenderLetterSpacing = -0.2f;
//        [lastSenderAttributesDictionary setObject:@(lastSenderLetterSpacing) forKey:NSKernAttributeName];
//        NSMutableParagraphStyle *lastSenderStyle = [[NSMutableParagraphStyle alloc] init];
//        lastSenderStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//        [lastSenderStyle setLineSpacing:2];
//        [lastSenderAttributesDictionary setObject:lastSenderStyle forKey:NSParagraphStyleAttributeName];
//        NSMutableAttributedString *lastSenderAttributedString = [[NSMutableAttributedString alloc] initWithString:self.lastSenderLabel.text];
//        [lastSenderAttributedString addAttributes:lastSenderAttributesDictionary
//                                            range:NSMakeRange(0, [self.lastSenderLabel.text length])];
//        self.lastSenderLabel.attributedText = lastSenderAttributedString;
        
//        if (numberOfUnreadMessage > 0 && numberOfUnreadMention > 0) {
//            self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f - CGRectGetWidth(self.unreadMentionView.frame) - 4.0f, 16.0f);
//        }
//        else if (numberOfUnreadMessage > 0) {
//            self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f, 16.0f);
//        }
//        else {
//            self.lastSenderLabel.frame = CGRectMake(CGRectGetMinX(self.lastSenderLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f, 16.0f);
//        }
        
        NSString *senderFirstName = [[lastSender componentsSeparatedByString:@" "] objectAtIndex:0];
        
        // Last Message
//        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMaxY(self.lastSenderLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 20.0f);
        self.lastMessageLabel.numberOfLines = 1;
        if (message.isDeleted || message.type == TAPChatMessageTypeSystemMessage) {
            self.lastMessageLabel.text = lastMessage;
        }
        else {
            self.lastMessageLabel.text = [NSString stringWithFormat:@"%@: %@", senderFirstName, lastMessage];
        }
    }
    else {
        if (isExpert) {
            self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.expertIconImageView.alpha = 1.0f;
        }
        else {
            self.expertIconImageView.alpha = 0.0f;
        }
        
//        self.lastSenderLabel.alpha = 0.0f;
        
        // Last Message
        self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetWidth(self.lastMessageLabel.frame), 44.0f);
//        self.lastMessageLabel.numberOfLines = 2;
        self.lastMessageLabel.numberOfLines = 1;
        self.lastMessageLabel.text = lastMessage;
        
        // Typing View
        self.typingView.frame = CGRectMake(CGRectGetMinX(self.typingView.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.typingView.frame), CGRectGetHeight(self.typingView.frame));
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
    
    // Resize roomNameLabel & lastMessageLabel
    CGSize roomNameLabelSize = [self.roomNameLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.roomNameLabel.frame), CGFLOAT_MAX)];
    
    CGSize newLastMessageLabelSize = [self.lastMessageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f, CGRectGetHeight(self.lastMessageLabel.frame))];
    
    self.roomNameLabel.frame = CGRectMake(
        CGRectGetMinX(self.roomNameLabel.frame),
        (CGRectGetHeight(self.bgView.frame) - roomNameLabelSize.height - newLastMessageLabelSize.height - 4.0f) / 2,
        CGRectGetWidth(self.roomNameLabel.frame),
        CGRectGetHeight(self.roomNameLabel.frame)
    );
    
    CGFloat lastMessageLabelNewY = CGRectGetMaxY(self.roomNameLabel.frame) + 2.0f;
    
    if (numberOfUnreadMessage > 0 && numberOfUnreadMention > 0 && [[TapUI sharedInstance] isMentionUsernameEnabled]) {
        self.lastMessageLabel.frame = CGRectMake(
            CGRectGetMinX(self.lastMessageLabel.frame),
            lastMessageLabelNewY,
            CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f - CGRectGetWidth(self.unreadMentionView.frame) - 4.0f,
            newLastMessageLabelSize.height
        );
        
        self.typingView.frame = CGRectMake(CGRectGetMinX(self.typingView.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.typingView.frame), CGRectGetHeight(self.typingView.frame));
    }
    else if (numberOfUnreadMessage > 0) {
        self.lastMessageLabel.frame = CGRectMake(
            CGRectGetMinX(self.lastMessageLabel.frame),
            lastMessageLabelNewY,
            CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f - 8.0f,
            newLastMessageLabelSize.height
        );
        
        self.typingView.frame = CGRectMake(CGRectGetMinX(self.typingView.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.typingView.frame), CGRectGetHeight(self.typingView.frame));
    }
    else {
        self.lastMessageLabel.frame = CGRectMake(
            CGRectGetMinX(self.lastMessageLabel.frame),
            lastMessageLabelNewY,
            CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f,
            newLastMessageLabelSize.height
        );
        
        self.typingView.frame = CGRectMake(CGRectGetMinX(self.typingView.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.typingView.frame), CGRectGetHeight(self.typingView.frame));
    }
    
    [self setAsTyping:[[TAPChatManager sharedManager] checkIsTypingWithRoomID:roomList.lastMessage.room.roomID]];
}

- (void)setAsTyping:(BOOL)typing {
    if (typing) {
        [self refreshTypingLabelState];
        self.typingView.alpha = 1.0f;
        self.lastMessageLabel.alpha = 0.0f;
//        if (self.roomType != RoomTypePersonal) {
//            self.lastSenderLabel.alpha = 0.0f;
//        }
        
        [self.typingAnimationImageView startAnimating];
        [self performSelector:@selector(setAsTypingNoAfterDelay) withObject:nil afterDelay:15.0f];
    }
    else {
        self.typingView.alpha = 0.0f;
        self.lastMessageLabel.alpha = 1.0f;
//        if (self.roomType != RoomTypePersonal) {
//            self.lastSenderLabel.alpha = 1.0f;
//        }
        
        [self.typingAnimationImageView stopAnimating];
    }
}

- (void)setAsTypingNoAfterDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAsTypingNoAfterDelay) object:nil];
    self.typingView.alpha = 0.0f;
    [self.typingAnimationImageView stopAnimating];
    self.lastMessageLabel.alpha = 1.0f;
//    if (self.roomType != RoomTypePersonal) {
//        self.lastSenderLabel.alpha = 1.0f;
//    }
}

- (void)showMessageDraftWithMessage:(NSString *)draftMessage {
    self.messageStatusType = TAPMessageStatusTypeNone;
    self.messageStatusImageView.alpha = 0.0f;
    self.timeLabel.text = @"";
    
    self.lastMessageLabel.text = [NSString stringWithFormat:@"Draft: %@", draftMessage];

    NSMutableDictionary *lastMessageAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat lastMessageLetterSpacing = -0.2f;
    [lastMessageAttributesDictionary setObject:@(lastMessageLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *lastMessageStyle = [[NSMutableParagraphStyle alloc] init];
    lastMessageStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [lastMessageStyle setLineSpacing:2];
    [lastMessageAttributesDictionary setObject:lastMessageStyle forKey:NSParagraphStyleAttributeName];
    

    UIFont *roomListMessageLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListMessage];
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
    [attributesDictionary setObject:roomListMessageLabelFont forKey:NSFontAttributeName];
    [attributesDictionary setObject:[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError] forKey:NSForegroundColorAttributeName];
    [attributesDictionary setObject:lastMessageStyle forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *lastMessageAttributedString = [[NSMutableAttributedString alloc] initWithString:[TAPUtil nullToEmptyString:self.lastMessageLabel.text]];

    [lastMessageAttributedString addAttributes:lastMessageAttributesDictionary
                                         range:NSMakeRange(0, [self.lastMessageLabel.text length])];
    
    NSRange draftRange = [self.lastMessageLabel.text rangeOfString:@"Draft:"];
    [lastMessageAttributedString addAttributes:attributesDictionary
                                         range:draftRange];
    
    self.lastMessageLabel.attributedText = lastMessageAttributedString;
    
    //Resize lastMessageLabel
    CGSize newLastMessageLabelSize = [self.lastMessageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) -16.0f, CGRectGetHeight(self.lastMessageLabel.frame))];
    self.lastMessageLabel.frame = CGRectMake(CGRectGetMinX(self.lastMessageLabel.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.bgView.frame) - 76.0f - CGRectGetWidth(self.bubbleUnreadView.frame) - 16.0f, newLastMessageLabelSize.height);
    
    self.typingView.frame = CGRectMake(CGRectGetMinX(self.typingView.frame), CGRectGetMinY(self.lastMessageLabel.frame), CGRectGetWidth(self.typingView.frame), CGRectGetHeight(self.typingView.frame));
}

- (void)setIsLastCellSeparator:(BOOL)isLastCell {
    if (isLastCell) {
         self.separatorView.frame = CGRectMake(0.0f, CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame), 1.0f);
    }
    else {
        self.separatorView.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame), 1.0f);
    }
}

- (void)refreshTypingLabelState {
    if (self.roomType == RoomTypePersonal) {
        self.typingLabel.text = NSLocalizedStringFromTableInBundle(@"typing", nil, [TAPUtil currentBundle], @"");
    }
    else {
        NSDictionary *typingUserDictionary = [[TAPChatManager sharedManager] getTypingUsersWithRoomID:self.roomID];
        if ([typingUserDictionary count] == 0) {
            [self setAsTyping:NO];
        }
        else if ([typingUserDictionary count] == 1) {
            NSArray *values = [typingUserDictionary allValues];
            TAPUserModel *user = [values firstObject];
            NSString *fullName = user.fullname;
            NSArray *eachWordArray = [fullName componentsSeparatedByString:@" "];
            NSString *firstName = [eachWordArray objectAtIndex:0];
            self.typingLabel.text = [NSString stringWithFormat:@"%@ is typing", firstName];
        }
        else if ([typingUserDictionary count] > 1){
            self.typingLabel.text = [NSString stringWithFormat:@"%ld people are typing", [typingUserDictionary count]];
        }
    }
    [self.typingLabel sizeToFit];
    CGFloat typingLabelWidth = CGRectGetWidth(self.typingLabel.frame);
    if (typingLabelWidth > CGRectGetWidth(self.tableView.frame) - 76.0f - 45.0f - 4.0f - CGRectGetWidth(self.typingAnimationImageView.frame)) {
        typingLabelWidth = CGRectGetWidth(self.tableView.frame) - 76.0f - 45.0f - 4.0f - CGRectGetWidth(self.typingAnimationImageView.frame);
    }
    
    self.typingLabel.frame = CGRectMake(CGRectGetMaxX(self.typingAnimationImageView.frame) + 4.0f, 0.0f, typingLabelWidth, 16.0f);
}

- (void)showUnreadMentionBadge:(BOOL)isShow {
    if (isShow && [[TapUI sharedInstance] isMentionUsernameEnabled]) {
        self.unreadMentionView.alpha = 1.0f;
    }
    else {
        self.unreadMentionView.alpha = 0.0f;
    }
}

@end

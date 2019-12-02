//
//  TAPSearchResultChatTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 22/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchResultChatTableViewCell.h"
#import "TAPRoomListModel.h"
@interface TAPSearchResultChatTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIView *bubbleUnreadView;
@property (strong, nonatomic) UIView *onlineStatusView;
@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *profileImageView;
@property (strong, nonatomic) UIImageView *expertIconImageView;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UILabel *roomNameLabel;
@property (strong, nonatomic) UILabel *numberOfUnreadMessageLabel;
@property (strong, nonatomic) UILabel *onlineStatusLabel;

@end

@implementation TAPSearchResultChatTableViewCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 70.0f)];
        [self.contentView addSubview:self.bgView];
        
        CGFloat leftPadding = 16.0f;
        CGFloat rightPadding = 16.0f;
        
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, 9.0f, 52.0f, 52.0f)];
        self.initialNameView.alpha = 0.0f;
        self.initialNameView.layer.cornerRadius = CGRectGetHeight(self.initialNameView.frame) / 2.0f;
        self.initialNameView.clipsToBounds = YES;
        [self.bgView addSubview:self.initialNameView];
        
        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarMediumLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarMediumLabel];
        _initialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.initialNameView.frame), CGRectGetHeight(self.initialNameView.frame))];
        self.initialNameLabel.font = initialNameLabelFont;
        self.initialNameLabel.textColor = initialNameLabelColor;
        self.initialNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.initialNameView addSubview:self.initialNameLabel];
        
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(leftPadding, 9.0f, 52.0f, 52.0f)];
        self.profileImageView.backgroundColor = [UIColor clearColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2.0f;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgView addSubview:self.profileImageView];
        
        _expertIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 22.0f, CGRectGetMaxY(self.profileImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 0.0f;
        [self.bgView addSubview:self.expertIconImageView];
        
        _bubbleUnreadView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, 25.0f, 0.0f, 20.0f)];
        self.bubbleUnreadView.clipsToBounds = YES;
        self.bubbleUnreadView.layer.cornerRadius = CGRectGetHeight(self.bubbleUnreadView.frame) / 2.0f;
        self.bubbleUnreadView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
        [self.bgView addSubview:self.bubbleUnreadView];
        
        UIFont *roomListUnreadBadgeLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListUnreadBadgeLabel];
        UIColor *roomListUnreadBadgeLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListUnreadBadgeLabel];
        _numberOfUnreadMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 3.0f, 0.0f, 13.0f)];
        self.numberOfUnreadMessageLabel.textColor = roomListUnreadBadgeLabelColor;
        self.numberOfUnreadMessageLabel.font = roomListUnreadBadgeLabelFont;
        [self.bubbleUnreadView addSubview:self.numberOfUnreadMessageLabel];
        
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgView.frame) - rightPadding, 0.0f, 0.0f, 13.0f)];
        self.muteImageView.alpha = 0.0f;
        self.muteImageView.image = [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.muteImageView.image = [self.muteImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRoomListMuted]];
        [self.bgView addSubview:self.muteImageView];
        
        UIFont *roomListNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomListName];
        UIColor *roomListNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListName];
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, 25.0f, CGRectGetMinX(self.muteImageView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), 20.0f)];
        self.roomNameLabel.textColor = roomListNameLabelColor;
        self.roomNameLabel.font = roomListNameLabelFont;
        [self.bgView addSubview:self.roomNameLabel];
        self.muteImageView.center = CGPointMake(self.muteImageView.center.x, self.roomNameLabel.center.y);
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.bgView addSubview:self.separatorView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.onlineStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
    self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.onlineStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
    self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
}

#pragma mark - Custom Methods
- (void)setSearchResultChatTableViewCellWithData:(TAPRoomModel *)room
                                  searchedString:(NSString *)searchedString
                          numberOfUnreadMessages:(NSString *)unreadMessageCount {
    searchedString = [searchedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //DV Temp
    BOOL isExpert = NO;
    BOOL isMuted = NO;
    BOOL isOnline = NO;
    //END DV Temp
    
    BOOL isGroup = NO;
    if (room.type == RoomTypeGroup || room.type == RoomTypeChannel) {
        isGroup = YES;
    }
    
    NSString *profileImageURL = room.imageURL.fullsize;
    NSInteger numberOfUnreadMessage = [unreadMessageCount integerValue];
    
    TAPRoomModel *currentRoom = room;
    
    NSString *roomName = currentRoom.name;
    roomName = [TAPUtil nullToEmptyString:roomName];
    
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        //No photo found, get the initial
        self.initialNameView.alpha = 1.0f;
        self.profileImageView.alpha = 0.0f;
        self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:roomName];
        self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:roomName isGroup:isGroup];
    }
    else {
        self.initialNameView.alpha = 0.0f;
        self.profileImageView.alpha = 1.0f;
        [self.profileImageView setImageWithURLString:profileImageURL];
    }
    
    if (numberOfUnreadMessage == 0) {
        self.bubbleUnreadView.alpha = 0.0f;
        self.bubbleUnreadView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, CGRectGetMinY(self.bgView.frame), 0.0f, CGRectGetHeight(self.bubbleUnreadView.frame));
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
        
        //Bubble View
        CGFloat bubbleUnreadViewWidth = newNumberOfUnreadMessageLabelSize.width + 7.0f + 7.0f;
        CGFloat numberOfUnreadMessageLabelXPosition = 7.0f;

        self.numberOfUnreadMessageLabel.frame = CGRectMake(numberOfUnreadMessageLabelXPosition, CGRectGetMinY(self.numberOfUnreadMessageLabel.frame), newNumberOfUnreadMessageLabelSize.width, CGRectGetHeight(self.numberOfUnreadMessageLabel.frame));
        
        self.bubbleUnreadView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - bubbleUnreadViewWidth, CGRectGetMinY(self.bubbleUnreadView.frame), bubbleUnreadViewWidth, CGRectGetHeight(self.bubbleUnreadView.frame));
        self.bubbleUnreadView.alpha = 1.0f;
    }
    
    //MUTE IMAGE VIEW
    if (isMuted) {
        if (numberOfUnreadMessage == 0) {
            self.muteImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 10.0f, CGRectGetMinY(self.muteImageView.frame), 10.0f, CGRectGetHeight(self.muteImageView.frame));
        }
        else {
            self.muteImageView.frame = CGRectMake(CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - 10.0f, CGRectGetMinY(self.muteImageView.frame), 10.0f, CGRectGetHeight(self.muteImageView.frame));
        }
        self.muteImageView.alpha = 1.0f;
    }
    else {
        self.muteImageView.frame = CGRectMake(CGRectGetMinX(self.bubbleUnreadView.frame), CGRectGetMinY(self.muteImageView.frame), 0.0f, CGRectGetHeight(self.muteImageView.frame));
        self.muteImageView.alpha = 0.0f;
    }
    
    if (isGroup) {
        
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconGroup" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 1.0f;
        
        //DV Temp -  Adding how many people online in here for group
        if (isOnline) {
            self.onlineStatusView.alpha = 1.0f;
            self.onlineStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.onlineStatusView.frame) + 3.0f, CGRectGetMinY(self.onlineStatusLabel.frame), CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - (CGRectGetMaxX(self.onlineStatusView.frame) + 3.0f), CGRectGetHeight(self.onlineStatusLabel.frame));
            self.onlineStatusLabel.text = @"Active now";
        }
        else {
            self.onlineStatusView.alpha = 0.0f;
            self.onlineStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), 20.0f);
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
        
        if (isOnline) {
            self.onlineStatusView.alpha = 1.0f;
            self.onlineStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.onlineStatusView.frame) + 3.0f, CGRectGetMinY(self.onlineStatusLabel.frame), CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - (CGRectGetMaxX(self.onlineStatusView.frame) + 3.0f), CGRectGetHeight(self.onlineStatusLabel.frame));
            self.onlineStatusLabel.text = @"Active now";
        }
        else {
            self.onlineStatusView.alpha = 0.0f;
            self.onlineStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), 20.0f);
        }
    }
    
    //ROOM NAME LABEL
    self.roomNameLabel.text = roomName;
    
    NSString *lowercaseSeachedString = [searchedString lowercaseString];
    NSString *lowercaseRoomName = [roomName lowercaseString];
    NSMutableDictionary *roomNameAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat roomNameLetterSpacing = -0.2f;
    [roomNameAttributesDictionary setObject:@(roomNameLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *roomNameStyle = [[NSMutableParagraphStyle alloc] init];
    roomNameStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [roomNameAttributesDictionary setObject:roomNameStyle forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *roomNameAttributedString = [[NSMutableAttributedString alloc] initWithString:self.roomNameLabel.text];
    [roomNameAttributedString addAttributes:roomNameAttributesDictionary
                                      range:NSMakeRange(0, [self.roomNameLabel.text length])];
    
    //CS NOTE - uncomment to use trimmed string
//    //WK Note - Create nonAlphaNumericCharacters
//    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
//    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
//    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
//
//    NSString *alphaNumericSearchedString = [[lowercaseSeachedString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
//    //End Note
    
    UIColor *roomNameHighlightedColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomListNameHighlighted];
    NSRange searchedRange = [lowercaseRoomName rangeOfString:lowercaseSeachedString];
    [roomNameAttributedString addAttribute:NSForegroundColorAttributeName
                                     value:roomNameHighlightedColor
                                     range:searchedRange];
    
    self.roomNameLabel.attributedText = roomNameAttributedString;
    self.roomNameLabel.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMinY(self.roomNameLabel.frame), CGRectGetMinX(self.muteImageView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), CGRectGetHeight(self.roomNameLabel.frame));
}

- (void)hideSeparatorView:(BOOL)isHide {
    if (isHide) {
        self.separatorView.alpha = 0.0f;
    }
    else {
        self.separatorView.alpha = 1.0f;
    }
}

@end

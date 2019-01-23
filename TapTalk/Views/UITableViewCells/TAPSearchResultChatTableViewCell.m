//
//  TAPSearchResultChatTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 22/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchResultChatTableViewCell.h"
#import "TAPRoomListModel.h"
@interface TAPSearchResultChatTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIView *bubbleUnreadView;
@property (strong, nonatomic) UIView *onlineStatusView;
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
        _profileImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(leftPadding, 9.0f, 52.0f, 52.0f)];
        self.profileImageView.backgroundColor = [UIColor clearColor];
        self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.frame) / 2.0f;
        self.profileImageView.clipsToBounds = YES;
        [self.bgView addSubview:self.profileImageView];
        
        _expertIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) - 22.0f, CGRectGetMaxY(self.profileImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertIconImageView.alpha = 0.0f;
        [self.bgView addSubview:self.expertIconImageView];
        
        _bubbleUnreadView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f, 25.0f, 0.0f, 20.0f)];
        self.bubbleUnreadView.clipsToBounds = YES;
        self.bubbleUnreadView.layer.cornerRadius = CGRectGetHeight(self.bubbleUnreadView.frame) / 2.0f;
        [self.bgView addSubview:self.bubbleUnreadView];
        
        _numberOfUnreadMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 3.0f, 0.0f, 13.0f)];
        self.numberOfUnreadMessageLabel.textColor = [UIColor whiteColor];
        self.numberOfUnreadMessageLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        [self.bubbleUnreadView addSubview:self.numberOfUnreadMessageLabel];
        
        _muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgView.frame) - rightPadding, 0.0f, 0.0f, 13.0f)];
        self.muteImageView.alpha = 0.0f;
        self.muteImageView.image = [UIImage imageNamed:@"TAPIconMute" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bgView addSubview:self.muteImageView];
        
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, 25.0f, CGRectGetMinX(self.muteImageView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), 20.0f)];
        self.roomNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.roomNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        [self.bgView addSubview:self.roomNameLabel];
        self.muteImageView.center = CGPointMake(self.muteImageView.center.x, self.roomNameLabel.center.y);
        
        //WK Note - Not being used in this feature
//        _onlineStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, CGRectGetMaxY(self.roomNameLabel.frame), CGRectGetMinX(self.bubbleUnreadView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), 20.0f)];
//        self.onlineStatusLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
//        self.onlineStatusLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
//        [self.bgView addSubview:self.onlineStatusLabel];
//
//        _onlineStatusView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 8.0f, CGRectGetMaxY(self.roomNameLabel.frame) + 6.0f, 8.0f, 8.0f)];
//        self.onlineStatusView.alpha = 0.0f;
//        self.onlineStatusView.layer.cornerRadius = CGRectGetHeight(self.onlineStatusView.frame) / 2.0f;
//        self.onlineStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
//        [self.bgView addSubview:self.onlineStatusView];
        //END Note
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.roomNameLabel.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_EA];
        [self.bgView addSubview:self.separatorView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.onlineStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
    self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_EA];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.onlineStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
    self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_EA];
}

#pragma mark - Custom Methods
- (void)setSearchResultChatTableViewCellWithData:(TAPRoomModel *)room
                                  searchedString:(NSString *)searchedString
                          numberOfUnreadMessages:(NSString *)unreadMessageCount {
    searchedString = [searchedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //DV Temp
    BOOL isExpert = NO;
    BOOL isGroup = NO;
    BOOL isMuted = NO;
    BOOL isOnline = NO;
    NSString *profileImageURL = room.imageURL.thumbnail;
    //END DV Temp
    
    NSInteger numberOfUnreadMessage = [unreadMessageCount integerValue];
    
    TAPRoomModel *currentRoom = room;
    
    NSString *roomName = currentRoom.name;
    roomName = [TAPUtil nullToEmptyString:roomName];
    
    [self.profileImageView setImageWithURLString:profileImageURL];
    
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
        self.onlineStatusLabel.text = @"76 members";
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
            
            self.onlineStatusLabel.text = @"Active 6 minutes ago";
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
    //WK Note - Create nonAlphaNumericCharacters
    NSMutableCharacterSet *nonAlphaNumericCharacters = [[NSMutableCharacterSet alloc] init];
    [nonAlphaNumericCharacters formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    [nonAlphaNumericCharacters removeCharactersInString:@" "]; //Remove space from nonAlphaNumericCharacters
    
    NSString *alphaNumericSearchedString = [[lowercaseSeachedString componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""]; //Remove all string that is nonAlphaNumericCharacters
    //End Note
    
    NSRange searchedRange = [lowercaseRoomName rangeOfString:alphaNumericSearchedString];
    [roomNameAttributedString addAttribute:NSForegroundColorAttributeName
                                     value:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93]
                                     range:searchedRange];
    
    self.roomNameLabel.attributedText = roomNameAttributedString;
    self.roomNameLabel.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMinY(self.roomNameLabel.frame), CGRectGetMinX(self.muteImageView.frame) - 4.0f - (CGRectGetMaxX(self.profileImageView.frame) + 8.0f), CGRectGetHeight(self.roomNameLabel.frame));
}

@end

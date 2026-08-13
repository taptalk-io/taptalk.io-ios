//
//  TAPContactTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactTableViewCell.h"
#import "PowerTalk.h"

@interface TAPContactTableViewCell ()

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *contactImageView;
@property (strong, nonatomic) UIImageView *expertLogoImageView;
@property (strong, nonatomic) UILabel *contactNameLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *adminIndicatorLabel;
@property (strong, nonatomic) UIView *separatorView;

@property (strong, nonatomic) UILabel *deliveredToLabel;
@property (strong, nonatomic) UILabel *readByLabel;

@property (strong, nonatomic) UIView *nonSelectedView;
@property (strong, nonatomic) UIImageView *selectedImageView;

- (void)resizeCell;

@end

@implementation TAPContactTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 64.0f)];
        [self.contentView addSubview:self.bgView];
        
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 6.0f, 52.0f, 52.0f)];
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
        
        _contactImageView = [[TAPImageView alloc] initWithFrame:self.initialNameView.frame];
        self.contactImageView.backgroundColor = [UIColor clearColor];
        self.contactImageView.layer.cornerRadius = CGRectGetHeight(self.contactImageView.frame) / 2.0f;
        self.contactImageView.clipsToBounds = YES;
        self.contactImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgView addSubview:self.contactImageView];
        
        _expertLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) - 22.0f, CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.expertLogoImageView.image = [UIImage imageNamed:@"TAPIconExpert" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.expertLogoImageView.alpha = 0.0f;
        [self.bgView addSubview:self.expertLogoImageView];
        
        UIFont *contactNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontContactListName];
        UIColor *contactNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListName];
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, 0.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), CGRectGetHeight(self.bgView.frame))];
        self.contactNameLabel.textColor = contactNameLabelColor;
        self.contactNameLabel.font = contactNameLabelFont;
        [self.bgView addSubview:self.contactNameLabel];

        UIFont *contactUsernameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontContactListUsername];
        UIColor *contactUsernameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListUsername];
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), 0.0f, CGRectGetWidth(self.contactNameLabel.frame), CGRectGetHeight(self.bgView.frame))];
        self.usernameLabel.textColor = contactUsernameLabelColor;
        self.usernameLabel.font = contactUsernameLabelFont;
        [self.bgView addSubview:self.usernameLabel];
        
        _adminIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), 20.0f)];
        //CS NOTE TO DOM - check style
        self.adminIndicatorLabel.textColor = [TAPUtil getColor:@"9b9b9b"];
        self.adminIndicatorLabel.font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:14.0f];
        self.adminIndicatorLabel.alpha = 0.0f;
        self.adminIndicatorLabel.text = NSLocalizedStringFromTableInBundle(@"Admin", nil, [TAPUtil currentBundle], @"");
        [self.bgView addSubview:self.adminIndicatorLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.contactNameLabel.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.bgView addSubview:self.separatorView];
        
        _nonSelectedView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 24.0f, 16.0f, 16.0f)];
        self.nonSelectedView.layer.cornerRadius = CGRectGetHeight(self.nonSelectedView.frame) / 2.0f;
        self.nonSelectedView.layer.borderWidth = 1.0f;
        self.nonSelectedView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconCircleSelectionInactive].CGColor;
        self.nonSelectedView.clipsToBounds = YES;
        self.nonSelectedView.alpha = 0.0f;
        [self.bgView addSubview:self.nonSelectedView];
        
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 24.0f, 16.0f, 16.0f)];
        self.selectedImageView.image = [UIImage imageNamed:@"TAPIconSuccessSent" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.selectedImageView.image = [self.selectedImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconCircleSelectionActive]];
        self.selectedImageView.alpha = 0.0f;
        self.selectedImageView.center = self.nonSelectedView.center;
        [self.bgView addSubview:self.selectedImageView];
        
        CGFloat deliveredToWidth = 80.0f;
        CGFloat deliveredToHeight = 16.0f;
        UIFont *deliveredToFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomDeliveredToLabel];
        _deliveredToLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - deliveredToWidth - 12.0f, (CGRectGetHeight(self.bgView.frame) - deliveredToHeight) /2, deliveredToWidth, 16.0f)];
        self.deliveredToLabel.text = @"dwedw";
        self.deliveredToLabel.font = deliveredToFont;
        self.deliveredToLabel.alpha = 0.0f;
        [self.bgView addSubview:self.deliveredToLabel];
        
        _readByLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - deliveredToWidth - 12.0f, (CGRectGetHeight(self.bgView.frame) - deliveredToHeight) /2, deliveredToWidth, 16.0f)];
        self.readByLabel.text = @"dwedw";
        self.readByLabel.font = deliveredToFont;
        self.readByLabel.alpha = 0.0f;
        [self.bgView addSubview:self.readByLabel];
        
        [self showAdminIndicator:NO];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contactImageView.image = nil;
    self.selectedImageView.alpha = 0.0f;
    self.nonSelectedView.alpha = 0.0f;
    [self showAdminIndicator:NO];
}

#pragma mark - Custom Method
- (void)setContactTableViewCellWithUser:(TAPUserModel *)user {
    if (user.userID != nil) {
        NSString *contactName = user.fullname;
        contactName = [TAPUtil nullToEmptyString:contactName];
        
        NSString *usernameString = user.username;
        usernameString = [TAPUtil nullToEmptyString:usernameString];
        NSString *contactUsername = [NSString stringWithFormat:@"@%@", usernameString];

        NSString *imageURL = user.imageURL.fullsize;
        if (imageURL == nil || [imageURL isEqualToString:@""]) {
            if(user.deleted.longValue > 0){
                //set deleted account profil pict
                self.initialNameView.alpha = 1.0f;
                self.contactImageView.alpha = 1.0f;
                self.initialNameView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
                self.initialNameLabel.text = @"";
                self.contactImageView.image = [UIImage imageNamed:@"TAPIconDeletedUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            }
            else{
                //No photo found, get the initial
                self.initialNameView.alpha = 1.0f;
                self.contactImageView.alpha = 0.0f;
                self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:contactName];
                self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:contactName isGroup:NO];
            }
        }
        else {
            self.initialNameView.alpha = 0.0f;
            self.contactImageView.alpha = 1.0f;
            [self.contactImageView setImageWithURLString:imageURL];
        }
        
        NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactNameLetterSpacing = -0.2f;
        [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
        [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                             range:NSMakeRange(0, [contactName length])];
        self.contactNameLabel.attributedText = contactNameAttributedString;
        
        NSMutableDictionary *contactUsernameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactUsernameLetterSpacing = -0.2f;
        [contactUsernameAttributesDictionary setObject:@(contactUsernameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactUsernameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactUsername];
        [contactUsernameAttributedString addAttributes:contactUsernameAttributesDictionary
                                                 range:NSMakeRange(0, [contactUsername length])];
        self.usernameLabel.attributedText = contactUsernameAttributedString;
    }
    
    if (self.contactTableViewCellType == TAPContactTableViewCellTypeWithUsername) {
        if (user.username == nil || [user.username isEqualToString:@""]) {
            //Set UI to cell without username because username is empty even the type is with username
            self.usernameLabel.alpha = 0.0f;
            self.bgView.frame = CGRectMake(CGRectGetMinX(self.bgView.frame), CGRectGetMinY(self.bgView.frame), CGRectGetWidth(self.bgView.frame), 64.0f);
            self.contactImageView.frame = CGRectMake(CGRectGetMinX(self.contactImageView.frame), CGRectGetMinY(self.contactImageView.frame), CGRectGetWidth(self.contactImageView.frame), CGRectGetHeight(self.contactImageView.frame));
            self.expertLogoImageView.frame = CGRectMake(CGRectGetMinX(self.expertLogoImageView.frame), CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f);
            self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), 15.0f, CGRectGetWidth(self.contactNameLabel.frame), 34.0f);
            self.usernameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.usernameLabel.frame), 0.0f);
        }
        else {
            self.usernameLabel.alpha = 1.0f;
        }
    }
    else {
        self.usernameLabel.alpha = 0.0f;
    }
}

- (void)setContactTableViewCellWithRoom:(TAPRoomModel *)room {
    if (room.roomID != nil) {
        NSString *contactName = room.name;
        contactName = [TAPUtil nullToEmptyString:contactName];
        
        NSString *usernameString = room.name;
        usernameString = [TAPUtil nullToEmptyString:usernameString];
        NSString *contactUsername = [NSString stringWithFormat:@"@%@", usernameString];

        NSString *imageURL = room.imageURL.fullsize;
        if (imageURL == nil || [imageURL isEqualToString:@""]) {
            if(room.deleted.longValue > 0){
                //set deleted account profil pict
                self.initialNameView.alpha = 1.0f;
                self.contactImageView.alpha = 1.0f;
                self.initialNameView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
                self.initialNameLabel.text = @"";
                self.contactImageView.image = [UIImage imageNamed:@"TAPIconDeletedUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            }
            else{
                //No photo found, get the initial
                self.initialNameView.alpha = 1.0f;
                self.contactImageView.alpha = 0.0f;
                self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:contactName];
                self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:contactName isGroup:NO];
            }
        }
        else {
            self.initialNameView.alpha = 0.0f;
            self.contactImageView.alpha = 1.0f;
            [self.contactImageView setImageWithURLString:imageURL];
        }
        
        if (room.type == RoomTypeGroup || room.type == RoomTypeChannel ||  room.type == RoomTypeTransaction) {
            //Group / Channel
            self.expertLogoImageView.image = [UIImage imageNamed:@"TAPIconGroup" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.expertLogoImageView.alpha = 1.0f;
        }
        
        NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactNameLetterSpacing = -0.2f;
        [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
        [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                             range:NSMakeRange(0, [contactName length])];
        self.contactNameLabel.attributedText = contactNameAttributedString;
        
        NSMutableDictionary *contactUsernameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactUsernameLetterSpacing = -0.2f;
        [contactUsernameAttributesDictionary setObject:@(contactUsernameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactUsernameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactUsername];
        [contactUsernameAttributedString addAttributes:contactUsernameAttributesDictionary
                                                 range:NSMakeRange(0, [contactUsername length])];
        self.usernameLabel.attributedText = contactUsernameAttributedString;
    }
    
    if (self.contactTableViewCellType == TAPContactTableViewCellTypeWithUsername) {
        if (room.name == nil || [room.name isEqualToString:@""]) {
            //Set UI to cell without username because username is empty even the type is with username
            self.usernameLabel.alpha = 0.0f;
            self.bgView.frame = CGRectMake(CGRectGetMinX(self.bgView.frame), CGRectGetMinY(self.bgView.frame), CGRectGetWidth(self.bgView.frame), 64.0f);
            self.contactImageView.frame = CGRectMake(CGRectGetMinX(self.contactImageView.frame), CGRectGetMinY(self.contactImageView.frame), CGRectGetWidth(self.contactImageView.frame), CGRectGetHeight(self.contactImageView.frame));
            self.expertLogoImageView.frame = CGRectMake(CGRectGetMinX(self.expertLogoImageView.frame), CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f);
            self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), 15.0f, CGRectGetWidth(self.contactNameLabel.frame), 34.0f);
            self.usernameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.usernameLabel.frame), 0.0f);
        }
        else {
            self.usernameLabel.alpha = 1.0f;
        }
    }
    else {
        self.usernameLabel.alpha = 0.0f;
    }
}

- (void)isRequireSelection:(BOOL)isRequired {
    if (isRequired) {
        //resize
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f - 8.0f - CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.contactNameLabel.frame));
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        //resize
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.contactNameLabel.frame));
//        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}

- (void)isCellSelected:(BOOL)isSelected {
    if (isSelected) {
        self.nonSelectedView.alpha = 0.0f;
        self.selectedImageView.alpha = 1.0f;
    }
    else {
        self.nonSelectedView.alpha = 1.0f;
        self.selectedImageView.alpha = 0.0f;
    }
}

- (void)showBlockedContactIcon:(BOOL)isShow {
    self.selectedImageView.image = [UIImage imageNamed:@"TAPIconMinusCircle" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.selectedImageView.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - 24.0f - 16.0f, 20.0f, 24.0f, 24.0f);
    if(isShow) {
        self.selectedImageView.alpha = 1.0f;
        [self isRequireSelection:YES];
    }
    else {
        self.selectedImageView.alpha = 0.0f;
        [self isRequireSelection:NO];
    }
}

- (void)showSeparatorLine:(BOOL)isVisible separatorLineType:(TAPContactTableViewCellSeparatorType)separatorType {
    if (isVisible) {
        if (separatorType == TAPContactTableViewCellSeparatorTypeDefault) {
            self.separatorView.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame) - CGRectGetMinX(self.contactNameLabel.frame), 1.0f);
        }
        else {
            self.separatorView.frame = CGRectMake(0.0f, CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame), 1.0f);

        }
        self.separatorView.alpha = 1.0f;
    }
    else {
        self.separatorView.alpha = 0.0f;
    }
}

- (void)showAdminIndicator:(BOOL)show {
    if (show) {
        self.adminIndicatorLabel.alpha = 1.0f;
        self.contactNameLabel.frame = CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, 11.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), 20.0f);
        self.adminIndicatorLabel.frame = CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), 20.0f);
    }
    else {
        self.adminIndicatorLabel.alpha = 0.0f;
        self.contactNameLabel.frame = CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, 0.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), CGRectGetHeight(self.bgView.frame));
        self.adminIndicatorLabel.frame = CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), 20.0f);
    }
}

- (void)showDeliveredTo:(NSString *)deliveredTime {
    self.deliveredToLabel.text = [NSString stringWithFormat:@"delivered %@", deliveredTime];
    [self.deliveredToLabel sizeToFit];
    CGFloat deliveredToWidth = CGRectGetWidth(self.deliveredToLabel.frame);
    CGFloat deliveredToHeight = CGRectGetHeight(self.deliveredToLabel.frame);
    self.deliveredToLabel.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - deliveredToWidth - 12.0f, (CGRectGetHeight(self.bgView.frame) - deliveredToHeight) /2, deliveredToWidth, 16.0f);
    self.deliveredToLabel.alpha = 1.0f;
    self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.contactNameLabel.frame) - deliveredToWidth, CGRectGetHeight(self.contactNameLabel.frame));
    
    NSArray *deliveredTimerray = [deliveredTime componentsSeparatedByString:@"•"];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.deliveredToLabel.text];
    NSString *deliveredTimeString = [deliveredTimerray objectAtIndex:1];
    NSRange opsionalStringRange = [self.deliveredToLabel.text rangeOfString:deliveredTimeString];
    UIFont *timeFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaListInfoLabel];
    [mutableAttributedString addAttribute:NSFontAttributeName
                                    value:timeFont
                                    range:opsionalStringRange];
    self.deliveredToLabel.attributedText = mutableAttributedString;
}

- (void)showReadBy:(NSString *)deliveredTime readTime:(NSString *)readTime {
    self.deliveredToLabel.text = [NSString stringWithFormat:@"delivered %@", deliveredTime];
    [self.deliveredToLabel sizeToFit];
    CGFloat deliveredToWidth = CGRectGetWidth(self.deliveredToLabel.frame);
    CGFloat deliveredToHeight = CGRectGetHeight(self.deliveredToLabel.frame);
    self.deliveredToLabel.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - deliveredToWidth - 12.0f, CGRectGetHeight(self.bgView.frame) - deliveredToHeight - 12.0f, deliveredToWidth, 16.0f);
    self.deliveredToLabel.alpha = 1.0f;
    
    self.readByLabel.text = [NSString stringWithFormat:@"read %@", readTime];
    [self.readByLabel sizeToFit];
    CGFloat readToWidth = CGRectGetWidth(self.readByLabel.frame);
    self.readByLabel.frame = CGRectMake(CGRectGetWidth(self.bgView.frame) - readToWidth - 12.0f, 12.0f, readToWidth, 16.0f);
    self.readByLabel.alpha = 1.0f;
    
    self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.contactNameLabel.frame) - deliveredToWidth, CGRectGetHeight(self.contactNameLabel.frame));
    
    
    NSArray *deliveredTimerray = [deliveredTime componentsSeparatedByString:@"•"];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.deliveredToLabel.text];
    NSString *deliveredTimeString = [deliveredTimerray objectAtIndex:1];
    NSRange opsionalStringRange = [self.deliveredToLabel.text rangeOfString:deliveredTimeString];
    UIFont *timeFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMediaListInfoLabel];
    [mutableAttributedString addAttribute:NSFontAttributeName
                                    value:timeFont
                                    range:opsionalStringRange];
    self.deliveredToLabel.attributedText = mutableAttributedString;
    
    NSArray *readbyTimerray = [readTime componentsSeparatedByString:@"•"];
    NSMutableAttributedString *mutableAttributedStringReadby = [[NSMutableAttributedString alloc] initWithString:self.readByLabel.text];
    NSString *readbyTimeString = [readbyTimerray objectAtIndex:1];
    NSRange readbyStringRange = [self.readByLabel.text rangeOfString:readbyTimeString];
    [mutableAttributedStringReadby addAttribute:NSFontAttributeName
                                    value:timeFont
                                    range:readbyStringRange];
    self.readByLabel.attributedText = mutableAttributedStringReadby;
}

- (void)resizeCell {
    self.bgView.frame = CGRectMake(CGRectGetMinX(self.bgView.frame), CGRectGetMinY(self.bgView.frame), CGRectGetWidth(self.bgView.frame), 64.0f);

    self.contactImageView.frame = CGRectMake(CGRectGetMinX(self.contactImageView.frame), CGRectGetMinY(self.contactImageView.frame), CGRectGetWidth(self.contactImageView.frame), CGRectGetHeight(self.contactImageView.frame));
    
    self.expertLogoImageView.frame = CGRectMake(CGRectGetMinX(self.expertLogoImageView.frame), CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f);

    if (self.contactTableViewCellType == TAPContactTableViewCellTypeWithUsername) {
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), 15.0f, CGRectGetWidth(self.contactNameLabel.frame), 18.0f);
        
        self.usernameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.usernameLabel.frame), 16.0f);
    }
    else {
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), 15.0f, CGRectGetWidth(self.contactNameLabel.frame), 34.0f);
        
        self.usernameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.usernameLabel.frame), 0.0f);
    }
}

- (void)setContactTableViewCellType:(TAPContactTableViewCellType)contactTableViewCellType {
    _contactTableViewCellType = contactTableViewCellType;
    [self resizeCell];
}

@end

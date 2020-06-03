//
//  TAPMentionListTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/05/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import "TAPMentionListTableViewCell.h"

@interface TAPMentionListTableViewCell()

@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *photoImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIView *separatorView;

@end

@implementation TAPMentionListTableViewCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 11.0f, 32.0f, 32.0f)];
        self.initialNameView.alpha = 0.0f;
        self.initialNameView.layer.cornerRadius = CGRectGetHeight(self.initialNameView.frame) / 2.0f;
        self.initialNameView.clipsToBounds = YES;
        [self.contentView addSubview:self.initialNameView];
        
        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarMediumLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarMediumLabel];
        _initialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.initialNameView.frame), CGRectGetHeight(self.initialNameView.frame))];
        self.initialNameLabel.font = initialNameLabelFont;
        self.initialNameLabel.textColor = initialNameLabelColor;
        self.initialNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.initialNameView addSubview:self.initialNameLabel];

        
        _photoImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(16.0f, 11.0f, 32.0f, 32.0f)];
        self.photoImageView.clipsToBounds = YES;
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.photoImageView.layer.cornerRadius = CGRectGetHeight(self.photoImageView.frame) / 2.0f;
        [self.contentView addSubview:self.photoImageView];
        
        UIFont *nameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMentionListNameLabel];
        UIColor *nameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListName];
        //Main screen width - left gap photo width - photo image view width - middle gap - outer right gap label
        CGFloat nameLabelWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 32.0f - 8.0f - 16.0f;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.photoImageView.frame) + 8.0f, 8.0f, nameLabelWidth, 20.0f)];
        self.nameLabel.font = nameLabelFont;
        self.nameLabel.textColor = nameLabelColor;
        [self.contentView addSubview:self.nameLabel];
        
        UIFont *usernameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMentionListUsernameLabel];
        UIColor *usernameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListUsername];
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.nameLabel.frame), 18.0f)];
        self.usernameLabel.font = usernameLabelFont;
        self.usernameLabel.textColor = usernameLabelColor;
        [self.contentView addSubview:self.usernameLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 54.0f - 1.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.contentView addSubview:self.separatorView];
    }
    
    return self;
}

- (void)setMentionListCellWithUser:(TAPUserModel *)user {
    if (user.userID != nil) {
        NSString *contactName = user.fullname;
        contactName = [TAPUtil nullToEmptyString:contactName];
        
        NSString *usernameString = user.username;
        usernameString = [TAPUtil nullToEmptyString:usernameString];
        NSString *contactUsername = [NSString stringWithFormat:@"@%@", usernameString];

        NSString *imageURL = user.imageURL.fullsize;
        if (imageURL == nil || [imageURL isEqualToString:@""]) {
            //No photo found, get the initial
            self.initialNameView.alpha = 1.0f;
            self.photoImageView.alpha = 0.0f;
            self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:contactName];
            self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:contactName isGroup:NO];
        }
        else {
            self.initialNameView.alpha = 0.0f;
            self.photoImageView.alpha = 1.0f;
            [self.photoImageView setImageWithURLString:imageURL];
        }
        
        NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactNameLetterSpacing = -0.2f;
        [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
        [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                             range:NSMakeRange(0, [contactName length])];
        self.nameLabel.attributedText = contactNameAttributedString;
        
        NSMutableDictionary *contactUsernameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactUsernameLetterSpacing = -0.2f;
        [contactUsernameAttributesDictionary setObject:@(contactUsernameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactUsernameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactUsername];
        [contactUsernameAttributedString addAttributes:contactUsernameAttributesDictionary
                                                 range:NSMakeRange(0, [contactUsername length])];
        self.usernameLabel.attributedText = contactUsernameAttributedString;
    }
}

- (void)showSeparatorView:(BOOL)show {
    if (show) {
        self.separatorView.alpha = 1.0f;
    }
    else {
        self.separatorView.alpha = 0.0f;
    }
}

@end

//
//  TAPMentionListXIBTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/05/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import "TAPMentionListXIBTableViewCell.h"

@interface TAPMentionListXIBTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *initialNameView;
@property (strong, nonatomic) IBOutlet UILabel *initialNameLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation TAPMentionListXIBTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.initialNameView.alpha = 0.0f;
    self.initialNameView.layer.cornerRadius = CGRectGetHeight(self.initialNameView.frame) / 2.0f;
    self.initialNameView.clipsToBounds = YES;
    
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.layer.cornerRadius = CGRectGetHeight(self.photoImageView.frame) / 2.0f;
    
    UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarMediumLabel];
    UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarMediumLabel];
    self.initialNameLabel.font = initialNameLabelFont;
    self.initialNameLabel.textColor = initialNameLabelColor;
    self.initialNameLabel.textAlignment = NSTextAlignmentCenter;
    
    UIFont *nameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMentionListNameLabel];
    UIColor *nameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListName];
    self.nameLabel.font = nameLabelFont;
    self.nameLabel.textColor = nameLabelColor;
    
    UIFont *usernameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMentionListUsernameLabel];
    UIColor *usernameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorContactListUsername];
    self.usernameLabel.font = usernameLabelFont;
    self.usernameLabel.textColor = usernameLabelColor;
    
    self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

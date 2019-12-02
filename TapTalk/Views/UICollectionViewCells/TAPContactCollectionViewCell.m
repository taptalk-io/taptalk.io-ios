//
//  TAPContactCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactCollectionViewCell.h"

@interface TAPContactCollectionViewCell()
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *initialNameView;
@property (strong, nonatomic) UILabel *initialNameLabel;
@property (strong, nonatomic) TAPImageView *contactImageView;
@property (strong, nonatomic) UIImageView *removeImageView;
@property (strong, nonatomic) UILabel *contactNameLabel;
@end

@implementation TAPContactCollectionViewCell
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        _initialNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, 52.0f)];
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
        
        _contactImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, 52.0f)];
        self.contactImageView.layer.cornerRadius = CGRectGetHeight(self.contactImageView.frame) / 2.0;
        self.contactImageView.clipsToBounds = YES;
        self.contactImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgView addSubview:self.contactImageView];
        
        _removeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) - 22.0f, CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.removeImageView.image = [UIImage imageNamed:@"TAPIconRemove" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bgView addSubview:self.removeImageView];
        
        UIFont *nameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSelectedMemberListName];
        UIColor *nameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSelectedMemberListName];
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.contactImageView.frame) + 8.0f, 52.0f, 13.0f)];
        self.contactNameLabel.font = nameLabelFont;
        self.contactNameLabel.textColor = nameLabelColor;
        self.contactNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.contactNameLabel];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setContactCollectionViewCellWithModel:(TAPUserModel *)user {
    NSString *profileImageURL = user.imageURL.thumbnail;
    NSString *contactName = user.fullname;
    if ([user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        contactName = NSLocalizedString(@"You", @"");
    }
    
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        //No photo found, get the initial
        self.initialNameView.alpha = 1.0f;
        self.contactImageView.alpha = 0.0f;
        self.initialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:user.fullname];
        self.initialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:user.fullname isGroup:NO];
    }
    else {
        self.initialNameView.alpha = 0.0f;
        self.contactImageView.alpha = 1.0f;
        [self.contactImageView setImageWithURLString:profileImageURL];
    }
    NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat contactNameLetterSpacing = -0.2f;
    [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
    NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
    [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                         range:NSMakeRange(0, [contactName length])];
    self.contactNameLabel.attributedText = contactNameAttributedString;
}

- (void)showRemoveIcon:(BOOL)isVisible {
    if (isVisible) {
        self.removeImageView.alpha = 1.0f;
    }
    else {
        self.removeImageView.alpha = 0.0f;
    }
}

@end

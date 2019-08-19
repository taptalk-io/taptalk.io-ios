//
//  TAPContactTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactTableViewCell.h"
#import "TAPImageView.h"

@interface TAPContactTableViewCell()
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) TAPImageView *contactImageView;
@property (strong, nonatomic) UIImageView *expertLogoImageView;
@property (strong, nonatomic) UILabel *contactNameLabel;
@property (strong, nonatomic) UILabel *adminIndicatorLabel;
@property (strong, nonatomic) UIView *separatorView;

@property (strong, nonatomic) UIView *nonSelectedView;
@property (strong, nonatomic) UIImageView *selectedImageView;
@end

@implementation TAPContactTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 64.0f)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        _contactImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(16.0f, 6.0f, 52.0f, 52.0f)];
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
        
        _adminIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) + 8.0f, CGRectGetMaxY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - (CGRectGetMaxX(self.contactImageView.frame) + 8.0f), 20.0f)];
        //CS NOTE TO DOM - check style
        self.adminIndicatorLabel.textColor = [TAPUtil getColor:@"9b9b9b"];
        self.adminIndicatorLabel.font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR     size:14.0f];
        self.adminIndicatorLabel.alpha = 0.0f;
        self.adminIndicatorLabel.text = NSLocalizedString(@"Admin", @"");
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
        NSString *imageURL = user.imageURL.fullsize;
        
        if (imageURL == nil || [imageURL isEqualToString:@""]) {
            self.contactImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }
        else {
            [self.contactImageView setImageWithURLString:imageURL];
        }
        
        NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat contactNameLetterSpacing = -0.2f;
        [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
        [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                             range:NSMakeRange(0, [contactName length])];
        self.contactNameLabel.attributedText = contactNameAttributedString;
    }
}

- (void)isRequireSelection:(BOOL)isRequired {
    if (isRequired) {
        //resize
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f - 8.0f - CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.contactNameLabel.frame));
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        //resize
        self.contactNameLabel.frame = CGRectMake(CGRectGetMinX(self.contactNameLabel.frame), CGRectGetMinY(self.contactNameLabel.frame), CGRectGetWidth(self.bgView.frame) - 16.0f - CGRectGetMinX(self.contactNameLabel.frame), CGRectGetHeight(self.contactNameLabel.frame));
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
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

@end

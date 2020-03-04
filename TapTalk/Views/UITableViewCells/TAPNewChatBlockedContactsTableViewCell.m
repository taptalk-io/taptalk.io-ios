//
//  TAPNewChatBlockedContactsTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNewChatBlockedContactsTableViewCell.h"

@interface TAPNewChatBlockedContactsTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation TAPNewChatBlockedContactsTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 98.0f)];
        self.bgView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self.contentView addSubview:self.bgView];
        
        UIFont *infoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *infoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 28.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 18.0f)];
        self.descriptionLabel.text = NSLocalizedStringFromTableInBundle(@"Can’t find the contact you were looking for?", nil, [TAPUtil currentBundle], @"");
        self.descriptionLabel.textColor = infoLabelColor;
        self.descriptionLabel.font = infoLabelFont;
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableDictionary *descriptionAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat descriptionLetterSpacing = -0.2f;
        [descriptionAttributesDictionary setObject:@(descriptionLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *descriptionAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
        [descriptionAttributedString addAttributes:descriptionAttributesDictionary
                                             range:NSMakeRange(0, [self.descriptionLabel.text length])];
        self.descriptionLabel.attributedText = descriptionAttributedString;
        [self.bgView addSubview:self.descriptionLabel];
        
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.descriptionLabel.frame) + 8.0f, CGRectGetWidth(self.descriptionLabel.frame), 18.0f)];
        self.titleLabel.text = NSLocalizedStringFromTableInBundle(@"View Blocked Contacts", nil, [TAPUtil currentBundle], @"");
        self.titleLabel.textColor = clickableLabelColor;
        self.titleLabel.font = clickableLabelFont;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableDictionary *titleAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat titleLetterSpacing = -0.2f;
        [titleAttributesDictionary setObject:@(titleLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [titleAttributedString addAttributes:titleAttributesDictionary
                                             range:NSMakeRange(0, [self.titleLabel.text length])];
        self.titleLabel.attributedText = titleAttributedString;
        [self.bgView addSubview:self.titleLabel];
    }
    
    return self;
}

#pragma mark - Custom Method

@end

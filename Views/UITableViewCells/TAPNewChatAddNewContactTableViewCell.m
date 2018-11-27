//
//  TAPNewChatAddNewContactTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNewChatAddNewContactTableViewCell.h"

@interface TAPNewChatAddNewContactTableViewCell()
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation TAPNewChatAddNewContactTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 98.0f)];
        self.bgView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        [self.contentView addSubview:self.bgView];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 20.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 18.0f)];
        self.descriptionLabel.text = NSLocalizedString(@"Can’t find who you are looking for?", @"");
        self.descriptionLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.descriptionLabel.font = [UIFont fontWithName:TAP_FONT_NAME_NORMAL size:13.0f];
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableDictionary *descriptionAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat descriptionLetterSpacing = -0.2f;
        [descriptionAttributesDictionary setObject:@(descriptionLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *descriptionAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
        [descriptionAttributedString addAttributes:descriptionAttributesDictionary
                                             range:NSMakeRange(0, [self.descriptionLabel.text length])];
        self.descriptionLabel.attributedText = descriptionAttributedString;
        [self.bgView addSubview:self.descriptionLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.descriptionLabel.frame), CGRectGetWidth(self.descriptionLabel.frame), 18.0f)];
        self.titleLabel.text = NSLocalizedString(@"Add New Contact", @"");
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93];
        self.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:13.0f];
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

//
//  TAPNewChatOptionTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNewChatOptionTableViewCell.h"

@interface TAPNewChatOptionTableViewCell()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIImageView *rightArrow;

@end

@implementation TAPNewChatOptionTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 56.0f)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 12.0f, 32.0f, 32.0f)];
        [self.bgView addSubview:self.iconImageView];
        
        _rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bgView.frame) - 16.0f - 8.0f, (CGRectGetHeight(self.bgView.frame) - 14.0f) / 2.0f, 8.0f, 14.0f)];
        self.rightArrow.image = [UIImage imageNamed:@"TAPIconRightArrowCell" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bgView addSubview:self.rightArrow];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 4.0f, 0.0f, CGRectGetMinX(self.rightArrow.frame) - 8.0f - (CGRectGetMaxX(self.iconImageView.frame) + 4.0f), CGRectGetHeight(self.bgView.frame))];
        [self.bgView addSubview:self.descriptionLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_EA];
        [self.bgView addSubview:self.separatorView];
    }
    return self;
}

#pragma mark - Custom Method
- (void)setNewChatOptionTableViewCellType:(TAPNewChatOptionTableViewCellType)type {
    NSString *imageName = @"";
    NSString *descriptionString = @"";
    
    if (type == TAPNewChatOptionTableViewCellTypeNewContact) {
        imageName = @"TAPIconNewContact";
        descriptionString = @"New Contact";
    }
    else if (type == TAPNewChatOptionTableViewCellTypeScanQRCode) {
        imageName = @"TAPIconScanQrCode";
        descriptionString = @"Scan QR code";
    }
    else if (type == TAPNewChatOptionTableViewCellTypeNewGroup) {
        imageName = @"TAPIconNewGroup";
        descriptionString = @"New Group";
    }
    
    self.iconImageView.image = [UIImage imageNamed:imageName inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    NSMutableDictionary *descriptionAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat descriptionLetterSpacing = -0.2f;
    [descriptionAttributesDictionary setObject:@(descriptionLetterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *descriptionStyle = [[NSMutableParagraphStyle alloc] init];
    descriptionStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [descriptionAttributesDictionary setObject:descriptionStyle forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *descriptionAttributedString = [[NSMutableAttributedString alloc] initWithString:descriptionString];
    [descriptionAttributedString addAttributes:descriptionAttributesDictionary
                                         range:NSMakeRange(0, [descriptionString length])];
    self.descriptionLabel.attributedText = descriptionAttributedString;
    self.descriptionLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
    self.descriptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
}

@end

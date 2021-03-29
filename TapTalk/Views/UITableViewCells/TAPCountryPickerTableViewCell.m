//
//  TAPCountryPickerTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCountryPickerTableViewCell.h"

@interface TAPCountryPickerTableViewCell ()

@property (strong, nonatomic) TAPImageView *countryFlagImageView;
@property (strong, nonatomic) UILabel *countryNameLabel;
//@property (strong, nonatomic) UIView *bottomSeparatorView;
@property (strong, nonatomic) UIImageView *selectedImageView;

@end

@implementation TAPCountryPickerTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _countryFlagImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, 28.0f, 20.0f)];
        self.countryFlagImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.countryFlagImageView];
        
        CGFloat countryNameLabelWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMaxX(self.countryFlagImageView.frame) - 16.0f - 16.0f - 20.0f - 32.0f;
        
        UIFont *countryPickerLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontCountryPickerLabel];
        UIColor *countryPickerLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorCountryPickerLabel];
        _countryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.countryFlagImageView.frame) + 16.0f, CGRectGetMinY(self.countryFlagImageView.frame), countryNameLabelWidth, 20.0f)];
        self.countryNameLabel.font = countryPickerLabelFont;
        self.countryNameLabel.textColor = countryPickerLabelColor;
        [self.contentView addSubview:self.countryNameLabel];
        
//        _bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.countryNameLabel.frame), 44.0f - 1.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMinX(self.countryNameLabel.frame), 1.0f)];
//        self.bottomSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
//        [self.contentView addSubview:self.bottomSeparatorView];
        
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 32.0f - 20.0f , (44.0f - 20.0f) / 2.0f, 20.0f, 20.0f)];
        self.selectedImageView.image = [UIImage imageNamed:@"TAPIconTick" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.selectedImageView.image = [self.selectedImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChecklist]];
        self.selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.selectedImageView.alpha = 0.0f;
        [self.contentView addSubview:self.selectedImageView];
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.countryFlagImageView.image = [UIImage imageNamed:@"TAPDefaultCountryFlag" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.countryNameLabel.text = @"";
//    self.bottomSeparatorView.alpha = 1.0f;
    [self setAsSelected:NO animated:NO];
}

#pragma mark - Custom Method
- (void)setCountryData:(TAPCountryModel *)country {
    
    NSString *countryName = country.countryCommonName;
    NSString *flagIconURL = country.flagIconURL;
    
    self.countryNameLabel.text = countryName;
    
    if (flagIconURL == nil || [flagIconURL isEqualToString:@""]) {
        self.countryFlagImageView.image = [UIImage imageNamed:@"TAPDefaultCountryFlag" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
         [self.countryFlagImageView setImageWithURLString:flagIconURL];
    }
}

//- (void)showSeparatorView:(BOOL)show {
//    if (show) {
//        self.bottomSeparatorView.alpha = 1.0f;
//    }
//    else {
//        self.bottomSeparatorView.alpha = 0.0f;
//    }
//}

- (void)setAsSelected:(BOOL)selected animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            if (selected) {
                self.selectedImageView.alpha = 1.0f;
            }
            else {
                self.selectedImageView.alpha = 0.0f;
            }
        }];
    }
    else {
        if (selected) {
            self.selectedImageView.alpha = 1.0f;
        }
        else {
            self.selectedImageView.alpha = 0.0f;
        }
    }
}

@end

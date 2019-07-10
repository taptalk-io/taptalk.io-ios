//
//  TAPKeyboardTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPKeyboardTableViewCell.h"

@interface TAPKeyboardTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *stringLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *iconImageView;

@end

@implementation TAPKeyboardTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImageView.backgroundColor = [UIColor clearColor];
    
    UIFont *customKeyboardItemLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontCustomKeyboardItemLabel];
    UIColor *customKeyboardItemLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorCustomKeyboardItemLabel];
    self.stringLabel.textColor = customKeyboardItemLabelColor;
    self.stringLabel.font = customKeyboardItemLabelFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark - Custom Method
- (void)setKeyboardCellWithKeyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem {
    
    if(keyboardItem.iconImage != nil) {
        self.iconImageView.image = keyboardItem.iconImage;
    }
    else {
        [self.iconImageView setImageWithURLString:keyboardItem.iconURL];
    }
    
    self.stringLabel.text = keyboardItem.itemName;
}

@end

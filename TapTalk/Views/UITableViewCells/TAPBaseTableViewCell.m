//
//  TAPBaseTableViewCell.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/16/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

@implementation TAPBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGrayHighlightColor {
    [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
}

- (void)setOrangeHighlightColor {
    [self setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
}

- (void)setHighlightColor:(UIColor *)color {
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    self.selectedBackgroundView.backgroundColor = color;
}

@end

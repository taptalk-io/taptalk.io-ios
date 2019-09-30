//
//  TAPBaseXIBTableViewCell.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/6/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseXIBTableViewCell.h"

@implementation TAPBaseXIBTableViewCell

#pragma mark - Lifecycle
+ (UINib *)cellNib {
    UINib *cellNib = [UINib nibWithNibName:[self.class description] bundle:[TAPUtil currentBundle]];
    return cellNib;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Custom Method
- (CGFloat)automaticHeight {
    if (IS_IOS_10_OR_ABOVE) {
        return UITableViewAutomaticDimension;
    }
    else {
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
        float height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        return height;
    }
}

@end

//
//  TAPUnreadMessagesBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPUnreadMessagesBubbleTableViewCell.h"

@implementation TAPUnreadMessagesBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Custom Method

@end

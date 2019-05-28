//
//  TAPUnreadMessagesBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPUnreadMessagesBubbleTableViewCell.h"

@interface TAPUnreadMessagesBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *backgroundBarView;
@property (strong, nonatomic) IBOutlet UILabel *unreadMessageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftGapConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightGapConstraint;

@end

@implementation TAPUnreadMessagesBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
    self.backgroundBarView.backgroundColor = [[TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1] colorWithAlphaComponent:0.1f];
    self.unreadMessageLabel.textColor = [TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1];

    CGFloat gap = (CGRectGetWidth([UIScreen mainScreen].bounds) - 120.0f) / 2.0f;
    self.leftGapConstraint.constant = gap;
    self.rightGapConstraint.constant = gap;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Custom Method

@end

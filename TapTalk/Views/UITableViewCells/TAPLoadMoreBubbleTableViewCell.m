//
//  TAPLoadMoreBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPLoadMoreBubbleTableViewCell.h"

@interface TAPLoadMoreBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicatorView;

@end

@implementation TAPLoadMoreBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.loadingActivityIndicatorView startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Method

@end
